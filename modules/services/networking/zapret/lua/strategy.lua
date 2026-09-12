local function connection_state(desync)
	if not desync.track or not desync.track.lua_state then
		return nil
	end
	local state = desync.track.lua_state
	state.connection_strategy = state.connection_strategy or {}
	return state.connection_strategy
end

local function send_connection_fake(ctx, desync, payload)
	desync.connection_fake_payload = payload
	local original_args = desync.arg
	desync.arg = deepcopy(original_args)
	desync.arg.blob = "connection_fake_payload"
	desync.arg.tls_mod = nil
	local verdict = fake(ctx, desync)
	desync.arg = original_args
	return verdict
end

function connection_fake(ctx, desync)
	if not desync.outgoing or not desync.dis.tcp or desync.l7payload ~= "tls_client_hello" then
		return
	end
	local state = connection_state(desync)
	if not state then
		return
	end
	if not state.fake_tls then
		state.fake_tls = tls_mod(fake_default_tls, "rnd,rndsni,dupsid", desync.reasm_data or desync.dis.payload)
	end
	if not state.fake_tls then
		return
	end
	return send_connection_fake(ctx, desync, state.fake_tls)
end

local function split_anchor(data, payload, first, last)
	local label_first = resolve_pos(data, payload, "sld")
	local label_last = resolve_pos(data, payload, "endsld")
	if label_first and label_last and label_last - label_first > 1 then
		return label_first, label_last
	end
	return first, last
end

local function split_positions(data, payload, first, last)
	if last - first < 2 then
		return nil
	end
	local anchor_first, anchor_last = split_anchor(data, payload, first, last)
	local positions = { math.random(anchor_first + 1, anchor_last - 1) }
	local minimum_gap = 8
	local left_first = minimum_gap + 1
	local left_last = positions[1] - minimum_gap
	local right_first = positions[1] + minimum_gap
	local right_last = #data - minimum_gap + 1
	local left_count = math.max(0, left_last - left_first + 1)
	local right_count = math.max(0, right_last - right_first + 1)
	if left_count + right_count > 0 and math.random(2) == 2 then
		local choice = math.random(left_count + right_count)
		positions[#positions + 1] = choice <= left_count and left_first + choice - 1
			or right_first + choice - left_count - 1
	end
	table.sort(positions)
	for index, position in ipairs(positions) do
		positions[index] = tostring(position - 1)
	end
	return table.concat(positions, ",")
end

function connection_multisplit(ctx, desync)
	if not desync.outgoing or not desync.dis.tcp then
		return
	end
	if desync.l7payload ~= "http_req" and desync.l7payload ~= "tls_client_hello" then
		return
	end
	local state = connection_state(desync)
	if not state then
		return
	end
	local data = desync.reasm_data or desync.dis.payload
	local first = resolve_pos(data, desync.l7payload, "host")
	local last = resolve_pos(data, desync.l7payload, "endhost")
	if not first or not last then
		return
	end
	local layout = table.concat({ desync.l7payload, #data, first, last }, ":")
	if state.split_layout ~= layout then
		state.split_layout = layout
		state.split_positions = split_positions(data, desync.l7payload, first, last)
	end
	if not state.split_positions then
		return
	end
	local original_args = desync.arg
	desync.arg = { pos = state.split_positions }
	local verdict = multisplit(ctx, desync)
	desync.arg = original_args
	return verdict
end
