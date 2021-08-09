_addon.name = 'Multictrl'
_addon.author = 'Kate'
_addon.version = '1.5.3.1'
_addon.commands = {'multi','mc'}

require('functions')
require('logger')
require('tables')
config = require('config')
packets = require('packets')
require('coroutine')
res = require('resources')
texts = require('texts')

default = {

	avatar='ramuh',
	indi='refresh',
	dia=true,
	active=false,
	assist='',
	smnhelp=false,
	smnsc=false,
	buy=false,
	autows=false,
	rangedmode=false,
	send_all_delay = 0.83,
	antisleep=true,
	autofood=false,
	rngsc=false,
}

jobnames = {
	[0] = {job="WHM",name=""},
    [1] = {job="RDM",name=""},
	[2] = {job="BRD",name=""},

}

InternalCMDS = S{
	'on','off','night','wake','foff',
	'mnt','dis','reload','unload','fin',
	'lotall','buff',
	'fight','fightmage','fightsmall','ws','food','sleep','rng','trib','rads','buyalltemps',
	'warp','omen','domain','wsall','cc','getjobs','remdrop'}

DelayCMDS = S{'trib','rads','buyalltemps','getjobs'}
	
isCasting = false
ipcflag = false
currentPC=windower.ffxi.get_player()
new = 0
old = 0

windower.register_event('status change', function(a, b)
	new = a
	old = b
end)

windower.register_event('incoming chunk', function(id, data)
    if id == 0x028 then
        local action_message = packets.parse('incoming', data)
		if action_message["Category"] == 4 then
			isCasting = false
		elseif action_message["Category"] == 8 then
			isCasting = true
		end
	end
end)

windower.register_event('addon command', function(input, ...)
	local cmd
    if input ~= nil then
		cmd = string.lower(input)	
	end

	local args = {...}
	local cmd2 = args[1]
	local cmd3 = args[2]
	local cmd4 = args[3]
	
	local term = table.concat({...}, ' ')

    term = term:gsub('<(%a+)id>', function(target_string)
        local entity = windower.ffxi.get_mob_by_target(target_string)
        return entity and entity.id or '<' .. target_string .. 'id>'
    end)

	if cmd == nil then
		windower.add_to_chat(123,"Abort: No command specified")

	-- Move these to addon?
		elseif cmd == 'runic' then
			runic()
		elseif cmd == 'done' then
			done()
		elseif cmd == 'tag' then
			tag()
		elseif cmd == 'ein' then
			ein(cmd2)
		elseif cmd == 'htmb' then
			htmb(cmd2)
		elseif cmd == 'go' then
			go()
		elseif cmd == 'enter' then
			enter()
		elseif cmd == 'srr' then
			srr()
		elseif cmd == 'srrget' then
			srrget()
		elseif cmd == 'endown' then
			endown()
		elseif cmd == 'enup' then
			enup()
		elseif cmd == 'esc' then
			esc()
		elseif cmd == 'zerg' then
			zerg(cmd2)
			
			elseif cmd == 'buffall' then
				buffall(cmd2)
			elseif cmd == 'haste' then
				haste()
			elseif cmd == 'proc' then
				proc(cmd2)
			elseif cmd == 'wstype' then
				wstype(cmd2)

	elseif cmd == '30' then
		cmd2 = '30'
		fps(cmd2)
	elseif cmd == '60' then
		cmd2 = '60'
		fps(cmd2)
	elseif cmd == 'd2' then
		d2()
	elseif cmd == 'buyshields' then
		buyshields()
	elseif cmd == 'fon' then
		fon(cmd2)
	elseif cmd == 'buy' then
		buy(cmd2)
	elseif cmd == 'assist' then
		assist(cmd2,cmd3)
	elseif cmd == 'burn' then
		burnset(cmd2,cmd3,cmd4)
	elseif cmd == 'smnburn' then
		smnburn()
	elseif cmd == 'geoburn' then
		geoburn()
	elseif cmd == 'smnhelp' then
		smnhelp(cmd2)
	elseif cmd == 'rngsc' then
		rngsc(cmd2)
	elseif cmd == 'stage' then
		stage(cmd2)
	elseif cmd == 'send' then
		send(term)
	elseif cmd == 'gettarget' then
		gettarget(term)
	elseif InternalCMDS:contains(cmd) then
		send_int_cmd(cmd,cmd2)
	end

end)


function send_int_cmd(cmd,cmd2)
	-- Single command functions
	if cmd2 == nil then
		log('Function: ' .. cmd)
		loadstring(cmd.."()")()
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message(cmd)
		end
		ipcflag = false
	-- 2 commands function
	else
		log('Function - 2 ARGS: ' .. cmd)
		_G[cmd](cmd2)
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message(cmd .. ' ' .. cmd2)
		end
		ipcflag = false
	
	end

end

-- Display functions

function init_box_pos()

	if burn_status then burn_status:destroy() end
	if smn_help then smn_help:destroy() end
	if buy_help then buy_help:destroy() end
	if ws_help then ws_help:destroy() end
	if rng_help then rng_help:destroy() end
	if rng_sc then rng_sc:destroy() end
	if sleep_help then sleep_help:destroy() end
	if food_help then food_help:destroy() end

	local settings = windower.get_windower_settings()
	local x,y
	local sx,sy
	local bx,by
	local wx,wy
	local rx,ry
	local slx,sly
	local fx,fy
	local rngx,rngy
	
	--if settings["ui_x_res"] == 1920 and settings["ui_y_res"] == 1080 then
		--x,y = settings["ui_x_res"]-1917, settings["ui_y_res"]-18 -- -285, -18
	--else
	x,y = settings["ui_x_res"]-510, 95 -- -285, -18
	--end
	sx,sy = settings["ui_x_res"]-625, 45
	
	bx,by = settings["ui_x_res"]-510, 85
	
	wx,wy = settings["ui_x_res"]-510, 45
	
	rx,ry = settings["ui_x_res"]-510, 65
	
	slx,sly = settings["ui_x_res"]-510, 25
	
	fx,fy = settings["ui_x_res"]-625, 25
	
	rngx,rngy = settings["ui_x_res"]-675, 25

	local font = displayfont or 'Arial'
	local size = displaysize or 11
	local bold = displaybold or true
	local bg = displaybg or 0
	local strokewidth = displaystroke or 2
	local stroketransparancy = displaytransparancy or 192
	
	smn_help = texts.new()
	smn_help:pos(sx,sy)
    smn_help:font(font)--Arial
    smn_help:size(size)
    smn_help:bold(bold)
    smn_help:bg_alpha(bg)--128
    smn_help:right_justified(false)
    smn_help:stroke_width(strokewidth)
    smn_help:stroke_transparency(stroketransparancy)
	
	buy_help = texts.new()
	buy_help:pos(bx,by)
    buy_help:font(font)--Arial
    buy_help:size(size)
    buy_help:bold(bold)
    buy_help:bg_alpha(bg)--128
    buy_help:right_justified(false)
    buy_help:stroke_width(strokewidth)
    buy_help:stroke_transparency(stroketransparancy)
	
    burn_status = texts.new()
    burn_status:pos(x,y)
    burn_status:font(font)--Arial
    burn_status:size(size)
    burn_status:bold(bold)
    burn_status:bg_alpha(bg)--128
    burn_status:right_justified(false)
    burn_status:stroke_width(strokewidth)
    burn_status:stroke_transparency(stroketransparancy)
	
	ws_help = texts.new()
	ws_help:pos(wx,wy)
    ws_help:font(font)--Arial
    ws_help:size(size)
    ws_help:bold(bold)
    ws_help:bg_alpha(bg)--128
    ws_help:right_justified(false)
    ws_help:stroke_width(strokewidth)
    ws_help:stroke_transparency(stroketransparancy)
	
	sleep_help = texts.new()
	sleep_help:pos(slx,sly)
    sleep_help:font(font)--Arial
    sleep_help:size(size)
    sleep_help:bold(bold)
    sleep_help:bg_alpha(bg)--128
    sleep_help:right_justified(false)
    sleep_help:stroke_width(strokewidth)
    sleep_help:stroke_transparency(stroketransparancy)
	
	food_help = texts.new()
	food_help:pos(fx,fy)
    food_help:font(font)--Arial
    food_help:size(size)
    food_help:bold(bold)
    food_help:bg_alpha(bg)--128
    food_help:right_justified(false)
    food_help:stroke_width(strokewidth)
    food_help:stroke_transparency(stroketransparancy)
	
	rng_help = texts.new()
	rng_help:pos(rx,ry)
    rng_help:font(font)--Arial
    rng_help:size(size)
    rng_help:bold(bold)
    rng_help:bg_alpha(bg)--128
    rng_help:right_justified(false)
    rng_help:stroke_width(strokewidth)
    rng_help:stroke_transparency(stroketransparancy)
	
	rng_sc = texts.new()
	rng_sc:pos(rx,ry)
    rng_sc:font(font)--Arial
    rng_sc:size(size)
    rng_sc:bold(bold)
    rng_sc:bg_alpha(bg)--128
    rng_sc:right_justified(false)
    rng_sc:stroke_width(strokewidth)
    rng_sc:stroke_transparency(stroketransparancy)
	

	burn_status:pos(x,y)
	
	rng_sc:pos(rngx,rngy)
	smn_help:pos(sx,sy)
	buy_help:pos(bx,by)
	ws_help:pos(wx,wy)
	rng_help:pos(rx,ry)
	sleep_help:pos(slx,sly)
	food_help:pos(fx,fy)
	
	display_box()
	--burn_status:show()
end

