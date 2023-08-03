--NPC handlers/packets

--Packet globals
__busy = false
__get_packet_sequence = {}
__get_keypress_sequence = {}
__get_menu_id = 0
__get_npc_name = ''
__received_response = false
__poke = false

--Shop globals
__get_shop_slot = 0
__get_shop_item_count = 0
__shop_busy = false
__shop_packet = false
__shop_opened = false

--HTMB/orb globals
__macro_orb_type = false
__deimos_orb_type = false
__htmb_state = false
__htmb_entered = false
__orb_type = ''
__orb_state = false
__orb_entered = false
__player_leader = ''

function handle_incoming_chunk(id, data, mod, inj, blk)
    if id == 0x028 then	-- Casting
        local action_message = packets.parse('incoming', data)
		if action_message["Category"] == 4 then
			isCasting = false
		elseif action_message["Category"] == 8 then
			isCasting = true
		end
	elseif id == 0x0DF or id == 0x0DD or id == 0x0C8 then -- Char update
        local packet = packets.parse('incoming', data)
		if packet then
			local playerId = packet['ID']
			local job = packet['Main job']
			
			if playerId and playerId > 0 then
				set_registry(packet['ID'], packet['Main job'])
			end
		end
	elseif (id == 0x032 or id == 0x034) and __busy and not inj then
		local parsed = packets.parse('incoming', data)
		if parsed and parsed['Zone'] == zone_id then
			local target = windower.ffxi.get_mob_by_index(parsed['NPC Index']) or false
			--Packet send
			if target and target.name == __get_npc_name and parsed['Menu ID'] == __get_menu_id and (next(__get_packet_sequence) ~= nil) then
				atcwarn('Packet 0x032 / 0x034 received: Packets Command')
				__received_response = true
				if __shop_packet then
					__shop_busy = true
				end
				send_packet(parsed, __get_packet_sequence)
				return true
			--Keypresses
			elseif target and target.name == __get_npc_name and (next(__get_keypress_sequence) ~= nil) then
				atcwarn('Packet 0x032 / 0x034 received: Keypress')
				__received_response = true
				keypress_cmd(__get_keypress_sequence)
			--Poke
			elseif target and target.name == __get_npc_name then
				atcwarn('Packet 0x032 / 0x034 received: Poke Command')
				__received_response = true
			else
				atcwarn('ABORT! Wrong NPC interaction! 0x032 / 0x034')
				send_packet(parsed, {{0,16384,0,false}})
				finish_interaction()
			end
		end
	-- Open shop sub menu
	elseif id == 0x03C and not inj and ((not __busy and __shop_busy) or __poke) then
		local parsed = packets.parse('incoming', data)
		if parsed then
			atcwarn('Packet 03C received - Shop opened.')
			__received_response = true
			__shop_opened = true
		end
	elseif (id == 0x38) and haveBuff('Voidwatcher') then
        local parsed = packets.parse('incoming', data)
        local mob = windower.ffxi.get_mob_by_id(parsed['Mob'])
        if not mob then elseif (mob.name == 'Riftworn Pyxis') then
            if parsed['Type'] == 'deru' then
                atc('[VW] Riftworn Pyxis spawn')
				off()
            end
        end
	end
end

function handle_statue_change(new, old)
	local target = windower.ffxi.get_mob_by_target('t')
    if not target or target then
        if new == 4 and __busy then
            __npc_dialog = true
        elseif old == 4 then
            __npc_dialog = false
        end
    end
	if new == 33 then	-- resting
		isResting = true
	elseif new == 00 then	-- idle
		isResting = false
	end
end

function handle_outgoing_chunk(id, original)
	if id == 0x05b then
		local parsed = packets.parse('outgoing', original)
		if parsed then
			__get_packet_sequence = {}
			__get_menu_id = 0
			__get_npc_name = ''
			__busy = parsed['Automated Message']
			__poke = parsed['Automated Message']
		end
	end
