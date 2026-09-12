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
	assert(sent[1].options.fwmark == desync.fwmark)
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

	local split_fake = flow("tls_client_hello", first_fake, ipv6)
	local fake_positions, fake_count = check_split(split_fake)
	assert(fake_positions and fake_count >= 2)
	local low_ttl = flow("tls_client_hello", first_fake, ipv6)
	if ipv6 then
		low_ttl.dis.ip6.ip6_hlim = 3
	else
		low_ttl.dis.ip.ip_ttl = 3
	end
	sent = {}
	assert(connection_multisplit(nil, low_ttl) == VERDICT_DROP)
	assert(#sent >= 2)
	for _, piece in ipairs(sent) do
		assert((piece.dis.ip and piece.dis.ip.ip_ttl or piece.dis.ip6.ip6_hlim) == 3)
	end
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

local short_label = {}
for _ = 1, 100 do
	local desync = flow("http_req", "GET / HTTP/1.1\r\nHost: x.com\r\nUser-Agent: fixture\r\n\r\n")
	check_split(desync)
	local host_first = resolve_pos(desync.reasm_data, desync.l7payload, "host")
	local host_last = resolve_pos(desync.reasm_data, desync.l7payload, "endhost")
	local length = 0
	for _, piece in ipairs(sent) do
		length = length + #piece.dis.payload
		if length >= host_first and length < host_last - 1 then
			short_label[length] = true
		end
	end
end
local short_label_count = 0
for _ in pairs(short_label) do
	short_label_count = short_label_count + 1
end
assert(short_label_count > 2)

print("zapret strategy tests passed")