display_box = function()
    local str
	local clr = {
		r='\\cs(240,28,28)', -- Red for active
        h='\\cs(255,192,0)', -- Yellow for active booleans and non-default modals
		w='\\cs(255,255,255)', -- White for labels and default modals
        n='\\cs(192,192,192)', -- White for labels and default modals
        s='\\cs(96,96,96)' -- Gray for inactive booleans
    }
	burn_status:clear()
	burn_status:append(' ')
	
	smn_help:clear()
	smn_help:append(' ')
	
	buy_help:clear()
	buy_help:append(' ')
	
	ws_help:clear()
	ws_help:append(' ')
	
	sleep_help:clear()
	sleep_help:append(' ')
	
	rng_help:clear()
	rng_help:append(' ')
	
	rng_sc:clear()
	rng_sc:append(' ')
	
	food_help:clear()
	food_help:append(' ')
	

	if settings.smnhelp then
		if settings.smnsc then
			smn_help:append(string.format("%sSMN: %sON - SC", clr.w, clr.r))
		else
			smn_help:append(string.format("%sSMN: %sON", clr.w, clr.r))
		end 
	else
		smn_help:clear()
	end
	
	if settings.autows then
		ws_help:append(string.format("%sWS/BUFF: %sON", clr.w, clr.r))
	else
		ws_help:clear()
	end
	
	if settings.antisleep then
		sleep_help:append(string.format("%sAnti-Sleep: %sON", clr.w, clr.r))
	else
		sleep_help:clear()
	end
	
	if settings.autofood then
		food_help:append(string.format("%sAuto-Food: %sON", clr.w, clr.r))
	else
		food_help:clear()
	end
	
	if settings.rangedmode then
		rng_help:append(string.format("%sRNG: %sON", clr.w, clr.r))
	else
		rng_help:clear()
	end
	
	if settings.rngsc then
		rng_sc:append(string.format("%sRNG SC: %sON", clr.w, clr.r))
	else
		rng_sc:clear()
	end

	if settings.buy then
		buy_help:append(string.format("%sBUY HELPER: %sON", clr.w, clr.r))
	else
		buy_help:clear()
	end

    if settings.active then
		burn_status:append(string.format("%s1HR Burn: %sON", clr.w, clr.r))

		if settings.avatar == 'ramuh' then
			burn_status:append(string.format("\n%s Avatar: %s" .. settings.avatar, clr.w, clr.h))
			
		elseif settings.avatar == 'ifrit' then
			burn_status:append(string.format("\n%s Avatar: %s" .. settings.avatar, clr.w, clr.h))
			
		elseif settings.avatar == 'siren' then
			burn_status:append(string.format("\n%s Avatar: %s" .. settings.avatar, clr.w, clr.h))
		end
		
		
		if settings.dia then
			burn_status:append(string.format("\n%s DIA: %sON", clr.w, clr.r))
		else
			burn_status:append(string.format("\n%s DIA: %sOFF", clr.w, clr.w))
		end
		
		if settings.indi == 'torpor' then
			burn_status:append(string.format("\n%s Indi Spell: %s" .. settings.indi, clr.w, clr.h))
		elseif settings.indi == 'malaise' then
			burn_status:append(string.format("\n%s Indi Spell: %s" .. settings.indi, clr.w, clr.h))
		elseif settings.indi == 'refresh' then
			burn_status:append(string.format("\n%s Indi Spell: %s" .. settings.indi, clr.w, clr.h))
		end
		
		if settings.assist ~= nil then
			burn_status:append(string.format("\n%s Assiting: %s" .. settings.assist, clr.w, clr.h))
		else
			burn_status:append(string.format("\n%s Assiting: %s", clr.w))
		end
		
		
    else
		burn_status:clear()
		--burn_status:append(string.format("%s1HR Burn: %sOFF", clr.w, clr.w))
    end
	
	
	smn_help:show()
	buy_help:show()
	ws_help:show()
	sleep_help:show()
	food_help:show()
	rng_help:show()
	rng_sc:show()
	burn_status:show()
end

-- Sub functions

function getjobs()
	local j = windower.ffxi.get_player().main_job 
	j = j:upper()
	settings[j] = windower.ffxi.get_player().name
	settings:save()

end

function stage(cmd2)
	local player_job = windower.ffxi.get_player()
	local MeleeJobs = S{'WAR','SAM','DRG','DRK','NIN','MNK','COR','BLU','PUP','DNC','RUN','BRD','THF','RNG'}

	
	settings = settings.load('data/settings.xml')

	if cmd2 == 'ambustart' then
		windower.send_command('input /autotarget off')
		if player_job.main_job == 'DRK' or player_job.main_job == 'SAM' then
			windower.send_command('lua r autows; autows on; gs c set hybridmode DT; gaze ap on')
		elseif player_job.main_job == 'GEO' then
			windower.send_command('gs c autoindi barrier; gs c autogeo frailty; gs c autoentrust fury; gs c set castingmode DT; gs c set idlemode DT; hb debuff dia2')
		elseif player_job.main_job == 'BRD' then
			windower.send_command('sing pl melee; wait 1; sing n off; sing p on; sing debuff carnage elegy; sing debuffing on; gs c set idlemode DT')
		elseif player_job.main_job == 'WHM' then
			windower.send_command('hb f dist 19; hb buff <me> barthundra; hb disable erase; gs c set idlemode DT')
		elseif player_job.main_job == 'RUN' then
			windower.send_command('gs c set runeelement tellus; gs c set autobuffmode auto')
		end
		
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('stage ambustart')
		end
		ipcflag = false
	elseif cmd2 == 'ambusecond' then
		if player_job.main_job == 'GEO' then
			windower.send_command('gs c autoindi acumen; gs c autogeo refresh;')
		end
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('stage ambusecond')
		end
		ipcflag = false
	elseif cmd2 == 'ody' then
		windower.send_command('lua r gazecheck; /autotarget on')
		coroutine.sleep(2)
		if player_job.main_job == 'WHM' then
			windower.send_command('gs c set castingmode MEVA; gs c set idlemode DT; gaze ap off; hb buff ' .. settings.run .. ' haste; hb buff ' .. settings.sam .. ' haste; hb buff ' .. settings.run .. ' regen4')
		elseif player_job.main_job == 'RUN' then
			windower.send_command('gaze ap off')
		elseif player_job.main_job == 'BRD' then
			windower.send_command('gs c set idlemode DT; gaze ap off; sing pl melee; sing n off; sing p on; hb buff ' .. settings.drk .. ' haste; hb buff ' .. settings.cor .. ' haste;')
		elseif player_job.main_job == 'COR' then
			windower.send_command('roll melee; gaze ap on;')
			windower.send_command('gs c set hybridmode HybridDT')
		elseif player_job.main_job == 'SAM' or player_job.main_job == 'DRK' then
			windower.send_command('gs c set hybridmode DT; gaze ap on;')
		end
		
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('stage ody')
		end
		ipcflag = false
	elseif cmd2 == 'shin' then
		windower.send_command('lua r gazecheck;')
		coroutine.sleep(2)
		if player_job.main_job == 'WHM' then
			windower.send_command('gaze ap off; hb buff <me> barfira; gs c set castingmode MEVA; gs c set idlemode DT;')
		elseif player_job.main_job == 'RUN' then
			windower.send_command('gs c set runeelement lux; gs c set autobuffmode auto; gs c set hybridmode DTLite;')
		elseif player_job.main_job == 'BRD' then
			windower.send_command('gaze ap off; sing pl shin; sing n on; sing p on; gs c set idlemode DT;')
		elseif player_job.main_job == 'THF' then
			windower.send_command('gs c set hybridmode HybridMEVA; gs c set treasuremode fulltime; gs c set weapons TH;')
		elseif player_job.main_job == 'SAM' or player_job.main_job == 'DRK' then
			windower.send_command('gs c set hybridmode DT; gaze ap on;')
		elseif player_job.main_job == 'SCH' then
			windower.send_command('gs c set elementalmode light; gs c set castingmode MEVA; gs c set idlemode DT; hb enable cure; hb enable na;')
		end
		
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('stage shin')
		end
		ipcflag = false
	elseif cmd2 == 'kalunga' then
		windower.send_command('lua u gazecheck;')
		if player_job.main_job == 'WHM' then
			windower.send_command('hb buff <me> barfira; gs c set castingmode MEVA; gs c set idlemode DT; hb debuff dia2;')
			windower.send_command('input /p Haste melee/tank, Shell 5 Tank')
		elseif player_job.main_job == 'RUN' then
			windower.send_command('gs c set runeelement unda; gs c set autobuffmode auto; hb buff <me> barfire')
		elseif player_job.main_job == 'BRD' then
			windower.send_command('sing pl kalunga; sing n on; sing p on; gs c set idlemode DT; lua r react')
			windower.send_command('input /p Pianissimo songs on Tank')
		elseif player_job.main_job == 'GEO' then
			windower.send_command('gs c autoindi barrier; gs c autogeo fury; gs c autoentrust refresh; gs c set castingmode HybridDT; gs c set idlemode PDT;')
		elseif player_job.main_job == 'SAM' then
			windower.send_command('gs c set hybridmode DT; gs c set weaponskillmode Emnity')
		elseif player_job.main_job == 'COR' then
			windower.send_command('lua r gazecheck; wait 2; gaze ap off')
			windower.send_command('roll melee;')
			windower.send_command('gs c set hybridmode HybridMEVA; gs c set weapons Naegling;')
		end
		
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('stage kalunga')
		end
		ipcflag = false
	elseif cmd2 == 'bumba' then
		windower.send_command('lua r gazecheck; wait 2; gaze ap on')
		if player_job.main_job == 'WHM' then
			windower.send_command('hb buff <me> barblizzara; hb buff <me> barparalyzra; hb disable na; gs c set castingmode MEVA; gs c set idlemode DT; hb debuff dia2; hb as attack off')
			windower.send_command('input /p Haste melee')
		elseif player_job.main_job == 'WAR' or player_job.main_job == 'DRG' then
			windower.send_command('gs c set weapons Naegling; gs c set hybridmode DT;')
		elseif player_job.main_job == 'BRD' then
			windower.send_command('sing pl bumba; sing n on; sing p on; gs c set idlemode DT; gs c set hybridmode DT; gs c set weapons Naegling; gs c autows Savage Blade')
		elseif player_job.main_job == 'GEO' then
			windower.send_command('gs c autoindi haste; gs c autogeo fury; gs c autoentrust fend; gs c set castingmode DT; gs c set idlemode DT;')
		elseif player_job.main_job == 'COR' then
			windower.send_command('roll roll1 sam; roll roll2 fighter')
			windower.send_command('gs c set hybridmode HybridMEVA; gs c set weapons Naegling;')
		end
		
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('stage bumba')
		end
		ipcflag = false
	else
		log('nothing specified')
	end
	

end