end

function handle_gain_buff(buff_id)
	if buff_id == 254 then
		if __htmb_state then
			__htmb_entered = true
			atc('[HTMB] IPC Trigger.')
			send_to_IPC:schedule(1.0, 'htmb',__player_leader)
		elseif __orb_state and __orb_type then
			__orb_entered = true
			if __macro_orb_type then
				atc('[Macro Orb] IPC Trigger. Lead: '..__player_leader)
				send_to_IPC:schedule(1.0, 'macro',__player_leader)
			elseif __deimos_orb_type then
				atc('[Deimos Orb] IPC Trigger. Lead: '..__player_leader)
				send_to_IPC:schedule(1.0, 'deimos',__player_leader)
			end
		end
	elseif buff_id == 475 then
		atc('[VW]')
		on()
    end
end

function handle_lose_buff(buff_id)
	if buff_id == 254 then
		__htmb_state = false
		__htmb_entered = false
		__orb_state = false
		__orb_entered = false
		__macro_orb_type = false
		__deimos_orb_type = false
		__orb_type = ''
		__player_leader = ''
		off:schedule(3)
    end
end

function poke(mob_index)
    atcwarn("[POKE] - Attempt to poke NPC")
	__get_npc_name = windower.ffxi.get_mob_by_index(mob_index) and windower.ffxi.get_mob_by_index(mob_index).name or nil
    if not mob_index or not __get_npc_name then
		return
		atcwarn("[POKE] - Abort, no valid target.")
	else
		__busy = true
		__poke = true
		get_poke_check_index(mob_index)	
	end
	finish_interaction()
end

pokesingle = poke

function sell(mob_index)
	atcwarn("[SELL] - Attempt to poke NPC to sell junk.")
    __get_npc_name = windower.ffxi.get_mob_by_index(mob_index) and windower.ffxi.get_mob_by_index(mob_index).name or nil
    if not mob_index or not __get_npc_name then
		return
		atcwarn("[SELL] - Abort, no valid target.")
	else
		windower.send_command('sellnpc junk')
		coroutine.sleep(1.5)
		__busy = true
		__poke = true
		get_poke_check_index(mob_index)
	end
	finish_interaction()
end

local function pre_check(map_type)
	if map_type == 'get' and not (get_map[zone_id]) then
		atcwarn('[GET] Not in an listed zone, cancelling.')
		finish_interaction()
		return false
	elseif map_type == 'enter' and not (npc_map[zone_id]) then
		atcwarn('[ENTER] Not in an listed zone, cancelling.')
		finish_interaction()
		return false
	elseif map_type == 'htmb' and not (htmb_map[zone_id]) then
		atcwarn('[HTMB] Not in an listed zone, cancelling.')
		finish_interaction()
		return false
	end
	
	if __busy then
		atcwarn('[GET KI] ABORT! Currently interacting with some NPC')
		return false
	end
	
	if haveBuff('Invisible') then
		windower.send_command('cancel invisible')
		coroutine.sleep(1.5)
	end
	if haveBuff('Mounted') then
		windower.send_command('input /dismount')
		coroutine.sleep(1.5)
	end
	return true
end

