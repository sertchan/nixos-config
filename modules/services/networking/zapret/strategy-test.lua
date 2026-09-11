local sent = {}
local send_failure = false
local send_failure_after = nil

rawsend_dissect = function(dis, options)
	if send_failure or send_failure_after and #sent >= send_failure_after then
		return false
	end
	sent[#sent + 1] = { dis = deepcopy(dis), options = deepcopy(options) }
	return true
end

local function flow(payload, data, ipv6)
	local dis = {
		tcp = { th_seq = 1000, th_flags = TH_ACK, th_urp = 0, options = {} },
		payload = data,
	}
	if ipv6 then
		dis.ip6 = { ip6_hlim = 64, exthdr = {} }
	else
		dis.ip = { ip_ttl = 64, ip_id = 1, options = "" }
	end
	return {
		arg = {},
		outgoing = true,
		l7payload = payload,
		dis = dis,
		reasm_data = data,
		tcp_mss = 1460,
		fwmark = 1073741824,
		func_instance = "test",
		track = { lua_state = {}, incoming_ttl = ipv6 and 57 or 56 },
	}
end

local function quic_flow(ipv6, dcid, scid, version)
	dcid = dcid or "dest-cid"
	scid = scid or "src-cid"
	local initial = "\xc0"
		.. (version or "\x00\x00\x00\x01")
		.. string.char(#dcid)
		.. dcid
		.. string.char(#scid)
		.. scid
		.. string.rep("\x00", 128)
	local desync = flow("quic_initial", initial, ipv6)
	desync.dis.tcp = nil
	desync.dis.udp = { uh_sport = 54321, uh_dport = 443 }
	desync.reasm_data = nil
	desync.arg = { repeats = "2" }
	return desync
end

local function check_quic(desync)
	sent = {}
	local original_args = desync.arg
	local original_payload = desync.dis.payload
	assert(connection_quic_fake(nil, desync) == nil)
	assert(desync.arg == original_args)
	assert(desync.dis.payload == original_payload)
	assert(#sent == 1)
	local packet = sent[1]
	assert(packet.dis.udp and not packet.dis.tcp)
	assert(packet.dis.udp.uh_sport == desync.dis.udp.uh_sport)
	assert(packet.dis.udp.uh_dport == 443)
	assert(packet.options.repeats == "2")
	assert(packet.options.fwmark == desync.fwmark)
	assert((packet.dis.ip and packet.dis.ip.ip_ttl or packet.dis.ip6.ip6_hlim) == 64)
	assert(#packet.dis.payload == #fake_default_quic)
	assert(packet.dis.payload:sub(1, 1) == fake_default_quic:sub(1, 1))
	assert(packet.dis.payload ~= fake_default_quic)
	return packet.dis.payload
end

local quic_fakes = {}
for _, ipv6 in ipairs({ false, true }) do
	for _ = 1, 100 do
		local desync = quic_flow(ipv6)
		local first_fake = check_quic(desync)
		assert(not quic_fakes[first_fake])
		quic_fakes[first_fake] = true
		assert(check_quic(desync) == first_fake)
		desync.dis.payload = desync.dis.payload .. "retransmit"
		assert(check_quic(desync) == first_fake)
		for _, next_flow in ipairs({
			quic_flow(ipv6, "next-dcid"),
			quic_flow(ipv6, nil, "next-scid"),
			quic_flow(ipv6, nil, nil, "\x6b\x33\x43\xcf"),
		}) do
			next_flow.track = desync.track
			assert(check_quic(next_flow) ~= first_fake)
			assert(check_quic(desync) == first_fake)
		end
		desync.replay = true
		desync.replay_piece = 1
		assert(check_quic(desync) == first_fake)
		desync.replay_piece = 2
		desync.replay_piece_last = true
		sent = {}
		assert(connection_quic_fake(nil, desync) == nil)
		assert(#sent == 0)
	end
end

for _, modify in ipairs({
	function(desync)
		desync.track = nil
	end,
	function(desync)
		desync.track.lua_state = nil
	end,
	function(desync)
		desync.outgoing = false
	end,
	function(desync)
		desync.dis.udp = nil
	end,
	function(desync)
		desync.l7payload = "unknown"
	end,
	function(desync)
		desync.dis.payload = fake_default_quic
	end,
	function(desync)
		desync.dis.payload = ""
	end,
	function(desync)
		desync.dis.payload = "\xc0\x00\x00\x00\x01\x14x"
	end,
	function(desync)
		desync.dis.payload = "\xc0\x00\x00\x00\x01\x00\x14x"
	end,
	function(desync)
		desync.dis.payload = "\xc0\x00\x00\x00\x01\xff" .. string.rep("x", 300)
	end,
	function(desync)
		desync.dis.payload = "\xc0\x00\x00\x00\x01\x00\xff" .. string.rep("x", 300)
	end,
}) do
	local desync = quic_flow()
	modify(desync)
	sent = {}
	assert(connection_quic_fake(nil, desync) == nil)
	assert(#sent == 0)
end

local hkdf_native = hkdf
hkdf = function()
	return nil
end
sent = {}
assert(connection_quic_fake(nil, quic_flow()) == nil)
assert(#sent == 0)
hkdf = hkdf_native

local function check_split(desync)
	sent = {}
	local original_args = desync.arg
	assert(connection_multisplit(nil, desync) == VERDICT_DROP)
	assert(desync.arg == original_args)
	local pieces = {}
	local length = 0
	local host_first = resolve_pos(desync.reasm_data, desync.l7payload, "host")
	local host_last = resolve_pos(desync.reasm_data, desync.l7payload, "endhost")
	local host_split = false
	for _, packet in ipairs(sent) do
		local dis = packet.dis
		assert(#dis.payload > 0)
		assert(dis.tcp.th_seq == desync.dis.tcp.th_seq + length)
		assert(not find_tcp_option(dis.tcp.options, TCP_KIND_MD5))
		assert((dis.ip and dis.ip.ip_ttl or dis.ip6.ip6_hlim) == 64)
		assert(packet.options.fwmark == desync.fwmark)
		length = length + #dis.payload
		if length >= host_first and length < host_last - 1 then
			host_split = true
		end
		pieces[#pieces + 1] = dis.payload
	end
	assert(host_split)
	assert(table.concat(pieces) == desync.reasm_data)
	return desync.track.lua_state.connection_strategy.split_positions, #sent
end

math.randomseed(123456)
local layouts = {}
local counts = {}
local http = "GET / HTTP/1.1\r\nHost: www.example.com\r\nUser-Agent: fixture\r\n\r\n"
for _, ipv6 in ipairs({ false, true }) do
	for _, sample in ipairs({ { "http_req", http }, { "tls_client_hello", fake_default_tls } }) do
		for _ = 1, 100 do
			local desync = flow(sample[1], sample[2], ipv6)
			local positions, count = check_split(desync)
			layouts[positions] = true
			counts[count] = true
			assert(check_split(desync) == positions)
		end
	end
end
local layout_count = 0
for _ in pairs(layouts) do
	layout_count = layout_count + 1
end
assert(layout_count > 20)
assert(counts[2] and counts[3])

local replay = flow("tls_client_hello", fake_default_tls)
replay.replay = true
replay.replay_piece = 1
check_split(replay)
sent = {}
replay.replay_piece = 2
replay.replay_piece_last = true
assert(connection_multisplit(nil, replay) == VERDICT_DROP)
assert(#sent == 0)
assert(not replay.track.lua_state.test_replay_drop)

local small_mss = flow("tls_client_hello", fake_default_tls)
small_mss.tcp_mss = 128
check_split(small_mss)
for _, packet in ipairs(sent) do
	assert(#packet.dis.payload <= 128)
end

for _, ipv6 in ipairs({ false, true }) do
	local desync = flow("tls_client_hello", fake_default_tls, ipv6)
	desync.arg = {
		tcp_md5 = "",
		fwmark = "0x20000000",
		ip_autottl = "-1,3-20",
		ip6_autottl = "-1,3-20",
		ip_ttl = "3",
		ip6_ttl = "3",
	}
	sent = {}
	connection_fake(nil, desync)
	assert(#sent == 1)
	local packet = sent[1].dis
	local first_fake = packet.payload
	assert(first_fake ~= fake_default_tls)
	assert(find_tcp_option(packet.tcp.options, TCP_KIND_MD5))
	assert((packet.ip and packet.ip.ip_ttl or packet.ip6.ip6_hlim) == (ipv6 and 6 or 7))
	assert(sent[1].options.fwmark == "0x20000000")
	assert(desync.dis.payload == fake_default_tls)
	assert(#desync.dis.tcp.options == 0)
	sent = {}
	connection_fake(nil, desync)
	assert(sent[1].dis.payload == first_fake)
	local another = flow("tls_client_hello", fake_default_tls, ipv6)
	another.arg = desync.arg
	sent = {}
	connection_fake(nil, another)
	local first = resolve_pos(first_fake, "tls_client_hello", "host")
	local last = resolve_pos(first_fake, "tls_client_hello", "endhost")
	assert(first_fake:sub(first, last - 1) ~= sent[1].dis.payload:sub(first, last - 1))
	local fallback = flow("tls_client_hello", fake_default_tls, ipv6)
	fallback.track.incoming_ttl = nil
	fallback.arg = desync.arg
	sent = {}
	connection_fake(nil, fallback)
	assert((sent[1].dis.ip and sent[1].dis.ip.ip_ttl or sent[1].dis.ip6.ip6_hlim) == 3)
end

for _, modify in ipairs({
	function(desync)
		desync.track = nil
	end,
	function(desync)
		desync.outgoing = false
	end,
	function(desync)
		desync.dis.tcp = nil
	end,
	function(desync)
		desync.l7payload = "unknown"
	end,
}) do
	local desync = flow("tls_client_hello", fake_default_tls)
	modify(desync)
	sent = {}
	connection_fake(nil, desync)
	connection_multisplit(nil, desync)
	assert(#sent == 0)
end

sent = {}
assert(connection_multisplit(nil, flow("http_req", "GET / HTTP/1.0\r\n\r\n")) == nil)
assert(connection_multisplit(nil, flow("http_req", "GET / HTTP/1.1\r\nHost: a\r\n\r\n")) == nil)
assert(#sent == 0)
send_failure = true
assert(connection_multisplit(nil, flow("tls_client_hello", fake_default_tls)) == VERDICT_PASS)
assert(#sent == 0)
send_failure = false
send_failure_after = 1
assert(connection_multisplit(nil, flow("tls_client_hello", fake_default_tls)) == VERDICT_PASS)
assert(#sent == 1)
send_failure_after = nil
sent = {}
send_failure = true
assert(connection_quic_fake(nil, quic_flow()) == nil)
assert(#sent == 0)
print("zapret strategy tests passed")