function wsall()
	local player_job = windower.ffxi.get_player()
	local MeleeJobs = S{'WAR','SAM','DRG','DRK','NIN','MNK','COR','BLU','PUP','DNC','RUN','BRD','THF','RNG','PLD'}
	if MeleeJobs:contains(player_job.main_job) then
		
			if player_job.main_job == "SAM" then
				windower.send_command('input /ws \'Tachi: Fudo\' <t>')
			elseif player_job.main_job == "MNK" then
				windower.send_command('input /ws \'Howling Fist\' <t>')
			elseif player_job.main_job == "NIN" then
				windower.send_command('input /ws \'Blade: Metsu\' <t>')
			elseif player_job.main_job == "DRG" then
				windower.send_command('input /ws \'Stardiver\' <t>')
			elseif player_job.main_job == "DRK" then
				windower.send_command('input /ws \'Torcleaver\' <t>')
			elseif player_job.main_job == "WAR" then
				windower.send_command('input /ws \'Upheaval\' <t>')
			elseif player_job.main_job == "COR" then
				windower.send_command('input /ws \'Savage Blade\' <t>')
			elseif player_job.main_job == "RNG" then
				windower.send_command('input /ws \'Last Stand\' <t>')
			elseif player_job.main_job == "BLU" then
				windower.send_command('input /ws \'Savage Blade\' <t>')
			elseif player_job.main_job == "BRD" then
				windower.send_command('input /ws \'Rudra\'s Storm\' <t>')
			elseif player_job.main_job == "RUN" then
				windower.send_command('input /ws \'Dimidiation\' <t>')
			elseif player_job.main_job == "PLD" then
				windower.send_command('input /ws \'Savage Blade\' <t>')
			elseif player_job.main_job == "THF" then
				windower.send_command('input /ws \'Rudra\'s Storm\' <t>')
			elseif player_job.main_job == "DNC" then
				windower.send_command('input /ws \'Rudra\'s Storm\' <t>')
			elseif player_job.main_job == "PUP" then
				windower.send_command('input /ws \'Howling Fist\' <t>')
			end
		
	end
end

function cc()
	local player_job = windower.ffxi.get_player()
	local SleepJobs = S{'BRD','BLM','RDM','GEO'}
	local SleepSubs = S{'BLM','RDM'}
	if SleepJobs:contains(player_job.main_job) then
		
			if player_job.main_job == "BRD" then
				windower.send_command('input /ma \'Horde Lullaby II\' <t>')
			elseif player_job.main_job == "BLM" then
				windower.send_command('input /ma \'Sleepga II\' <t>')
			elseif player_job.main_job == "RDM" then
				if player_job.sub_job == "BLM" then
					windower.send_command('input /ma \'Sleepga\' <t>')
				end
			elseif player_job.main_job == "GEO" then
				if player_job.sub_job == "BLM" then
					windower.send_command('input /ma \'Sleepga\' <t>')
				end
			end
		
	end
end

function mnt()
	--windower.send_command('input /mount \'Red Crab\'')
	windower.send_command('input /mount \'Crab\'')
end

function dis()
	windower.send_command('input /dismount')
end

function on()
	log('Turning on addon stuff...')
	local zone = windower.ffxi.get_info()['zone']
	local di_zones = S{288,289,291}

	if di_zones:contains(zone) then
		log('Domain Invasion zone, removing mobilization')
		windower.send_command('cancel mobilization')
	end
	local player_job = windower.ffxi.get_player()
	local MeleeJobs = S{'WAR','SAM','DRG','DRK','NIN','MNK','COR','BLU','PUP','DNC','RUN','BRD','THF','RNG','PLD'}
	if player_job.main_job == "GEO" then
		windower.send_command('geo on')
		windower.send_command('gs c set autobuffmode auto')
	elseif player_job.main_job == "WHM" then
		windower.send_command('gs c set autobuffmode auto')
	elseif player_job.main_job == "RUN" then
		windower.send_command('gs c set autorunemode on')
	elseif player_job.main_job == "BRD" then
		windower.send_command('singer on')
		windower.send_command('gs c set autobuffmode auto')
	elseif player_job.main_job == "COR" then
		windower.send_command('roller on')
	elseif player_job.main_job == "SCH" then
		windower.send_command('gs c set autosubmode on')
	elseif player_job.main_job == "RDM" then
		windower.send_command('gs c set autoarts on')
		windower.send_command('input /ja composure <me>')
	elseif player_job.main_job == "DNC" then
		windower.send_command('gs c set autosambamode on')
		--windower.send_command('gs c set autobuffmode auto')
	end
	
	-- SCH sub toggles
	if player_job.sub_job == "SCH" then
		if player_job.main_job ~= "RDM" then
			if settings.antisleep == true then
				windower.send_command('gs c set autosubmode sleep')
			elseif settings.antisleep == false then
				windower.send_command('gs c set autosubmode on')
			end
		end
	end
	
	-- WS/Buff mode
	if MeleeJobs:contains(player_job.main_job) then
		if settings.autofood then
			windower.send_command('gs c set autofoodmode on;')
		end
		if settings.autows then
			windower.send_command('gs c set autowsmode on;')
			if player_job.main_job == "DRG" or player_job.sub_job == "DRG" then
				windower.send_command('gs c set autojumpmode on;')
				windower.send_command('gs c set autobuffmode auto;')
			else
				windower.send_command('gs c set autobuffmode auto;')
			end
		end
		if settings.rangedmode then
			if player_job.main_job == "COR" or player_job.main_job == "RNG" then
				windower.send_command('gs c set rnghelper on;')
			end
		end
	end
	windower.send_command('hb on')

end

function off()
	log('Turning off addon stuff...')
	local player_job = windower.ffxi.get_player()
	if player_job.main_job == "GEO" then
		windower.send_command('geo off')
	elseif player_job.main_job == "RUN" then
		windower.send_command('gs c set autorunemode off')
		windower.send_command('gs c set autotankmode off')
	elseif player_job.main_job == "DRG" then
		windower.send_command('gs c set autojumpmode off')
	elseif player_job.main_job == "RNG" or player_job.main_job == "COR" then
		windower.send_command('gs c set rnghelper off')
	elseif player_job.main_job == "RDM" then
		windower.send_command('gs c set autoarts off')
	elseif player_job.main_job == "WHM" then
		windower.send_command('gs c set autosubmode off')
	end
	windower.send_command('hb off')
	windower.send_command('roller off')
	windower.send_command('singer off')
	windower.send_command('gs c set autowsmode off;')
	windower.send_command('gs c set autobuffmode off;')
	windower.send_command('gs c set autonukemode off;')
	windower.send_command('gs c set autotankmode off')
	windower.send_command('gs c set autosambamode off')
	windower.send_command('gs c set autozergmode off')
end

function fon()
	log('Follow ON')
	currentPC=windower.ffxi.get_player()
	
		windower.send_command('hb follow off')
		windower.send_command('hb f dist 2')
	
		for k, v in pairs(windower.ffxi.get_party()) do
			
				if type(v) == 'table' then
					if v.name ~= currentPC.name then
					
					--coroutine.sleep(1)
					
						ptymember = windower.ffxi.get_mob_by_name(v.name)
						-- check if party member in same zone.

						if v.mob == nil then
							-- Not in zone.
							log(v.name .. ' is not in zone, not following.')
							--windower.send_command('send ' .. v.name .. ' hb follow off')
							--windower.send_command('send ' .. v.name .. ' hb f dist 3')
						else
							windower.send_command('send ' .. v.name .. ' hb f dist 2')
							windower.send_command('send ' .. v.name .. ' hb follow ' .. currentPC.name)
						end
					end
				end
		end
end

function foff()
	log('Follow OFF')
	windower.send_command('hb follow off')
end

function unload(addonarg)
	log('Unloading Specific ADDON.')
	windower.send_command('lua u ' ..addonarg)
end

function reload(addonarg)
	log('Reload Specific ADDON.')
	if addonarg == 'multictrl' then
		log('Not supported!')
	else
		windower.send_command('lua r ' ..addonarg)
	end
end

function fin()
	log('Dispel/Finale')
	local player_job = windower.ffxi.get_player()
	if player_job.main_job == "BRD" then
		windower.send_command('fin <t>')
	elseif player_job.main_job == "RDM" or player_job.sub_job == "RDM" then
		windower.send_command('dis <t>')
	end
end

function lotall()
	windower.send_command('tr lotall;')
end

function ws(cmd2)
	if cmd2 == 'off' then
		log('AutoWS DISABLED')
		settings.autows = false
	elseif cmd2 == 'on' then
		log('AutoWS ACTIVE')
		settings.autows = true
	end
	display_box()
end

function sleep(cmd2)
	if cmd2 == 'off' then
		log('AntiSleep DISABLED')
		settings.antisleep = false
	elseif cmd2 == 'on' then
		log('AntiSleep ACTIVE')
		settings.antisleep = true
	end
	display_box()
end

function food(cmd2)
	if cmd2 == 'off' then
		log('AutoFood DISABLED')
		settings.autofood = false
	elseif cmd2 == 'on' then
		log('Autofood ACTIVE')
		settings.autofood = true
	end
	display_box()
end

function rng(cmd2)
	if cmd2 == 'off' then
		log('RNG Helper DISABLED')
		settings.rangedmode = false
	elseif cmd2 == 'on' then
		log('RNG Helper ACTIVE')
		settings.rangedmode = true
	end
	display_box()
end


function night()
	windower.send_command('lua u gearswap; wait 1.0; lua u healbot; wait 1.0; config FrameRateDivisor 2')	
end

function wake()
	windower.send_command('lua r healbot; wait 3.0; lua r gearswap;')	
end

function buy(cmd2)

	if cmd2 == 'on' then
		log('Turning on BUY function, loading addons')
		settings.buy = true
		windower.send_command('lua r powder; wait 1; lua r sparks; wait 1; lua r sellnpc')
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('buy on')
		end
		ipcflag = false
	elseif cmd2 == 'off' then
		log('Shutting off BUY function, unloading addons')
		settings.buy = false
		windower.send_command('lua u powder; wait 1; lua u sparks; wait 1; lua u sellnpc')
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('buy off')
		end
		ipcflag = false
	end
	
	if settings.buy then
	-- ACTIVE
		if (cmd2 == 'shield') then
			log('Buying SINGLE CHAR SHIELD!')
			--coroutine.sleep(5)
			windower.send_command('sparks buyall acheron shield')		
		elseif (cmd2 == 'powder' and settings.buy == true) then
			log('Buying powders!')
			windower.send_command('powder buy 3315')
			if ipcflag == false then
				ipcflag = true
				windower.send_ipc_message('buy powder')
			end
			ipcflag = false
		elseif (cmd2 == 'ss' and settings.buy == true) then
			windower.send_command('sellnpc s')
			local targetid = windower.ffxi.get_mob_by_name('Corua')
			
			windower.send_command('settarget ' .. targetid.id)
			coroutine.sleep(1)
			windower.send_command('input /lockon; wait 1; setkey enter down; wait 0.5; setkey enter up;')
			if ipcflag == false then
				ipcflag = true
				windower.send_ipc_message('buy ss')
			end
			ipcflag = false
		elseif (cmd2 == 'sp' and settings.buy == true) then
			windower.send_command('sellnpc p')
			local targetid = windower.ffxi.get_mob_by_name('Corua')
			
			windower.send_command('settarget ' .. targetid.id)
			coroutine.sleep(1)
			windower.send_command('input /lockon; wait 1; setkey enter down; wait 0.5; setkey enter up;')
			if ipcflag == false then
				ipcflag = true
				windower.send_ipc_message('buy sp')
			end
			ipcflag = false	
		elseif (cmd2 == 're' and settings.buy == true) then
			windower.send_command('buy re')
			
			windower.send_command('lua r sparks; wait 0.5; lua r powder')

			if ipcflag == false then
				ipcflag = true
				windower.send_ipc_message('buy re')
			end
			ipcflag = false	
		
		end
	
	end
	
	display_box()