function refillmeds()
	if not pre_check('get') then return end

	local category_curio = S{'meds','scrolls','foods'}
	
	for our_categories,_ in pairs (category_curio) do
		local possible_npc = find_npc_to_poke("get")
		local get_command = (possible_npc and get_map[zone_id].name[possible_npc.name].cmd[our_categories]) or nil
		if possible_npc and get_command then
			if get_command.packet then
				atc("[REFILL MEDS] - "..get_command.description)
				__get_packet_sequence = get_command.packet[1]
				__get_menu_id = get_command.menu_id
				__get_npc_name = possible_npc.name
				__shop_packet = true
				__busy = true
			end
			--Poke NPC
			if not get_poke_check_index(possible_npc.index) then
				finish_interaction()
			end
			coroutine.sleep(2.5)
			if __shop_opened then
				windower.send_command('setkey escape down; wait 0.25; setkey escape up;')
				coroutine.sleep(0.5)
				atc('[REFILL MEDS] - Cateogry: '..our_categories:capitalize())
				for k,v in pairs(get_map[zone_id].name[possible_npc.name]) do
					for _,med_table in pairs(v) do
						if med_table.category == our_categories then
							windower.send_command('get "' ..med_table.description.. '" 100')
							coroutine.sleep(1.2)
							local item_count = 0
							item_count = CheckItemInInventory(med_table.description, true, true)
							if item_count and item_count < med_table.count and med_table.category == our_categories then
								local amount_to_buy = med_table.count - item_count
								local free_space = count_inv()
								local total_space = math.ceil(amount_to_buy/12)

								if free_space < total_space then
									atcwarn("WARNING:  Not enough space, skipping - "..med_table.description)
								else
									atc(med_table.description.." - "..item_count.." <> Buying: "..amount_to_buy)
									if amount_to_buy > 12 then
										atc("TX: Buying in multiple transactions!")
										local small_count = 1
										for i = amount_to_buy, 1, -12 do
											if i > 12 then
												atc('TX: '..small_count..' - '..med_table.description..' <> Buying: 12')
												send_packet_shop(med_table.shop_packet_slot, 12)
											else
												atc('TX: '..small_count..' - '..med_table.description..' <> Buying: '..i)
												send_packet_shop(med_table.shop_packet_slot, i)
											end
											small_count = small_count +1
											coroutine.sleep(2.0)
										end
									else
										send_packet_shop(med_table.shop_packet_slot, amount_to_buy)
									end
								end
							else
								atcwarn('Skipping: '..med_table.description..' - Have: '..item_count)
							end
							coroutine.sleep(2.0)
							windower.send_command('put "' ..med_table.description.. '" sack 100')
							coroutine.sleep(1.2)
						end
					end
				end
				finish_interaction()
				atc("[REFILL MEDS] - Finish refilling all: "..our_categories:capitalize())
			else
				atcwarn("[REFILL MEDS] - Shop did not open!  0x03C was not received.")
				finish_interaction()
				return
			end
		else
			atcwarn("[REFILL MEDS] No NPC's nearby to poke, cancelling.")
			finish_interaction()
			return
		end
	end
	finish_interaction()
	atc("[REFILL MEDS] All actions complete.")
end

function get(cmd2,cmd3)
	local ki_count = 0
	local ki_max = 0
	if not pre_check('get') then return end
	
	local possible_npc = find_npc_to_poke("get")
	local get_command = (possible_npc and get_map[zone_id].name[possible_npc.name].cmd[cmd2]) or nil
	if possible_npc and get_command then
		if (get_command.packet) then	-- Packets
			ki_count = (get_command.ki_check and find_missing_ki(get_command.ki_check)) or 0
			ki_max = get_command.ki_max_num or 1
			if (ki_max-ki_count) > 0 then 
				atc("[GET KI Packet] - "..get_command.description)
				__get_packet_sequence = get_command.packet[ki_max-ki_count]
				__get_menu_id = get_command.menu_id
				__get_npc_name = possible_npc.name
				__busy = true
				if get_command.shop_packet_slot and cmd3 and tonumber(cmd3, 10) < 12 then
					__shop_packet = true
				end
				--Poke NPC
				if not get_poke_check_index(possible_npc.index) then
					finish_interaction()
				end
				--Curio command
				coroutine.sleep(2.0)
				if __shop_opened then
					atcwarn(get_command.description.." - Buying: "..cmd3)
					send_packet_shop(get_command.shop_packet_slot, tonumber(cmd3, 10))
				end
			else
				atcwarn("[GET Packet] - Abort! You already have maximum amount of "..get_command.description)
			end
		elseif (get_command.entry_command) then	-- KeyPress
			atc("[GET] - "..get_command.description)
			__busy = true
			__get_npc_name = possible_npc.name
			__get_keypress_sequence = get_command.entry_command
			if not get_poke_check_index(possible_npc.index) then
				finish_interaction()
				return
			end
		end
		finish_interaction()
	else
		atcwarn("[GET] No NPC's nearby to poke, cancelling.")
		finish_interaction()
	end