end

function buff()
	log('Buffing Up!')
	local player_job = windower.ffxi.get_player()
	local buff_jobs = S{"WHM","RDM","GEO","BRD","SMN","BLM","SCH","RUN"}
	if buff_jobs:contains(player_job.main_job) then
		windower.send_command('gs c buffup')
	end
end

function gettarget(term)
	if (term ~= nil) then
		local targetid = windower.ffxi.get_mob_by_name('' .. term .. '')
		log('Get Target: ' .. term .. ' ID: ' .. targetid.id)
		windower.send_command('settarget ' .. targetid.id)
	else
		log('No target specified!')
	end
end

function fight()
	log('Fight distance.')
	local player_job = windower.ffxi.get_player()
	if player_job.main_job == "WHM" then
		windower.send_command('hb f dist 18;')
	elseif player_job.main_job == "GEO" or player_job.main_job == "BRD" then
		windower.send_command('hb f dist 2')
	elseif player_job.main_job == "SMN" or player_job.main_job == "BLM" or player_job.main_job == "SCH" or player_job.main_job == "RDM" then
		windower.send_command('hb f dist 19')
	else
		windower.send_command('hb f dist 1.7')
	end
end

function fightmage()
	log('Fight MAGE distance.')
	local player_job = windower.ffxi.get_player()
	local mage_jobs = S{"WHM","RDM","GEO","BRD","SMN","BLM","SCH","COR"}
	
	if mage_jobs:contains(player_job.main_job) then
		windower.send_command('hb f dist 19.5;')
	else
		windower.send_command('hb f dist 3.5')
	end
end

function fightsmall()
	log('Close quarters fight distnace.')
	local player_job = windower.ffxi.get_player()
	if player_job.main_job == "WHM" then
		windower.send_command('hb f dist 7')
	elseif player_job.main_job == "GEO" or player_job.main_job == "BRD" then
		windower.send_command('hb f dist 5')
	else
		windower.send_command('hb f dist 3')
	end
end

function send(commands)
	if ipcflag == false then
		log('Sending all chars: \"' .. commands .. '\"')
		ipcflag = true
		windower.send_command(commands)
		windower.send_ipc_message('send ' .. commands)
	elseif ipcflag == true then
		windower.send_command(commands)
	end
	ipcflag = false
end

function fps(cmd2)

	if cmd2 == "30" then
		log('FPS is 30')
		windower.send_command('config FrameRateDivisor 2')
	elseif cmd2 == "60" then
		log('FPS is 60')
		windower.send_command('config FrameRateDivisor 1')
	end
	if ipcflag == false and cmd2 == "30" then
		ipcflag = true
		windower.send_ipc_message('fps ' .. cmd2)
	end
	ipcflag = false
	
end

function assist(cmd,namearg)

	currentPC=windower.ffxi.get_player()
	if cmd == 'melee' then
	
		if ipcflag == false then
			log('Setting current character as leader!')
			ipcflag = true
			windower.send_command('hb assist off')
			windower.send_command('hb assist attack off')
			windower.send_ipc_message('assist melee ' .. currentPC.name)
		elseif ipcflag == true then
			local player_job = windower.ffxi.get_player()
			local MeleeJobs = S{'WAR','SAM','DRG','DRK','NIN','MNK','COR','BLU','PUP','DNC','RUN','THF'}		
			if MeleeJobs:contains(player_job.main_job) then
				log('Assist & Attack -> ' ..namearg)
				windower.send_command('hb assist ' .. namearg)
				windower.send_command('hb f ' .. namearg)
				windower.send_command('wait 0.5; hb assist attack on')
				windower.send_command('wait 0.5; hb on')
			else
				log('Disabling assist, not melee job.')
				windower.send_command('hb assist off')
				windower.send_command('hb assist attack off')
			end
		end
	elseif cmd == 'all' then
		if ipcflag == false then
			log('Setting current character as leader!')
			ipcflag = true
			windower.send_command('hb assist off')
			windower.send_command('hb assist attack off')
			windower.send_ipc_message('assist all ' .. currentPC.name)
		elseif ipcflag == true then
			log('Assist & Attack -> ' ..namearg)
			windower.send_command('hb assist ' .. namearg)
			windower.send_command('wait 0.5; hb assist attack on')
		end
	elseif cmd == 'on' then
		if ipcflag == false then
			log('Leader for assisting in spells.')
			ipcflag = true
			windower.send_command('hb assist off')
			windower.send_command('hb assist attack off')
			windower.send_ipc_message('assist on ' .. currentPC.name)
		elseif ipcflag == true then
			log('Assist ONLY -> ' ..namearg)
			windower.send_command('hb assist ' .. namearg)
		end
	elseif cmd == 'off' then
		if ipcflag == false then
			ipcflag = true
			windower.send_command('hb assist off; hb assist attack off')
			windower.send_ipc_message('assist off')
		elseif ipcflag == true then
			windower.send_command('hb assist off; hb assist attack off')
		end
	end
	ipcflag = false
	
end

function d2()

	player = windower.ffxi.get_player()
	get_spells = windower.ffxi.get_spells()
	spell = S{player.main_job_id,player.sub_job_id}[4] and (get_spells[261] 
		and {japanese='デジョン',english='"Warp"'} or get_spells[262] 
		and {japanese='デジョンII',english='"Warp II"'})
	
	if spell then
	-- Ok have right job/sub job and spells

		for k, v in pairs(windower.ffxi.get_party()) do
		
			if type(v) == 'table' then
				if v.name ~= currentPC.name then
				
					coroutine.sleep(0.55)
				
					ptymember = windower.ffxi.get_mob_by_name(v.name)
					-- check if party member in same zone.

					if v.mob == nil then
						-- Not in zone.
						log(v.name .. ' is not in zone, skipping')
						--coroutine.sleep(0.5)
					else
						-- In zone, do distance check
						if math.sqrt(ptymember.distance) < 18  and windower.ffxi.get_mob_by_name(v.name).in_party then
							-- Checking recast
							isWaiting = true
							RCast = windower.ffxi.get_spell_recasts()

							while isWaiting == true do
								coroutine.sleep(0.75)
								
								RCast = windower.ffxi.get_spell_recasts()
								
								if (RCast[262] == 0 ) then
									
									--Check MP
									playernow = windower.ffxi.get_player()
									checkmp = playernow.vitals.mp >= 150

									if checkmp then
										--check if resting
										if (new == 33 and old == 0) then
											windower.send_command('input /heal')
										end
										isWaiting = false
									else --Rest for MP
										
										--check if resting
										if (new == 33 and old == 0) then --Already resting
											
										elseif (new == 0 and old == 0) then
											log('Resting for MP')
											windower.send_command('input /heal')
											coroutine.sleep(3)
										else -- idle
											log('Resting for MP')
											windower.send_command('input /heal')
											coroutine.sleep(3)
										end
										isWaiting = true
									end
								end
								
							end
						
								isWaiting = true								
								coroutine.sleep(1.63)
								windower.send_command('input /ma "Warp II" ' .. v.name)
								coroutine.sleep(1)
								log('Warping ' .. v.name)
								
								--Check if still casting		
								while isCasting do
									coroutine.sleep(0.5)
								end

						else
							log(v.name .. ' is too far to warp, skipping')
							--coroutine.sleep(0.5)
						end
					end

				end
				
			end
		end

		-- Warp self
	
		coroutine.sleep(0.25)
		isWaiting = true
		RCast = windower.ffxi.get_spell_recasts()
	
		while isWaiting == true do
			coroutine.sleep(0.75)
			RCast = windower.ffxi.get_spell_recasts()
			
			if (RCast[262] == 0 ) then
									
				--Check MP
				playernow = windower.ffxi.get_player()
				checkmp = playernow.vitals.mp >= 100

				if checkmp then
					--check if resting
					if (new == 33 and old == 0) then
						windower.send_command('input /heal')
					end
					isWaiting = false
				else --Rest for MP
					
					--check if resting
					if (new == 33 and old == 0) then --Already resting
						
					elseif (new == 0 and old == 0) then
						log('Resting for MP')
						windower.send_command('input /heal')
						coroutine.sleep(3)
					else -- idle
						log('Resting for MP')
						windower.send_command('input /heal')
						coroutine.sleep(3)
					end
					isWaiting = true
				end
			end
			
		end

		coroutine.sleep(1.1)
		log('Warping')
		windower.send_command('input /ma "Warp" ' .. currentPC.name)
		
	else
		log('Not BLM main or sub or no warp spells!')
	end
	
end


function buyshields()

	player = windower.ffxi.get_player()
	get_spells = windower.ffxi.get_spells()
	
	log('Starting buying SHIELDS!')
	
	for k, v in pairs(windower.ffxi.get_party()) do
	
		if type(v) == 'table' then
			if v.name ~= currentPC.name then
			
				coroutine.sleep(2)
			
				ptymember = windower.ffxi.get_mob_by_name(v.name)
				-- check if party member in same zone.

				if v.mob == nil then
					-- Not in zone.
					log(v.name .. ' is not in zone, skipping buying shields.')
					coroutine.sleep(0.5)
				else
					-- In zone, do distance check
					if math.sqrt(ptymember.distance) < 8  and windower.ffxi.get_mob_by_name(v.name).in_party then
						coroutine.sleep(1.63)
						windower.send_command('send ' .. v.name .. ' sparks buyall acheron shield')
						log('Buying shields for: ' .. v.name)
						coroutine.sleep(45)
					else
						log(v.name .. ' is too far to buy shields with sparks, skipping')
						coroutine.sleep(0.5)
					end
				end
			end
		end
	end

	-- Buy shield for self
	windower.send_command('sparks buyall acheron shield')
	coroutine.sleep(42)
	log('DONE!')
end


-- Burn functions SMN/GEO

function burnset(cmd2,cmd3,cmd4)
	
	player = windower.ffxi.get_player()
	
	if cmd2 == 'avatar' then
		if cmd3 ~= nil then
			if cmd3:lower() == 'ramuh' then
				settings.avatar = 'ramuh'
				--settings.save()
			elseif cmd3:lower() == 'ifrit' then
				settings.avatar = 'ifrit'
				--settings.save()
			elseif cmd3:lower() == 'siren' then
				settings.avatar = 'siren'
				
			else
				log('Invalid Avatar choice')
			end
		else
			log('Missing argument for Avatar')
		end
		
	elseif cmd2 == 'on' then
		settings.active = true
		windower.add_to_chat(122,'Usage: //mc burn Command Variable \n')
		windower.add_to_chat(122,'\ ')
		windower.add_to_chat(122,'-Commands- \ \ \ -Variables- \n')
		windower.add_to_chat(122,'\ ')
		windower.add_to_chat(122,'\ avatar \ \ \ \ \ \ \ \ \ ramuh/ifrit')
		windower.add_to_chat(122,'\ dia \ \ \ \ \ \ \ \ \ \ \ \ \ on/off')
		windower.add_to_chat(122,'\ indi \ \ \ \ \ \ \ \ \ \ \ \ torpor/malaise')
		windower.add_to_chat(122,'\ assist \ \ \ \ \ \ \ \ \ \ name of character that is engaging mob')
		windower.add_to_chat(123,'\ init \ \ \ \ \ \ \ \ \ \ \ \ *** Intializes commands to all chars, MUST RUN THIS AFTER setting variables. ***')
	elseif cmd2 == 'off' then
		settings.active = false
		
	elseif cmd2 == 'dia' then
		if cmd3 ~= nil then
			if cmd3 == 'on' then
				settings.dia = true
			elseif cmd3 == 'off' then
				settings.dia = false
			else
				log('Invalid DIA choice')
			end
		else
			log('Missing argument for DIA')
		end
	elseif cmd2 == 'indi' then
		if cmd3 ~= nil then
			if cmd3 == 'torpor' then
				settings.indi = 'torpor'
			elseif cmd3 == 'malaise' then
				settings.indi = 'malaise'
			elseif cmd3 == 'refresh' then
				settings.indi = 'refresh'
			elseif cmd3 == 'fury' then
				settings.indi = 'fury'
			end
		else
			log('Missing argument for INDI')
		end
	elseif cmd2 == 'init' then
		
		if settings.assist == '' then
			log('Cannot initialize until you set assist name')
		else
			for k, v in pairs(windower.ffxi.get_party()) do
				if type(v) == 'table' then
					if string.lower(v.name) == string.lower(settings.assist) then
						if v.mob == nil then
							-- Not in zone.
							log(v.name .. ' is not in zone, HB will NOT assist if player is not in zone.  Try again later.')
						
						else
							log('Initialize HB and assist, and disabled cures')
							-- if string.lower(v.name) == string.lower(player.name) then
								-- windower.send_command('hb reload; wait 1.5; hb disable cure; hb disable na')
							-- else
								if player.main_job ~= 'WHM' and player.main_job ~= 'RUN' and player.main_job ~= 'COR' and player.main_job ~= 'BRD' then
									windower.send_command('hb reload; wait 1.5; hb disable cure; hb disable na; hb assist ' ..settings.assist .. '; wait 1.0; hb on')
								end
								if player.main_job == 'COR' then
									windower.send_command('hb reload; wait 1.5; hb on')
									if settings.indi == 'malaise' then
										windower.send_command('roll roll1 beast; wait 1.0; roll roll2 pup;')
									else
										windower.send_command('roll roll1 beast; wait 1.0; roll roll2 drachen;')
									end
								end
								-- Favor
								if player.main_job == 'SMN' then
									if settings.avatar == 'ramuh' then
										windower.send_command('input /ma "Ramuh" <me>; wait 5; input /ja "Avatar\'s Favor" <me>')
									elseif settings.avatar == 'ifrit' then
										windower.send_command('input /ma "Ifrit" <me>; wait 5; input /ja "Avatar\'s Favor" <me>')
									elseif settings.avatar == 'siren' then
										windower.send_command('input /ma "Siren" <me>; wait 5; input /ja "Avatar\'s Favor" <me>')
									end
								end
								if player.main_job == 'GEO' then
										windower.send_command('gs c set autobuffmode off')
									--windower.send_command('lua r autogeo; wait 1.0; geo off; wait 1.5; geo geo frailty')
									if settings.indi == 'torpor' then
										windower.send_command('gs c autogeo frailty; wait 1; gs c autoindi torpor')
									elseif settings.indi == 'malaise' then
										windower.send_command('gs c autogeo frailty; wait 1; gs c autoindi malaise')
										coroutine.sleep(1.0)
										windower.send_command('hb follow ' ..settings.assist .. '; wait 1.0; hb f dist 5')
									elseif settings.indi == 'refresh' then
										windower.send_command('gs c autogeo frailty; wait 1; gs c autoindi refresh')
									elseif settings.indi == 'fury' then
										windower.send_command('gs c autogeo frailty; wait 1; gs c autoindi fury')
									end
								end
							--end
						end
					end
				end
			end
		end
		
	elseif cmd2 == 'assist' then
		if cmd3 ~= nil then
			for k, v in pairs(windower.ffxi.get_party()) do
		
				if type(v) == 'table' then
					if string.lower(v.name) == string.lower(cmd3) then
						if v.mob == nil then
							-- Not in zone.
							log(v.name .. ' is not in zone, HB will NOT assist if player is not in zone.  Try again later.')
						
						else
							log('You are now assisting ' ..cmd3)
							settings.assist = cmd3
						end
					end
				end
			end
			
		else
			log('Missing argument for ASSIST')
		end
	else
		log('Invalid command')
	end

	if ipcflag == false then
		ipcflag = true
		if cmd2 == nil then
		cmd2 = 'a'
		end
		if cmd3 == nil then
			cmd3 = 'b'
		end
		if cmd4 == nil then
			cmd4 = 'c'
		end
		windower.send_ipc_message('burnset ' ..cmd2.. ' ' ..cmd3.. ' ' ..cmd4)
	end

	ipcflag = false
	display_box()
end

function smnhelp(cmd2)
	currentPC=windower.ffxi.get_player()

	if cmd2 == nil then
		if settings.smnhelp then
			log('Helper for SMN BPing DISABLED')
			settings.smnhelp = false
				if ipcflag == false then
				ipcflag = true
				windower.send_ipc_message('smnhelp')
			end
			ipcflag = false
		else
			log('Helper for SMN BPing ACTIVE')
			settings.smnhelp = true
			if ipcflag == false then
				ipcflag = true
				windower.send_ipc_message('smnhelp')
			end
			ipcflag = false
		end
	end
	if settings.smnhelp then
		
		if cmd2 == 'SC' then
			if settings.smnsc then
				log('SMN Skillchain DISABLED')
				settings.smnsc = false
					if ipcflag == false then
					ipcflag = true
					windower.send_ipc_message('smnhelp SC')
				end
				ipcflag = false
			else
				log('SMN Skillchain ACTIVE')
				settings.smnsc = true
				if ipcflag == false then
					ipcflag = true
					windower.send_ipc_message('smnhelp SC')
				end
				ipcflag = false
			end
		end
		
		if currentPC.main_job == 'SMN' then

			if cmd2 == 'assault' then
				if ipcflag == false then
					ipcflag = true
					windower.send_ipc_message('smnhelp assault')
				else
					windower.send_command('input /ja "Assault" <t>')
				end
				ipcflag = false
			elseif cmd2 == 'release' then
				if ipcflag == false then
					ipcflag = true
					windower.send_ipc_message('smnhelp release')
				else
					windower.send_command('input /ja "Release" <me>')
				end
				ipcflag = false
			elseif cmd2 == 'retreat' then
				if ipcflag == false then
					ipcflag = true
					windower.send_ipc_message('smnhelp retreat')
				else
					windower.send_command('input /ja "Retreat" <me>')
				end
				ipcflag = false
			
			elseif cmd2 == 'VS' then
			
				if settings.smnsc then
					if ipcflag == false then
						ipcflag = true
						coroutine.sleep(3.5)
						windower.send_ipc_message('smnhelp FC')
					else
						windower.send_command('input /ja "Volt Strike" <t>')
					end
					ipcflag = false
				else
					if ipcflag == false then
						ipcflag = true
						windower.send_ipc_message('smnhelp VS')
					else
						windower.send_command('input /ja "Volt Strike" <t>')
					end
					ipcflag = false
				end
			
			elseif cmd2 == 'FC' then
				
				if settings.smnsc then
					if ipcflag == false then
						ipcflag = true
						coroutine.sleep(3.5)
						windower.send_ipc_message('smnhelp VS')
					else
						windower.send_command('input /ja "Flaming Crush" <t>')
					end
					ipcflag = false
				else
					if ipcflag == false then
						ipcflag = true
						windower.send_ipc_message('smnhelp FC')
					else
						windower.send_command('input /ja "Flaming Crush" <t>')
					end
					ipcflag = false
				end
				
			elseif cmd2 == 'HA' then
			
				if settings.smnsc then
					if ipcflag == false then
						ipcflag = true
						coroutine.sleep(3.5)
						windower.send_ipc_message('smnhelp FC')
					else
						windower.send_command('input /ja "Hysteric Assault" <t>')
					end
					ipcflag = false
				else
					if ipcflag == false then
						ipcflag = true
						windower.send_ipc_message('smnhelp HA')
					else
						windower.send_command('input /ja "Hysteric Assault" <t>')
					end
					ipcflag = false
				end				
			
			elseif cmd2 == 'ramuh' then
				if settings.smnsc then
					if ipcflag == false then
						ipcflag = true
						windower.send_ipc_message('smnhelp ifrit')
					else
						windower.send_command('input /ma "Ramuh" <me>')
					end
					ipcflag = false
				else
					if ipcflag == false then
						ipcflag = true
						windower.send_ipc_message('smnhelp ramuh')
					else
						windower.send_command('input /ma "Ramuh" <me>')
					end
					ipcflag = false
				end
			elseif cmd2 == 'ifrit' then
				if settings.smnsc then
					if ipcflag == false then
						ipcflag = true
						windower.send_ipc_message('smnhelp ramuh')
					else
						windower.send_command('input /ma "Ifrit" <me>')
					end
					ipcflag = false
				else
					if ipcflag == false then
						ipcflag = true
						windower.send_ipc_message('smnhelp ifrit')
					else
						windower.send_command('input /ma "Ifrit" <me>')
					end
					ipcflag = false
				end
				
			elseif cmd2 == 'siren' then
				if settings.smnsc then
					if ipcflag == false then
						ipcflag = true
						windower.send_ipc_message('smnhelp ifrit')
					else
						windower.send_command('input /ma "Siren" <me>')
					end
					ipcflag = false	
				else
					if ipcflag == false then
						ipcflag = true
						windower.send_ipc_message('smnhelp siren')
					else
						windower.send_command('input /ma "Siren" <me>')
					end
					ipcflag = false	
				end
			elseif cmd2 == 'apogee' then
				if ipcflag == false then
					ipcflag = true
					windower.send_ipc_message('smnhelp apogee')
				else
					windower.send_command('input /ja "Apogee" <me>')
				end
				ipcflag = false
			elseif cmd2 == 'thunderspark' then
				if ipcflag == false then
					ipcflag = true
					windower.send_ipc_message('smnhelp thunderspark')
				else
					windower.send_command('input /ja "Thunderspark" <t>')
				end
				ipcflag = false
			elseif cmd2 == 'thunderstorm' then
				if ipcflag == false then
					ipcflag = true
					windower.send_ipc_message('smnhelp thunderstorm')
				else
					windower.send_command('input /ja "thunderstorm" <t>')
				end
				ipcflag = false
			elseif cmd2 == 'NB' then
				if ipcflag == false then
					ipcflag = true
					windower.send_ipc_message('smnhelp NB')
				else
					windower.send_command('input /ja "Nether Blast" <t>')
				end
				ipcflag = false
			elseif cmd2 == 'diabolos' then
				if ipcflag == false then
					ipcflag = true
					windower.send_ipc_message('smnhelp diabolos')
				else
					windower.send_command('input /ma "Diabolos" <me>')
				end
				ipcflag = false
			elseif cmd2 == 'super' then
				if ipcflag == false then
					ipcflag = true
					windower.send_ipc_message('smnhelp super')
				else
					windower.send_command('input /item "Super Revitalizer" <me>')
				end
				ipcflag = false
			elseif cmd2 == 'elixir' then
				if ipcflag == false then
					ipcflag = true
					windower.send_ipc_message('smnhelp elixir')
				else
					windower.send_command('input /item "Lucid Elixir II" <me>')
					windower.send_command('input /item "Lucid Elixir I" <me>')
				end
				ipcflag = false
			end
		else
			if ipcflag == false then
				ipcflag = true
			end
			ipcflag = false
		end

	end
	display_box()