end

function enter(leader)
	if not pre_check('enter') then return end

	local possible_npc = find_npc_to_poke()
	if possible_npc then
		-- Name type
		if not(npc_map[zone_id].name[possible_npc.name].index) then
			local enter_command = npc_map[zone_id].name[possible_npc.name] or nil
			if (enter_command.packet) then	-- Packets
				atc("[ENTER Packet] - "..enter_command.description)
				__get_packet_sequence = enter_command.packet[1]
				__get_menu_id = enter_command.menu_id
				__get_npc_name = possible_npc.name
				__busy = true
				--Poke NPC
				if not get_poke_check_index(possible_npc.index) then
					finish_interaction()
				end
			else
				__busy = true
				__get_npc_name = possible_npc.name
				__get_keypress_sequence = npc_map[zone_id].name[possible_npc.name].entry_command
				if not get_poke_check_index(possible_npc.index) then
					finish_interaction()
				end
			end
		-- Index type
		else
			local enter_command = npc_map[zone_id].name[possible_npc.name].index[possible_npc.index] or nil
			if (enter_command.packet) then	-- Packets
				atc("[ENTER Packet] - "..enter_command.description)
				__get_packet_sequence = enter_command.packet[1]
				__get_menu_id = enter_command.menu_id
				__get_npc_name = possible_npc.name
				__busy = true
				--Poke NPC
				if not get_poke_check_index(possible_npc.index) then
					finish_interaction()
				end
			else
				__busy = true
				__get_npc_name = possible_npc.name
				__get_keypress_sequence = npc_map[zone_id].name[possible_npc.name].index[possible_npc.index].entry_command
				if not get_poke_check_index(possible_npc.index) then
					finish_interaction()
				end
			end
		end
		finish_interaction()
	else
		atcwarn("[ENTER] No NPC's nearby to poke, cancelling.")
		finish_interaction()
	end	
end

function orb_entry(leader, __orb_type)
	if __orb_type and ((__orb_type == 'macro' and not (macro_orb_map[zone_id])) or (__orb_type == 'deimos' and not (deimos_orb_map[zone_id]))) then
		atcwarn('[ORB_ENTRY] Not in '..(__orb_type:gsub("^%l", string.upper))..' Orb zone, cancelling.')
		return
	end
	
	if (leader == player.name and not __orb_entered) or (leader ~= player.name and haveBuff('Battlefield')) then
	local possible_npc = find_npc_to_poke(__orb_type)
		if leader == player.name and not __orb_state then
			if possible_npc then
				__busy = true
				__get_npc_name = possible_npc.name
				if not trade_orb(possible_npc.index, __orb_type) then
					finish_orb_htmb_interaction()
				else
					if __orb_type == 'macro' then
						__macro_orb_type = true
						keypress_cmd(macro_orb_map[zone_id].entry_command)
					elseif __orb_type == 'deimos' then
						__deimos_orb_type = true
						keypress_cmd(deimos_orb_map[zone_id].entry_command)
					end
					__orb_state=true
					__player_leader = player.name
				end
			end
		else
			if possible_npc then
				__busy = true
				__get_npc_name = possible_npc.name
				if not get_poke_check_index(possible_npc.index) then
					finish_orb_htmb_interaction()
				else
					if __orb_type == 'macro' then
						keypress_cmd(macro_orb_map[zone_id].follower_command)
					elseif __orb_type == 'deimos' then
						keypress_cmd(deimos_orb_map[zone_id].follower_command)
					end
				end
			end
		end
	end
	finish_interaction()