end	

function rngsc(cmd2)
	currentPC=windower.ffxi.get_player()
	
	local rangedjobs = S{'RNG','COR'}

	if cmd2 == nil then
		if settings.rngsc then
			log('Helper for Ranged SC DISABLED')
			settings.rngsc = false
				if ipcflag == false then
				ipcflag = true
				windower.send_ipc_message('rngsc')
			end
			ipcflag = false
		else
			log('Helper for Ranged SC ACTIVE')
			settings.rngsc = true
			if ipcflag == false then
				ipcflag = true
				windower.send_ipc_message('rngsc')
			end
			ipcflag = false
		end
	end
	if settings.rngsc then
		if rangedjobs:contains(currentPC.main_job) then
			
			if cmd2 == 'Wildfire' then
				if not (currentPC.main_job == 'RUN') then				
					if ipcflag == false then
						ipcflag = true
						windower.add_to_chat(123, 'Starting SC Wildfire')
						coroutine.sleep(3.8)
						windower.send_ipc_message('rngsc Wildfire')
						windower.send_command('wait 1.6; autora start')
					else
						windower.add_to_chat(123, 'ENDING SC Wildfire')
						windower.send_command('input /ws "Wildfire" <t>')
						coroutine.sleep(3.8)
						windower.send_command('wait 1.6; autora start')
					end
					ipcflag = false
				end
			elseif cmd2 == 'Laststand' then
				if not (currentPC.main_job == 'RUN') then				
					if ipcflag == false then
						ipcflag = true
						windower.add_to_chat(123, 'Starting SC Last Stand')
						coroutine.sleep(3.8)
						windower.send_ipc_message('rngsc Laststand')
						windower.send_command('wait 1.6; autora start')
					else
						windower.add_to_chat(123, 'ENDING SC Last Stand')
						windower.send_command('input /ws "Last Stand" <t>')
						coroutine.sleep(3.8)
						windower.send_command('wait 1.6; autora start')
					end
					ipcflag = false
				end
			elseif cmd2 == 'GroundStrike' then
				if ipcflag == false then
					ipcflag = true
					windower.add_to_chat(123, 'Starting SC Ground Strike')
					coroutine.sleep(2.7)
					windower.send_ipc_message('rngsc GroundStrike')
				else
					windower.add_to_chat(123, 'ENDING SC Ground Strike')
					windower.send_command('input /ja "Earth Shot" <t>')
					coroutine.sleep(1.2)
					windower.send_command('input /ws "Leaden Salute" <t>')
					coroutine.sleep(3.4)
					windower.send_command('wait 1.6; autora start')
				end
				ipcflag = false
			elseif cmd2 == 'Jishnu' then
				if ipcflag == false then
					ipcflag = true
					windower.add_to_chat(123, 'Starting SC Jishnu 4 step')
					windower.send_command('wait 3.3; autora start')
					--coroutine.sleep(5.8)
					coroutine.sleep(2.1)
					windower.send_ipc_message('rngsc Jishnu')
					coroutine.sleep(8.3)
					coroutine.sleep(3.7)
					windower.add_to_chat(123, 'Third step Namas Arrow')
					windower.send_command('input /ws "Namas Arrow" <t>')
					--coroutine.sleep(1.5)
					windower.send_command('wait 3.3; autora start')
				else
					windower.add_to_chat(123, 'Second step Leaden Salute + Earth shot!')
					windower.send_command('input /ja "Earth Shot" <t>')
					coroutine.sleep(3.7)
					windower.send_command('input /ws "Leaden Salute" <t>')
					--coroutine.sleep(1.5)
					windower.send_command('wait 3.3; autora start')
					coroutine.sleep(14.4)
					windower.add_to_chat(123, 'Forth step Wildfire')
					windower.send_command('input /ws "Wildfire" <t>')
					--coroutine.sleep(1.5)
					windower.send_command('wait 3.3; autora start')
				end
				ipcflag = false
			elseif cmd2 == 'shoot' then
				if not (currentPC.main_job == 'RUN') then				
					if ipcflag == false then
						ipcflag = true
						windower.add_to_chat(123, 'Shooting!')
						windower.send_ipc_message('rngsc shoot')
						windower.send_command('autora start')
					else
						windower.add_to_chat(123, 'Shooting')
						windower.send_command('autora start')
					end
					ipcflag = false
				end
			end
		else
			if ipcflag == false then
				ipcflag = true
			end
			ipcflag = false
		end
	end
	display_box()
end	


function geoburn()
	
	player = windower.ffxi.get_player()
	
	if settings.active then
		log('Check GEO for burn.')
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('geoburn')
		end
		ipcflag = false
		if player.main_job == 'GEO' then
			windower.add_to_chat(123, 'GEO Burn Activated for Bolster!')
			
			windower.send_command('gs c set autobuffmode off')
			windower.send_command('hb disable cure')
			windower.send_command('hb disable na')
			windower.send_command('hb on')
			
			coroutine.sleep(1.7)
			windower.send_command('input /ja "Bolster" <me>')
			coroutine.sleep(1.8)
			windower.send_command('input /ma "Geo-Frailty" <t>')
			coroutine.sleep(4.5)
			if settings.indi == 'torpor' then
				windower.send_command('input /ma "Indi-Torpor" <me>')
			elseif settings.indi == 'malaise' then
				windower.send_command('input /ma "Indi-Malaise" <me>')
			elseif settings.indi == 'refresh' then
				windower.send_command('input /ma "Indi-Refresh" <me>')
			end
			coroutine.sleep(4.5)
			windower.send_command('input /ja "Dematerialize" <me>')
			coroutine.sleep(0.75)
			if settings.dia then
				windower.send_command('hb debuff dia II')
			elseif not settings.dia then
				windower.send_command('hb debuff rm dia II')
			end
			windower.send_command('hb enable cure')
			windower.send_command('hb enable na')
			windower.send_command('hb mincure 3')
			windower.send_command('gs c set autobuffmode auto')

		else
			log('Not GEO job, skipping')
		end
	else
		log('OneHour BURN not active!')
	end
end

function smnburn()

	player = windower.ffxi.get_player()
	if settings.active then
		log('Check SMN for burn.')
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('smnburn')
		end
		ipcflag = false
		
		if player.main_job == 'SMN' then
			
			windower.add_to_chat(123, 'SMN Burn INTIATE!')
			windower.send_command('hb on')
			-- check distance 21 or less
			coroutine.sleep(1.5)
			windower.send_command('input /ja "Astral Flow" <me>')
			coroutine.sleep(2.5)
			windower.send_command('input /ja "Assault" <t>')
			coroutine.sleep(4.2)
			windower.send_command('input /ja "Astral Conduit" <me>')
			coroutine.sleep(1.6)
			if settings.avatar == 'ramuh' then
				windower.send_command('exec VoltStrike.txt')
			elseif settings.avatar == 'ifrit' then
				windower.send_command('exec FlamingCrush.txt')
			elseif settings.avatar == 'siren' then
				windower.send_command('exec HystericAssault.txt')
			end
		else
			log('Not SMN job, skipping')
		end
	else
		log('OneHour BURN not active!')
	end
end

function domain()
	log('Domain setup')
	windower.send_command('cancel mobilization')
end
-- External addons

function warp()
	log('Warping.')
	windower.send_command('myhome')
end

function omen()
	log('Heading to Omen.')
	windower.send_command('myomen')
end

function trib()
	log('Getting Tribulens')
	windower.send_command('escha trib')
end

function rads()
	log('Getting Radialens')
	windower.send_command('escha rads')
end

function buyalltemps()
	log('Getting ALL TEMPS!')
	windower.send_command('escha buyall')
end

-- Functions to enter instances -> May move to separate addon?
function go()
	if ipcflag == false then
		ipcflag = true
		windower.send_command('wait 0.5; input /targetnpc; wait 0.5; setkey enter down; wait 0.5; setkey enter up;')
		windower.send_ipc_message('go')
	elseif ipcflag == true then
		windower.send_command('input /targetnpc; wait 0.5; setkey enter down; wait 0.5; setkey enter up;')
	end
	ipcflag = false
end