end

function htmb(leader)
	if not pre_check('htmb') then return end
	
	if (leader == player.name and not __htmb_entered) or (leader ~= player.name and haveBuff('Battlefield')) then
		local possible_npc = find_npc_to_poke("htmb")
		if possible_npc then
			__busy = true
			__get_npc_name = possible_npc.name
			__get_keypress_sequence = htmb_map[zone_id].entry_command
			if not get_poke_check_index(possible_npc.index) then
				finish_orb_htmb_interaction()
			else
				if leader == player.name and not __htmb_state then		
					__htmb_state=true
				end
			end
		end
	end
	finish_interaction()
end

function keypress_cmd(key_table)
	local keypress_string = ''
	for _,press in ipairs(key_table) do
		if type(press)=='table'then
			keypress_string = keypress_string ..'setkey '..press[1]..' down; wait '..press[2]..'; setkey '..press[1]..' up; '
		else
			keypress_string = keypress_string ..'wait '..press..'; '
		end
	end
	windower.send_command(keypress_string)
end

function basic_keys(cmd)
	atc('[KeyPress] Sending -'..cmd:upper()..'- key sequence.')
	keypress_cmd(basic_key_sequence[cmd].command)
end

function finish_interaction()
	__get_keypress_sequence = {}
	__get_packet_sequence = {}
	__get_menu_id = 0
	__get_npc_name = ''
	__get_shop_item_count = 0
	__get_shop_slot = 0
	__shop_busy = false
	__shop_opened = false
	__shop_packet = false
	__busy = false
	__poke = false
	__received_response = false
	atcwarn('Finish interaction')
end

function finish_orb_htmb_interaction()
	__macro_orb_type = false
	__deimos_orb_type = false
	__htmb_state = false
	__htmb_entered = false
	__orb_type = ''
	__orb_state = false
	__orb_entered = false
	__player_leader = ''
end

function calc_lazy_distance(a,b)
    return (a.x-b.x)^2 + (a.y-b.y)^2
end

--Find NPC that's in list to poke
function find_npc_to_poke(npc_type)
	if npc_type == "htmb" then
		npc_list = htmb_map[zone_id] and htmb_map[zone_id].name
	elseif npc_type == "macro" then
		npc_list = macro_orb_map[zone_id] and macro_orb_map[zone_id].name
	elseif npc_type == "deimos" then
		npc_list = deimos_orb_map[zone_id] and deimos_orb_map[zone_id].name
	elseif npc_type == "get" then
		unformatted_npc_list = get_map[zone_id] and get_map[zone_id].name
		npc_list = {}
		if unformatted_npc_list then
			local index = 1
			for k,v in pairs(get_map[zone_id].name) do
			  npc_list[index] = k
			  index=index+1
			end
		end
	else
		unformatted_npc_list = npc_map[zone_id] and npc_map[zone_id].name
		npc_list = {}
		if unformatted_npc_list then
			local index = 1
			for k,v in pairs(npc_map[zone_id].name) do
			  npc_list[index] = k
			  index=index+1
			end
		end
	end
	    
    if not npc_list or #npc_list == 0 then
        return nil
    end
	local player_distance = windower.ffxi.get_mob_by_target('me')
	
    npcs = T(T(windower.ffxi.get_mob_list()):filter(table.contains+{npc_list}):keyset()):map(windower.ffxi.get_mob_by_index):filter(table.get-{'valid_target'})
	closest_npc = npcs:reduce(function(current, npc_of_interest)
		local npc_of_interest_dist = calc_lazy_distance(player_distance, npc_of_interest)
		local current_dist = calc_lazy_distance(player_distance, current)
		return npc_of_interest_dist < current_dist and npc_of_interest or current
	end)
    
	if closest_npc and calc_lazy_distance(player_distance, closest_npc) < 50^2 then
        return closest_npc
    end