function enter()
	if ipcflag == false then
		ipcflag = true
		windower.send_command('input /targetnpc; wait 1; input /lockon; wait 1; setkey enter down; wait 0.5; setkey enter up; wait 3; setkey up down; wait 0.5; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
		windower.send_ipc_message('enter')
	elseif ipcflag == true then
		windower.send_command('input /targetnpc; wait 1; input /lockon; wait 1; setkey enter down; wait 0.5; setkey enter up; wait 3; setkey up down; wait 0.5; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
	end
	ipcflag = false
end

function srrget()
	if ipcflag == false then
		ipcflag = true
		windower.send_command('input /targetnpc; wait 1; input /lockon; wait 1; setkey enter down; wait 0.5; setkey enter up; wait 3; setkey down down; wait 0.1; setkey down up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 1.0; setkey up down; wait 0.5; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
		windower.send_ipc_message('srrget')
	elseif ipcflag == true then
		windower.send_command('input /targetnpc; wait 1; input /lockon; wait 1; setkey enter down; wait 0.5; setkey enter up; wait 3; setkey down down; wait 0.1; setkey down up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 1.0; setkey up down; wait 0.5; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
	end
	ipcflag = false
end


function srr()
	if ipcflag == false then
		ipcflag = true
		windower.send_command('input /targetnpc; wait 1; input /lockon; wait 1; setkey enter down; wait 0.5; setkey enter up; wait 3; setkey down down; wait 0.1; setkey down up; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
		windower.send_ipc_message('srr')
	elseif ipcflag == true then
		windower.send_command('input /targetnpc; wait 1; input /lockon; wait 1; setkey enter down; wait 0.5; setkey enter up; wait 3; setkey down down; wait 0.1; setkey down up; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
	end
	ipcflag = false
end

function endown()
	if ipcflag == false then
		ipcflag = true
		windower.send_command('input /targetnpc; wait 1; input /lockon; wait 2; setkey enter down; wait 0.5; setkey enter up; wait 5; setkey down down; wait 0.5; setkey down up; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
		windower.send_ipc_message('endown')
	elseif ipcflag == true then
		windower.send_command('input /targetnpc; wait 1; input /lockon; wait 2; setkey enter down; wait 0.5; setkey enter up; wait 5; setkey down down; wait 0.5; setkey down up; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
	end
	ipcflag = false
end

function enup()
	if ipcflag == false then
		ipcflag = true
		windower.send_command('setkey up down; wait 0.5; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
		windower.send_ipc_message('enup')
	elseif ipcflag == true then
		windower.send_command('setkey up down; wait 0.5; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
	end
	ipcflag = false
end

function esc()
	if ipcflag == false then
		ipcflag = true
		windower.send_command('setkey escape down; wait 0.5; setkey escape up;')
		windower.send_ipc_message('esc')
	elseif ipcflag == true then
		windower.send_command('setkey escape down; wait 0.5; setkey escape up;')
	end
	ipcflag = false
end

function htmb(cmd2)
	if cmd2 == 'enter' then
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('htmb enter')
		elseif ipcflag == true then
			local zone = windower.ffxi.get_info()['zone']
			local cloister_zones = S{201,202,203,207,209,211}
			local targetid = 0
			-- Avatar battles
			if cloister_zones:contains(zone) then
				if zone == 201 then
					targetid = windower.ffxi.get_mob_by_name('Wind Protocrystal')
				elseif zone == 202 then
					targetid = windower.ffxi.get_mob_by_name('Lightning Protocrystal')
				elseif zone == 203 then
					targetid = windower.ffxi.get_mob_by_name('Ice Protocrystal')
				elseif zone == 207 then
					targetid = windower.ffxi.get_mob_by_name('Fire Protocrystal')
				elseif zone == 209 then
					targetid = windower.ffxi.get_mob_by_name('Earth Protocrystal')
				elseif zone == 211 then
					targetid = windower.ffxi.get_mob_by_name('Water Protocrystal')
				end
					log('Target: ' .. targetid.id)
					windower.send_command('settarget ' .. targetid.id)
					windower.send_command('wait 0.5; input /lockon; wait 2; setkey enter down; wait 0.5; setkey enter up; wait 6; setkey down down; wait 0.5; setkey down up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 1.0; setkey up down; wait 0.5; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up')
			else
				windower.send_command('input /targetnpc; wait 1; input /lockon; wait 2; setkey enter down; wait 0.5; setkey enter up; wait 7; setkey down down; wait 0.5; setkey down up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 1.0; setkey up down; wait 0.5; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up')
			end
		end
		ipcflag = false
	elseif cmd2 == 'buy' then
		windower.send_command('htmb; wait 8; findall avatar phantom')
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('htmb buy')
		end
		ipcflag = false
	elseif cmd2 == 'woe' then
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('htmb woe')
		elseif ipcflag == true then
			windower.send_command('input /targetnpc; wait 1; input /lockon; wait 2; setkey enter down; wait 0.5; setkey enter up; wait 7; setkey down down; wait 0.5; setkey down up; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
		end
		ipcflag = false
	end
end


function runic()
	
	local zone = windower.ffxi.get_info()['zone']
	local runic_zones = S{50,77,54,52,61,79,72}
	if runic_zones:contains(zone) then
	
		local runic_id = windower.ffxi.get_mob_by_name('Runic Portal').id
		log(runic_id)
		windower.send_command('settarget ' .. runic_id)
		coroutine.sleep(1)
		windower.send_command('input /lockon; wait 1; setkey enter down; wait 0.5; setkey enter up; wait 2; setkey up down; wait 0.5; setkey up up; wait 2; setkey enter down; wait 0.5; setkey enter up;')
	else
		log('Not in runic zone!')
	end
		
	if ipcflag == false then
		ipcflag = true
		windower.send_ipc_message('runic')
	end
	ipcflag = false
end

function tag()

	log('tag')
	local zone = windower.ffxi.get_info()['zone']
	if zone == 50 then
		log('In zone')
		windower.send_command('input /targetnpc; wait 2; setkey enter down; wait 0.5; setkey enter up; wait 2; input /targetnpc; wait 2; setkey enter down; wait 0.5; setkey enter up; wait 2.5; setkey enter down; wait 0.5; setkey enter up;')
	end
		
	if ipcflag == false then
		ipcflag = true
		windower.send_ipc_message('tag')
	end
	ipcflag = false
end

function done()

	local ror = windower.ffxi.get_mob_by_name('Rune of Release').id
	--local book = 'Ilrusi Ledger'
	local book = 'Leujaoam Log'
	--local book = 'Mamool Ja Journal'
	--local book = 'Lebros Chronicle'
	--local book = 'Periqia Diary'
		windower.send_command('settarget ' .. ror)
		coroutine.sleep(1)
		windower.send_command('input /lockon; wait 1; input /item \"' .. book .. '\" <t>')
		
	if ipcflag == false then
		ipcflag = true
		windower.send_ipc_message('done')
	end
	ipcflag = false
end

function remdrop()
	local rem_chapters = S{4069,4070,4071,4072,4073}

	local items = windower.ffxi.get_items()
	for index, item in pairs(items.inventory) do
		if type(item) == 'table' and rem_chapters:contains(item.id) then
			log('Dropping REM: ' .. item.id)
			windower.ffxi.drop_item(index, item.count)
		end
	end
end

function zerg(cmd2)
	if cmd2 == 'on' then
		windower.send_command('gs c set AutoZergMode on')
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('zerg on')
		end
		ipcflag = false
	elseif cmd2 == 'off' then
		windower.send_command('gs c set AutoZergMode off')
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('zerg off')
		end
		ipcflag = false
	end
end

function ein(cmd2)
	local zone = windower.ffxi.get_info()['zone']
	if zone == 78 then
	
	if (cmd2 == 'enter') then
		--windower.send_command('settarget 17097342')
		coroutine.sleep(3)
		windower.send_command('input /targetnpc; wait 1; input /lockon; wait 1; input /item \'glowing lamp\' <t>; wait 3; setkey up down; wait 0.5; setkey up up; wait 1; setkey enter down; wait 0.5; setkey enter up')
		coroutine.sleep(10)
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('ein enter')
		end
		ipcflag = false
	elseif (cmd2 == 'exit') then
		local items = windower.ffxi.get_items()
		local exitflag = false
		for index, item in pairs(items.inventory) do
			if type(item) == 'table' and item.id == 5414 then
				log('Dropping lamp to exit!')
				windower.ffxi.drop_item(index, item.count)
				exitflag = true
			end
		end
		if exitflag == false then
			log('No lamp in inventory!')
		end
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('ein exit')
		end
		ipcflag = false
	else
		log('No sub command specified')
	end
	else
		windower.add_to_chat(123,"Not in proper zone, skipping")
	end
	
end

-- Beta functions

function buffall(cmd2)
	player = windower.ffxi.get_player()
	for k, v in pairs(windower.ffxi.get_party()) do
		if type(v) == 'table' then
			if v.mob == nil then
				-- Not in zone.
				log(v.name .. ' is not in zone!')
			elseif windower.ffxi.get_mob_by_name(v.name).in_party then
				windower.send_command('hb buff ' .. v.name .. ' ' .. cmd2)
			end
		end
		end
end

function haste()
	player = windower.ffxi.get_player()
	for k, v in pairs(windower.ffxi.get_party()) do
		if type(v) == 'table' then
			if v.mob == nil then
				-- Not in zone.
				log(v.name .. ' is not in zone!')
			elseif windower.ffxi.get_mob_by_name(v.name).in_party then
				if player.main_job == 'RDM' then
					windower.send_command('hb buff ' .. v.name .. ' haste2')
				else
					windower.send_command('hb buff ' .. v.name .. ' haste')
				end
			end
		end
		end
end

function wstype(cmd2)
	local player_job = windower.ffxi.get_player()
	local WSjobs = S{'COR','DRG','SAM','BLU','DRK'}		

	if cmd2 == 'leaden' then
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('wstype leaden')
		end
		ipcflag = false
		if WSjobs:contains(player_job.main_job) then
			if player_job.main_job == 'COR' then
				log('WS is Leaden Salute')
				windower.send_command('gs c autows Leaden Salute')
				windower.send_command('gs c set weapons DualLeaden')
			else
				log('Not COR, no WS change.')
			end
		else
			log('Not correct job for WS Change, Skipping')
		end
	elseif cmd2 == 'savage' then
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('wstype savage')
		end
		ipcflag = false
		if WSjobs:contains(player_job.main_job) then
			if player_job.main_job == 'COR' then
				log('WS is Savage Blade')
				windower.send_command('gs c autows Savage Blade')
				windower.send_command('gs c set weapons DualSavage')
			else
				log('Not COR, no WS change.')
			end
		else
			log('Not correct job for WS Change, Skipping')
		end
	elseif cmd2 == 'slash' then
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('wstype slash')
		end
		ipcflag = false
		if WSjobs:contains(player_job.main_job) then
			if player_job.main_job == 'COR' then
				log('WS is Savage')
				windower.send_command('gs c autows Savage Blade')
				windower.send_command('gs c set weapons DualSavage')
			elseif player_job.main_job == 'DRG' then
				log('WS is Savage')
				windower.send_command('gs c autows Savage Blade')
				windower.send_command('gs c set weapons Naegling')
			elseif player_job.main_job == 'SAM' then
				log('WS is Fudo')
				windower.send_command('gs c set weapons Masamune')
			elseif player_job.main_job == 'DRK' then
				log('WS is Torcleaver')
				windower.send_command('gs c set weapons Caladbolg')
			elseif player_job.main_job == 'BLU' then
				log('WS is Savage')
				windower.send_command('gs c set weapons NaegThib')
				windower.send_command('gs c autows Savage Blade')
			end
		else
			log('Not correct job for WS Change, Skipping')
		end
	elseif cmd2 == 'pierce' then
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('wstype pierce')
		end
		ipcflag = false
		if WSjobs:contains(player_job.main_job) then
			if player_job.main_job == 'COR' then
				log('WS is Savage')
				windower.send_command('gs c autows Last Stand')
				windower.send_command('gs c set weapons DualLastStand')
			elseif player_job.main_job == 'DRG' then
				log('WS is Stardiver')
				windower.send_command('gs c autows Stardiver')
				windower.send_command('gs c set weapons Trishula')
			elseif player_job.main_job == 'SAM' then
				log('WS is Impulse')
				windower.send_command('gs c set weapons ShiningOne')
			elseif player_job.main_job == 'DRK' then
				log('WS is Torcleaver')
				windower.send_command('gs c set weapons Caladbolg')
				elseif player_job.main_job == 'BLU' then
				log('WS is ???')
					windower.send_command('gs c set weapons NaegThib')
					windower.send_command('gs c autows Savage Blade')
			end
		else
			log('Not correct job for WS Change, Skipping')
		end
	elseif cmd2 == 'blunt' then
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('wstype blunt')
		end
		ipcflag = false
		if WSjobs:contains(player_job.main_job) then
			if player_job.main_job == 'BLU' then
				log('WS is Black Halo')
				windower.send_command('gs c autows Black Halo')
				windower.send_command('gs c set weapons MagicWeapons')
			elseif player_job.main_job == 'SAM' or player_job.main_job == 'DRK' then
				log('WS is True Strike')
				windower.send_command('gs c set weapons MaficCudgel')
			elseif player_job.main_job == 'COR' then
				log('WS is WildFire')
				windower.send_command('gs c autows Wildfire')
				windower.send_command('gs c set weapons DualLeaden')
				elseif player_job.main_job == 'DRG' then
				log('WS is Retribution')
				windower.send_command('gs c autows Retribution')
				windower.send_command('gs c set weapons Malignance')
			end
		else
			log('Not correct job for WS Change, Skipping')
		end
	end
end

function proc(cmd2)
	local player_job = windower.ffxi.get_player()
	local MageNukeJobs = S{'BLM','GEO','SCH','RDM'}		

	if cmd2 == 'on' then
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('proc on')
		end
		ipcflag = false
		if MageNukeJobs:contains(player_job.main_job) then
			log('Proc casting ON')
			windower.send_command('gs c set castingmode proc')
			windower.send_command('gs c set MagicBurstMode off')
			windower.send_command('gs c set AutoNukeMode off')
			windower.send_command('lua u maa')
			if player_job.main_job == "GEO" then
				windower.send_command('gs c autoindi refresh; gs c autogeo haste')
			end
		else
			log('Skipping')
		end
	elseif cmd2 == 'off' then
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('proc off')
		end
		ipcflag = false
		if MageNukeJobs:contains(player_job.main_job) then
			log('Proc casting OFF')
			windower.send_command('gs c set castingmode normal')
			windower.send_command('gs c set MagicBurstMode lock')
			windower.send_command('gs c set AutoNukeMode off')
			windower.send_command('lua r maa')
			if player_job.main_job == "GEO" then
				windower.send_command('gs c autoindi acumen; gs c autogeo malaise')
			end
		else
			log('Skipping')
		end
	elseif cmd2 == 'nuke' then
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('proc nuke - low tier')
		end
		ipcflag = false
		if MageNukeJobs:contains(player_job.main_job) then
			log('Auto nuke - low tier')
			windower.send_command('gs c set castingmode normal')
			windower.send_command('gs c set MagicBurstMode off')
			windower.send_command('gs c set AutoNukeMode on')
			windower.send_command('lua u maa')
			if player_job.main_job == "GEO" then
				windower.send_command('gs c autoindi refresh; gs c autogeo haste')
			end
		else
			log('Skipping')
		end
	end
end

---------------------------------
--Helper functions--
---------------------------------

local function get_delay()
    local self = windower.ffxi.get_player().name
    local members = {}
    for k, v in pairs(windower.ffxi.get_party()) do
        if type(v) == 'table' then
            members[#members + 1] = v.name
        end
    end
    table.sort(members)
    for k, v in pairs(members) do
        if v == self then
            return (k - 1) * settings.send_all_delay
        end
    end
end



------------
--IPC Stuff
------------

windower.register_event('ipc message', function(msg, ...) 
	local args = msg:split(' ')
	local cmd = args[1]
	local cmd2 = args[2]
	local cmd3 = args[3]
	local cmd4 = args[4]
	args:remove(1)
	local delay = get_delay()
	local term = msg:split(' ')
	term:remove(1)
	local send_cmd = table.concat(term, " ")
	
	if (InternalCMDS:contains(cmd)) then
		if cmd2 == nil then
			log('IPC: ' .. cmd)
			ipcflag = true
			if(DelayCMDS:contains(cmd)) then
				coroutine.sleep(delay)
			end
			send_int_cmd(cmd)
			--loadstring(cmd.."()")()
		else
			log('IPC: ' .. cmd)
			ipcflag = true
			if(DelayCMDS:contains(cmd)) then
				coroutine.sleep(delay)
			end
			send_int_cmd(cmd,cmd2)
			--_G[cmd](cmd2)
		end
	elseif cmd == 'assist' then
		if cmd2 == 'melee' then
			log('IPC Assist MELEE')
			ipcflag = true
			assist(cmd2,cmd3)
		elseif cmd2 == 'all' then
			log('IPC Assist ALL')
			ipcflag = true
			assist(cmd2,cmd3)
		elseif  cmd2 == 'on' then
			log('IPC Assist ON')
			ipcflag = true
			assist(cmd2,cmd3)
		elseif cmd2 == 'off' then
			log('IPC Assist OFF')
			ipcflag = true
			assist(cmd2)
		end
	elseif cmd == 'fps' then
		log('IPC FPS')
		ipcflag = true
		fps(cmd2)
	elseif cmd == 'send' then
		log('IPC Send: ' .. send_cmd)
		coroutine.sleep(delay)
		ipcflag = true
		send(send_cmd)
	elseif cmd == 'burnset' then
		log('IPC Burn Settings')
		ipcflag = true
		burnset(cmd2, cmd3, cmd4)
	elseif cmd == 'smnburn' then
		log('IPC SMN - Astral Flow/Conduit')
		ipcflag = true
		smnburn()
	elseif cmd == 'geoburn' then
		log('IPC GEO - Bolster')
		ipcflag = true
		geoburn()
	elseif cmd == 'smnhelp' then
		log('IPC SMNHelp')
		ipcflag = true
		smnhelp(cmd2)
	elseif cmd == 'rngsc' then
		log('IPC RNGSC')
		ipcflag = true
		rngsc(cmd2)
	elseif cmd == 'stage' then
		log('IPC STAGE')
		ipcflag = true
		stage(cmd2)
	elseif cmd == 'buy' then
		log('IPC Buy')
		coroutine.sleep(delay)
		ipcflag = true
		buy(cmd2)	


	-- Might move these to separate addon
	elseif cmd == 'ein' then
		log('IPC Ein')
		coroutine.sleep(delay)
		ipcflag = true
		ein(cmd2)
	elseif cmd == 'go' then
		log('IPC GO')
		coroutine.sleep(delay)
		ipcflag = true
		go()
	elseif cmd == 'enter' then
		log('IPC ENTER')
		coroutine.sleep(delay)
		ipcflag = true
		enter()
	elseif cmd == 'srr' then
		log('IPC SRR')
		coroutine.sleep(delay)
		ipcflag = true
		srr()
	elseif cmd == 'srrget' then
		log('IPC SRRGET')
		coroutine.sleep(delay)
		ipcflag = true
		srrget()
	elseif cmd == 'endown' then
		log('IPC ENTER DOWN')
		coroutine.sleep(delay)
		ipcflag = true
		endown()
	elseif cmd == 'enup' then
		log('IPC UP MENU')
		coroutine.sleep(delay)
		ipcflag = true
		enup()
	elseif cmd == 'esc' then
		log('IPC ESC MENU')
		coroutine.sleep(delay)
		ipcflag = true
		esc()
	elseif cmd == 'zerg' then
		log('IPC Zerg')
		coroutine.sleep(delay)
		ipcflag = true
		zerg(cmd2)
	elseif cmd == 'htmb' then
		log('IPC HTMB')
		local moredelay = delay + 0.3
		coroutine.sleep(moredelay)
		ipcflag = true
		htmb(cmd2)	
	elseif cmd == 'runic' then
		log('IPC Runic')
		coroutine.sleep(delay)
		ipcflag = true
		runic()	
	elseif cmd == 'done' then
		log('IPC DONE')
		coroutine.sleep(delay)
		ipcflag = true
		done()	
	elseif cmd == 'tag' then
		log('IPC Tag')
		coroutine.sleep(delay)
		ipcflag = true
		tag()	
	elseif cmd == 'proc' then
		log('IPC Proc')
		coroutine.sleep(delay)
		ipcflag = true
		proc(cmd2)	
	elseif cmd == 'wstype' then
		log('IPC wstype')
		coroutine.sleep(delay)
		ipcflag = true
		wstype(cmd2)	
	end
end)

function loaded()
	settings = config.load(default)
	init_box_pos()
end

windower.register_event('load', loaded)
--windower.register_event('zone change', zone_change)