end

local function distance_check_npc(npc)
    local player = windower.ffxi.get_mob_by_target('me')

    if npc and calc_lazy_distance(player, npc) < 6^2 then
		atc('[Dist Check] -Found-: ' ..npc.name.. ' [Distance]: ' .. math.floor(math.sqrt(npc.distance)*(10^2))/(10^2))
        return true
    else
        atcwarn('[Dist Check] -TOO FAR AWAY-: ' ..npc.name.. ' [Distance]: ' .. math.floor(math.sqrt(npc.distance)*(10^2))/(10^2))
        return false
    end
end

function trade_orb(npc_index, __orb_type)
	count = 0

	while __npc_dialog == false and count < 3 do
		count = count + 1
        npcstats = windower.ffxi.get_mob_by_index(npc_index)
		if npcstats and distance_check_npc(npcstats) and npcstats.valid_target then
			atc('Trade #: ' ..count.. ' [NPC: ' .. npcstats.name.. ' ID: ' .. npcstats.id.. ']')
			if __orb_type == 'macro' then
				windower.send_command('tradenpc 1 "macrocosmic orb" "'..npcstats.name..'"')
			elseif __orb_type == 'deimos' then
				windower.send_command('tradenpc 1 "deimos orb" "'..npcstats.name..'"')
			end
		end
		coroutine.sleep(3.0)
	end
	return __npc_dialog
end

function get_poke_check_index(npc_index)
	count = 0
	while __received_response == false and count < 3 do
		count = count + 1
		npcstats = windower.ffxi.get_mob_by_index(npc_index)
		if not npcstats then
			atcwarn('[POKE]: Abort! NPC Target is beyond 50 yalms in current zone.')
			return false
		end
		if npcstats and distance_check_npc(npcstats) and npcstats.valid_target then
			atc('Poke #: ' ..count.. ' [NPC: ' .. npcstats.name.. ' ID: ' .. npcstats.id.. ']')
			poke_npc(npcstats.id,npcstats.index)
		end
		coroutine.sleep(3.0)
	end
	return __received_response
end

function poke_npc(npc,target_index)
	if npc and target_index then
		local packet = packets.new('outgoing', 0x01A, {
			["Target"]=npc,
			["Target Index"]=target_index,
			["Category"]=0,
			["Param"]=0,
			["_unknown1"]=0})
		packets.inject(packet)
	end
end

function send_packet(parsed, options, delay)
	local delay = (delay or 0)

	if parsed and options and type(options) == 'table' then
		coroutine.schedule(function()

			for option, index in T(options):it() do
				local option = T(option)

				coroutine.schedule(function()
					packets.inject(packets.new('outgoing', 0x05b, {
						['Menu ID']             = parsed['Menu ID'],
						['Zone']                = parsed['Zone'],
						['Target Index']        = parsed['NPC Index'],
						['Target']              = parsed['NPC'],
						['Option Index']        = option[1],
						['_unknown1']           = option[2],
						['_unknown2']           = option[3],
						['Automated Message']   = option[4]
					}))
				end, (index * 0.25))
			end
		end, delay)
	end
end

function send_packet_shop(shop_slot, item_count)
	if shop_slot and item_count then
		packets.inject(packets.new('outgoing', 0x083, {
			['Count']             	= item_count,
			['_unknown2']           = 0,
			['Shop Slot']        	= shop_slot,
			['_unknown3']        	= 0,
			['_unknown4']           = 0,
		}))
	end
end

windower.register_event('incoming chunk', handle_incoming_chunk)
windower.register_event('outgoing chunk', handle_outgoing_chunk)
windower.register_event("gain buff", handle_gain_buff)
windower.register_event("lose buff", handle_lose_buff)
windower.register_event('status change', handle_statue_change)