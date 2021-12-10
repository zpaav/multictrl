_addon.name = 'MC'
_addon.author = 'Kate'
_addon.version = '1.8.0'
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
	rngsc=false,
	autoarts='',
	npc_dialog=false,
}

areas = {}

-- City areas for town gear and behavior.
areas.Cities = S{
    "Ru'Lude Gardens",
    "Upper Jeuno",
    "Lower Jeuno",
    "Port Jeuno",
    "Port Windurst",
    "Windurst Waters",
    "Windurst Woods",
    "Windurst Walls",
    "Heavens Tower",
    "Port San d'Oria",
    "Northern San d'Oria",
    "Southern San d'Oria",
	"Chateau d'Oraguille",
    "Port Bastok",
    "Bastok Markets",
    "Bastok Mines",
    "Metalworks",
    "Aht Urhgan Whitegate",
	"The Colosseum",
    "Tavnazian Safehold",
    "Nashmau",
    "Selbina",
    "Mhaura",
	"Rabao",
    "Norg",
    "Kazham",
    "Eastern Adoulin",
    "Western Adoulin",
	"Celennia Memorial Library",
	"Mog Garden",
	"Leafallia"
}

areas.Abyssea = S{15,45,132,215,216,217,218,253,254}

jobnames = {
	[0] = {job="WHM",name=""},
    [1] = {job="RDM",name=""},
	[2] = {job="BRD",name=""},

}

InternalCMDS = S{
	'on','off','foff',
	'mnt','dis','reload','unload','fin','sch','ent',
	'lotall','buff','esc','nitro','sv5','cleanstones','brd',
	'fight','fightmage','fightsmall','ws','food','sleep','rng','trib','rads','buyalltemps',
	'warp','omen','wsall','cc','drop'}

DelayCMDS = S{'trib','rads','buyalltemps'}
	
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
	elseif cmd == 'done' then
		done()
	elseif cmd == 'ein' then
		ein(cmd2)
	elseif cmd == 'htmb' then
		htmb(cmd2)
	elseif cmd == 'go' then
		go()
	elseif cmd == 'enter' then
		enter()
	elseif cmd == 'get' then
		get(cmd2)
	elseif cmd == 'endown' then
		endown()
	elseif cmd == 'enup' then
		enup()
	elseif cmd == 'zerg' then
		zerg(cmd2)
	elseif cmd == 'buffall' then
		buffall(cmd2)
	elseif cmd == 'proc' then
		proc(cmd2)
	elseif cmd == 'wstype' then
		wstype(cmd2)
	elseif cmd == 'rand' then
		rand()
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
	elseif cmd == 'as' then
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
	elseif cmd == 'jc' then
		jc(cmd2)
	elseif cmd == 'send' then
		send(term)
	elseif cmd == 'gettarget' then
		gettarget(term)
	elseif InternalCMDS:contains(cmd) then
		send_int_cmd(cmd,cmd2)
	end

end)

local mprefix = ('[%s] '):format(_addon.name)

function enter()
	log('Enter')
	windower.send_command('setkey enter down; wait 0.5; setkey enter up;')
end
function down()
	log('Down')
	windower.send_command('setkey down down; wait 0.1; setkey down up;')
end
function up()
	log('Up')
	windower.send_command('setkey up down; wait 0.1; setkey up up;')
end
function right()
	log('Right')
	windower.send_command('setkey right down; wait 0.5; setkey right up;')
end
function left()
	log('Left')
	windower.send_command('setkey left down; wait 0.5; setkey left up;')
end

function atc(...)
    local args = T({...})
	local msg = table.concat({...}, ' ')
    windower.add_to_chat(478, mprefix..msg)
	--478 L.blue
end

function atcwarn(...)
    local args = T({...})
	local msg = table.concat({...}, ' ')
    windower.add_to_chat(3, mprefix..msg)
end

function send_int_cmd(cmd,cmd2)
	-- Single command functions
	if cmd2 == nil then

		--atc('Function: ' .. cmd)
		loadstring(cmd.."()")()
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message(cmd)
		end
		ipcflag = false
	-- 2 commands function
	else
		--atc('Function - 2 ARGS: ' .. cmd)
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

function stage(cmd2)
	local player_job = windower.ffxi.get_player()
	local MeleeJobs = S{'WAR','SAM','DRG','DRK','NIN','MNK','COR','BLU','PUP','DNC','RUN','BRD','THF','RNG'}

	settings = settings.load('data/settings.xml')

	-- Iron giants month - BRD/WHM, GEO/RDM, PLD/RUN, COR/NINx2, RNG/WAR
	if cmd2 == 'ambu' then
		atc('Stage : ' .. cmd2)
		windower.send_command('input /autotarget off')
		if player_job.main_job == 'BRD' then
			windower.send_command('sing pl ambu; sing n off; sing p on; gaze ap off; sing ballad 2 <me>; sing ballad 2 <m3>; sing ballad 2 ' ..settings.char5.. '; hb mincure 3; sing sirvente ' ..settings.char1.. '; wait 2.5; mc brd reset')
		elseif player_job.main_job == 'COR' then
			windower.send_command('gaze ap off; gs c autows Leaden Salute; gs c set weapons DualLeadenRanged')
		elseif player_job.main_job == 'RNG' then
			windower.send_command('gaze ap off; gs c autows coronach; gs c set weapons Annihilator')
		elseif player_job.main_job == 'PLD' then
			windower.send_command('lua r react; gs c set runeelement ignis; hb buff <me> barblizzard; gaze ap off; gs c set weapons Aegis')
		elseif player_job.main_job == 'GEO' then
			windower.send_command('hb mincure 3; gs c autogeo acumen; gs c autoindi fury; gs c autoentrust refresh; hb buff ' ..settings.char1.. ' haste; hb buff ' ..settings.char1.. ' refresh; hb buff ' ..settings.char4.. ' refresh')
		end
		
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('stage ambu')
		end
		ipcflag = false
	elseif cmd2 == 'ambu2' then
		if player_job.main_job == 'RDM' then
			windower.send_command('hb f off; hb as off; hb off')
		end
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('stage ambu2')
		end
		ipcflag = false
	elseif cmd2 == 'ody' then
		windower.send_command('lua r gazecheck')
		windower.send_command('input /autotarget on')
		if player_job.main_job == 'WHM' then
			windower.send_command('wait 1.5; gs c set castingmode DT; gs c set idlemode DT; gaze ap off; hb buff ' .. settings.char1 .. ' haste; hb buff ' .. settings.char2 .. ' haste; hb buff ' .. settings.char1 .. ' regen4; hb ignore_debuff all poison')
		elseif player_job.main_job == 'RUN' then
			windower.send_command('wait 1.5; gaze ap off; gs c set runeelement sulpor;')
		elseif player_job.main_job == 'BRD' then
			windower.send_command('wait 1.5; gs c set idlemode DT; gaze ap off; sing pl melee; sing n off; sing p on; hb buff ' .. settings.char3 .. ' haste; hb buff ' .. settings.char6 .. ' haste;')
		elseif player_job.main_job == 'COR' then
			windower.send_command('wait 1.5; roll melee; gaze ap on;')
		elseif player_job.main_job == 'SAM' or player_job.main_job == 'DRK' then
			windower.send_command('wait 1.5; gaze ap on;')
		elseif player_job.main_job == 'WAR' or player_job.main_job == 'DRG' then
			windower.send_command('wait 1.5; gaze ap on; gs c set weapons Naegling;')
		end
		
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('stage ody')
		end
		ipcflag = false
	elseif cmd2 == 'shin' then
		windower.send_command('lua r gazecheck;')
		if player_job.main_job == 'WHM' then
			windower.send_command('wait 2; gaze ap off; hb buff <me> barfira; gs c set castingmode DT; gs c set idlemode DT;')
		elseif player_job.main_job == 'RUN' then
			windower.send_command('wait 2; gs c set runeelement lux; gs c set autobuffmode auto; gs c set hybridmode DTLite;')
		elseif player_job.main_job == 'BRD' then
			windower.send_command('wait 2; gaze ap off; sing pl shin; sing n on; sing p on;')
		elseif player_job.main_job == 'THF' then
			windower.send_command('wait 2; gs c set treasuremode fulltime; gs c set weapons TH;')
		elseif player_job.main_job == 'SAM' or player_job.main_job == 'DRK' or player_job.main_job == 'MNK' then
			windower.send_command('wait 2; gaze ap on;')
		elseif player_job.main_job == 'SCH' then
			windower.send_command('wait 2; gs c set elementalmode light; gs c set castingmode DT; gs c set idlemode DT; hb enable cure; hb enable na;')
		end
		
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('stage shin')
		end
		ipcflag = false
	elseif cmd2 == 'kalunga' then
		if player_job.main_job == 'WHM' then
			windower.send_command('hb buff <me> barfira; gs c set castingmode DT; gs c set idlemode DT; hb debuff dia2; hb disable erase; hb buff ' ..settings.char1.. ' haste; hb buff ' ..settings.char1.. ' shell5; hb buff ' .. settings.char2 .. ' haste; hb buff ' .. settings.char3 .. ' haste;')
		elseif player_job.main_job == 'RUN' then
			windower.send_command('gs c set runeelement unda; gs c set autobuffmode auto; hb buff <me> barfire')
		elseif player_job.main_job == 'BRD' then
			windower.send_command('sing pl kalunga; sing n on; sing p on; gs c set idlemode DT; sing sirvente ' ..settings.char1)
		elseif player_job.main_job == 'GEO' then
			windower.send_command('gs c autoindi barrier; gs c autogeo fury; gs c autoentrust refresh; gs c set castingmode DT; gs c set idlemode DT;')
		elseif player_job.main_job == 'SAM' then
			windower.send_command('gs c set hybridmode DT; gs c set weaponskillmode Emnity')
		elseif player_job.main_job == 'COR' then
			windower.send_command('roll melee;')
			windower.send_command('gs c set weapons Naegling;')
		end
		
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('stage kalunga')
		end
		ipcflag = false
	elseif cmd2 == 'arebati' then
		if player_job.main_job == 'SCH' or player_job.main_job == 'WHM' then
			windower.send_command('gs c set autoapmode off; hb disable erase; hb buff ' ..settings.char1.. ' haste; hb buff ' ..settings.char1.. ' shell5;')
			if player_job.main_job == 'SCH' then
				windower.send_command('mc sch heal;  hb buff ' .. settings.char1 .. ' regen5;')
			else
				windower.send_command('hb buff ' .. settings.char1 .. ' regen4;')
			end
		elseif player_job.main_job == 'RUN' then
			windower.send_command('gs c set runeelement ignis; hb buff <me> barblizzard')
		elseif player_job.main_job == 'BRD' then
			windower.send_command('sing pl arebati; sing n on; sing p on; gs c set idlemode DT; sing sirvente ' ..settings.char1)
		elseif player_job.main_job == 'GEO' then
			windower.send_command('gs c autoindi fury; gs c autogeo agi; gs c autoentrust refresh; gs c set castingmode DT; gs c set idlemode DT;')
		elseif player_job.main_job == 'RNG' then
			windower.send_command('gs c set weapons Fomalhaut; gs c set rnghelper on; wait 2; gs c autows Last Stand;')
		elseif player_job.main_job == 'COR' then
			windower.send_command('roll melee; gs c set weapons Fomalhaut; gs c set rnghelper on; wait 2; gs c autows Last Stand;')
		end
		
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('stage arebati')
		end
		ipcflag = false
	elseif cmd2 == 'xev' then
		windower.send_command('autoitem on')
		if player_job.main_job == 'WHM' then
			windower.send_command('hb buff <me> baraera; gs c set castingmode DT; gs c set idlemode DT; hb debuff dia2; hb disable na;')
			windower.send_command('input /p Haste all')
		elseif player_job.main_job == 'WAR' then
			windower.send_command('gs c set weapons ShiningOne; gaze ap on')
		elseif player_job.main_job == 'BRD' then
			windower.send_command('sing pl xev; sing n on; sing p on; gs c set weapons Aeneas; gaze ap on')
		elseif player_job.main_job == 'GEO' then
			windower.send_command('gs c autoindi attunement; gs c autogeo fury; gs c autoentrust barrier; gs c set castingmode DT; gs c set idlemode DT;')
		elseif player_job.main_job == 'DNC' then
			windower.send_command('gaze ap on')
		elseif player_job.main_job == 'COR' then
			windower.send_command('roll melee; gaze ap on')
			windower.send_command('gs c autows Last Stand; gs c set weapons RostamFH;')
		end
		
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('stage xev')
		end
		ipcflag = false
	elseif cmd2 == 'bumba' then
		windower.send_command('lua r gazecheck; wait 2; gaze ap on')
		if player_job.main_job == 'WHM' then
			windower.send_command('hb buff <me> barblizzara; hb buff <me> barparalyzra; hb disable na; gs c set castingmode DT; gs c set idlemode DT; hb debuff dia2; hb as attack off; hb buff <me> auspice')
			windower.send_command('wait 2; gaze ap off')
		elseif player_job.main_job == 'WAR' or player_job.main_job == 'DRG' then
			windower.send_command('gs c set weapons Naegling;')
		elseif player_job.main_job == 'BRD' then
			windower.send_command('sing pl bumba; sing n on; sing p on; gs c set idlemode DT; gs c set hybridmode DT; gs c set weapons Naegling; gs c autows Savage Blade')
		elseif player_job.main_job == 'GEO' then
			windower.send_command('gs c autoindi haste; gs c autogeo fury; gs c autoentrust fend; gs c set castingmode DT; gs c set idlemode DT;')
		elseif player_job.main_job == 'COR' then
			windower.send_command('roll roll1 sam; roll roll2 fighter')
			windower.send_command('gs c set weapons Naegling;')
		end
		
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('stage bumba')
		end
		ipcflag = false
	elseif cmd2 == 'mboze' then
		windower.send_command('gaze ap off')
		if player_job.main_job == 'WHM' then
			windower.send_command('hb buff <me> barstonra; hb buff <me> barpetra; gs c set castingmode DT; gs c set idlemode DT; hb debuff dia2; hb buff <me> auspice')
			windower.send_command('input /p Haste DRK')
		elseif player_job.main_job == 'DRK' then
			windower.send_command('gs c set weapons KajaChopper; gs c set hybridmode SubtleBlow; gs c set weaponskillmode SubtleBlow')
		elseif player_job.main_job == 'BRD' then
			windower.send_command('sing pl sv5; sing n off; sing p off; sing debuffing off; gs c set idlemode DT; sing debuff wind threnody 2')
			windower.send_command('input /p Piano WHM BLU SMN')
		elseif player_job.main_job == 'BLU' then
			windower.send_command('gs c set autobuffmode auto; gs c set AutoBLUSpam on; gs c set weapons MACC;')
			windower.send_command('input /p Check buff+spam modes')
		elseif player_job.main_job == 'COR' then
			windower.send_command('roll melee')
			windower.send_command('gs c set CompensatorMode always')
		elseif player_job.main_job == 'SMN' then
			windower.send_command('input /p Ifrit, Garuda, Shiva, toggle automodes')
		end
		
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('stage mboze')
		end
		ipcflag = false
	elseif cmd2 == 'ngai' then
		windower.send_command('gaze ap off')
		if player_job.main_job == 'WHM' then
			windower.send_command('hb disable erase; hb buff <me> barwatera; hb buff <me> barsleepra; gs c set castingmode DT; gs c set idlemode DT; hb debuff dia2; hb buff <me> auspice; hb buff ' ..settings.char1.. ' haste')
		elseif player_job.main_job == 'MNK' then
			windower.send_command('gs c set hybridmode Tank; gs c set weaponskillmode tank')
		elseif player_job.main_job == 'BRD' then
			windower.send_command('sing pl ngai; sing n on; sing p on; sing debuffing off; gs c set weapons Carnwenhan')
		elseif player_job.main_job == 'DNC' then
			--windower.send_command('')
		elseif player_job.main_job == 'COR' then
			windower.send_command('roll melee')
			windower.send_command('gs c set weapons Naegling')
		elseif player_job.main_job == 'SMN' then
			windower.send_command('gs c set idlemode DT;')
		end
		
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('stage ngai')
		end
		ipcflag = false
	elseif cmd2 == 'lil' then
		if player_job.main_job == 'WHM' then
			windower.send_command('hb buff <me> barstonra; hb buff <me> barpetra; gs c set castingmode DT; gs c set idlemode DT; hb buff <me> auspice; hb disable erase;')
		elseif player_job.main_job == 'BRD' then
			windower.send_command('sing pl lil; sing n on; sing p off; sing debuffing off; gs c set idlemode DT; gs c set hybridmode DT;')
		elseif player_job.main_job == 'THF' then
			windower.send_command('hb debuff bio')
		elseif player_job.main_job == 'COR' then
			windower.send_command('roll roll1 sam; roll roll2 allies')
		elseif player_job.main_job == 'GEO' then
			windower.send_command('gs c autogeo str; gs c autoindi fury; gs c autoentrust haste; gs c set castingmode DT; gs c set idlemode DT;')
		end
		
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('stage lil')
		end
		ipcflag = false
	elseif cmd2 == 'alex' then
		-- PLD, WHM/SCH, BRD/NIN, THF/WAR, COR/NIN, GEO/RDM
		windower.send_command('gaze ap on')
		if player_job.main_job == 'WHM' then
			windower.send_command('hb buff <me> barstonra; hb buff <me> barpetra; gs c set castingmode DT; gs c set idlemode DT; hb buff <me> auspice; hb disable na;')
			windower.send_command('input /p Haste WAR')
			windower.send_command('gaze ap off')
		elseif player_job.main_job == 'BRD' then
			windower.send_command('sing pl alex; sing p off; sing debuffing off; gs c set idlemode DT; gs c set hybridmode DT; gs c set weapons DualSavage; gs c autows Savage Blade;')
		elseif player_job.main_job == 'THF' then
			windower.send_command('gs c set hybridmode HybridMEVA; gs c set weapons Naegling; gs c set treasuremode fulltime')
		elseif player_job.main_job == 'COR' then
			windower.send_command('roll melee')
		elseif player_job.main_job == 'GEO' then
			windower.send_command('gs c autogeo fury; gs c autoindi refresh; gs c autoentrust haste; gs c set castingmode DT; gs c set idlemode DT;')
			windower.send_command('input /p Haste COR')
			windower.send_command('gaze ap off')
		end
		
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('stage alex')
		end
		ipcflag = false
	elseif cmd2 == 'ouryu' then
		windower.send_command('gaze ap on')
		if player_job.main_job == 'WHM' then
			windower.send_command('hb buff <me> barstonra; hb buff <me> barpetra; gs c set castingmode DT; gs c set idlemode DT; hb buff <me> auspice;')
		elseif player_job.main_job == 'RUN' then
			windower.send_command('gaze ap off; gs c set runeelement flabra')
		elseif player_job.main_job == 'BRD' then
			windower.send_command('sing pl ouryu; hb debuff dia2')
		elseif player_job.main_job == 'GEO' then
			windower.send_command('gs c set castingmode DT; gs c set idlemode DT; gs c autoentrust attunement')
		end
		
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('stage ouryu')
		end
		ipcflag = false
	elseif cmd2 == 'gog' then
		windower.send_command('autoitem off')
		if player_job.main_job == 'RDM' then
			windower.send_command('gaze ap off; mc haste; dsmall; hb buff ' .. settings.char3 .. ' refresh3; hb buff ' .. settings.char4 .. ' refresh3;')
		elseif player_job.main_job == 'PUP' then
			windower.send_command('gs c set hybridmode HybridPET; gs c set petmode melee; input /ja "Activate" <me>;')
		elseif player_job.main_job == 'BLU' then
			windower.send_command('azuresets set melee; gs c set weapons magic;')
		elseif player_job.main_job == 'MNK' then
			windower.send_command('gs c set hybridmode Tank; gs c set weaponskillmode tank')
		elseif player_job.main_job == 'THF' then
			windower.send_command('gs c weapons KajaKnuckles;')
		elseif player_job.main_job == 'WAR' then
			windower.send_command('gs c weapons Loxotic;')
		end
		
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('stage gog')
		end
		ipcflag = false
	elseif cmd2 == 'dae' then
		windower.send_command('autoitem off')
		if player_job.main_job == 'SCH' then
			windower.send_command('hb enable cure; hb enable na; hb buff <me> reraise; hb disable erase; hb buff <me> aurorastorm2;')
		elseif player_job.main_job == 'SAM' then
			windower.send_command('gs c set weapons ShiningOne')
		elseif player_job.main_job == 'BST' then
			windower.send_command('gs c set weapons Kaja; gs c set jugmode GenerousArthur; gs c toggle AutoCallPet')
		end
		
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('stage dae')
		end
		ipcflag = false
	else
		atc('nothing specified')
	end
end

function jc(cmd2)
	local player_job = windower.ffxi.get_player()

	-- First from 3rd.
	if cmd2 == 'ody' then
		if player_job.name == "" ..settings.char1.. "" then
			windower.send_command("jc run/drk" )
		elseif player_job.name == "" ..settings.char2.. "" then
			windower.send_command("jc sam/war" )
		elseif player_job.name == "" ..settings.char3.. "" then
			windower.send_command("jc drk/sam" )
		elseif player_job.name == "" ..settings.char4.. "" then
			windower.send_command("jc brd/rdm")
		elseif player_job.name == "" ..settings.char5.. "" then
			windower.send_command("jc whm/sch")
		elseif player_job.name == "" ..settings.char6.. "" then
			windower.send_command("jc cor/nin")
		end
		
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('jc ody')
		end
		ipcflag = false
	else
		atc('nothing specified')
	end
end


function wsall()
	atc("WSALL!")
	local player_job = windower.ffxi.get_player()
	local MeleeJobs = S{'WAR','SAM','DRG','DRK','NIN','MNK','COR','BLU','PUP','DNC','RUN','BRD','THF','RNG','PLD','GEO','BST'}
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
				windower.send_command('input /ws \'Expaciation\' <t>')
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
			elseif player_job.main_job == "BST" then
				windower.send_command('input /ws \'Calamity\' <t>')
			elseif player_job.main_job == "GEO" then
				windower.send_command('input /ws \'Black Halo\' <t>')
			end
		
	end
end

function cc()
	local player_job = windower.ffxi.get_player()
	local SleepJobs = S{'BRD','BLM','RDM','GEO'}
	local SleepSubs = S{'BLM','RDM'}
	if SleepJobs:contains(player_job.main_job) then
		
		if player_job.main_job == "BRD" then
			atcwarn("CC: Horde Lullaby.")
			windower.send_command('input /ma \'Horde Lullaby II\' <t>')
		elseif player_job.main_job == "BLM" then
			atcwarn("CC: Sleepga II.")
			windower.send_command('input /ma \'Sleepga II\' <t>')
		elseif player_job.main_job == "RDM" then
			if player_job.sub_job == "BLM" then
				atcwarn("CC: Sleepga.")
				windower.send_command('input /ma \'Sleepga\' <t>')
			end
		elseif player_job.main_job == "GEO" then
			if player_job.sub_job == "BLM" then
				atcwarn("CC: Sleepga.")
				windower.send_command('input /ma \'Sleepga\' <t>')
			end
		end
	else
		atcwarn("CC: Non sleepable jobs, skipping.")
	end
end

function mnt()
	windower.send_command('input /mount \'Red Crab\'')
end

function dis()
	windower.send_command('input /dismount')
end

function on()
	atc('ON: Turning on addons.')
	local zone = windower.ffxi.get_info()['zone']
	local world = res.zones[windower.ffxi.get_info().zone].name
	local di_zones = S{288,289,291}
		
	local player_job = windower.ffxi.get_player()
	local MeleeJobs = S{'WAR','SAM','DRG','DRK','NIN','MNK','COR','BLU','PUP','DNC','RUN','THF','RNG','PLD','BST','GEO','BRD'}
	local MageJobs = S{'WHM','BLM','SCH','RDM','SMN','GEO','BRD'}

	if di_zones:contains(zone) then
		atc('ON: Domain Invasion zone, removing mobilization')
		windower.send_command('cancel mobilization')
	end

	if not(areas.Cities:contains(world)) then
	
		windower.send_command('hb on')
		
		if MageJobs:contains(player_job.main_job) then
			if player_job.main_job == "SCH" then
				if autoarts == 'Light' then
					windower.send_command('gs c set autobuffmode Healing')
				elseif autoarts == 'Dark' then
					windower.send_command('gs c set autobuffmode Nuking')
				else
					windower.send_command('gs c set autobuffmode auto')
				end
			else
				windower.send_command('gs c set autobuffmode auto')
			end
		end

		if player_job.main_job == "RUN" then
			windower.send_command('gs c set autorunemode on')
		elseif player_job.main_job == "BRD" then
			windower.send_command('singer on')
		elseif player_job.main_job == "COR" then
			windower.send_command('roller on')
		elseif player_job.main_job == "SCH" then
			windower.send_command('gs c set autosubmode on')
		elseif player_job.main_job == "RDM" then
			windower.send_command('gs c set autoarts on;')
			windower.send_command('input /ja composure <me>')
		elseif player_job.main_job == "WHM" then
			windower.send_command('gs c set autoarts on;')
		elseif player_job.main_job == "DNC" then
			windower.send_command('gs c toggle autosambamode')
			windower.send_command('gs c set autobuffmode auto')
		elseif player_job.main_job == "PUP" then
			windower.send_command('gs c set autopuppetmode on')
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
		
		if player_job.sub_job == "RUN" then
			windower.send_command('gs c set autorunemode on')
		end
		
		-- WS/Buff mode
		if MeleeJobs:contains(player_job.main_job) then
			if settings.autows then
				windower.send_command('gs c set autowsmode on; gs c set autobuffmode auto;')
				if player_job.main_job == "DRG" or player_job.sub_job == "DRG" then
					windower.send_command('gs c set autojumpmode on;')
				end
			end
			if settings.rangedmode then
				if player_job.main_job == "COR" or player_job.main_job == "RNG" then
					windower.send_command('gs c set rnghelper on;')
				end
			end
		else
			if settings.autows then
				windower.send_command('gs c set autowsmode on;')
			end
		end
	else
		atc('ON: Indoor zone: ' .. world .. ' - skipping')
	end
end

function off()
	atc('OFF: Turning off addons.')
	local player_job = windower.ffxi.get_player()
	if player_job.main_job == "GEO" then
		windower.send_command('geo off')
	elseif player_job.main_job == "RUN" then
		windower.send_command('gs c set autorunemode off')
		windower.send_command('gs c set autotankmode off')
	elseif player_job.main_job == "PLD" then
		windower.send_command('gs c set autorunemode off')
		windower.send_command('gs c set autotankmode off')
		windower.send_command('gs c set autotankfull off')
	elseif player_job.main_job == "DRG" or player_job.sub_job == "DRG" then
		windower.send_command('gs c set autojumpmode off')
	elseif player_job.main_job == "RNG" or player_job.main_job == "COR" then
		windower.send_command('gs c set rnghelper off')
	elseif player_job.main_job == "RDM" then
		windower.send_command('gs c set autoarts off')
	elseif player_job.main_job == "WHM" then
		windower.send_command('gs c set autosubmode off')
	elseif player_job.main_job == "SMN" then
		windower.send_command('gs c set autowardmode off; gs c set autobpmode off')
	elseif player_job.main_job == "SCH" then
		windower.send_command('gs c set autoapmode off')
	elseif player_job.main_job == "PUP" then
		windower.send_command('gs c set autopuppetmode off')
	elseif player_job.main_job == "BST" then
		windower.send_command('gs c set autocallpet off')
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
	windower.send_command('gs c set autoarts off')
end

function fon()
	atc('FON: Follow ON.')
	currentPC=windower.ffxi.get_player()
	
		windower.send_command('hb follow off')
		windower.send_command('hb f dist 2')
	
		for k, v in pairs(windower.ffxi.get_party()) do
			
				if type(v) == 'table' then
					if v.name ~= currentPC.name then
						ptymember = windower.ffxi.get_mob_by_name(v.name)
						-- check if party member in same zone.
						if v.mob == nil then
							-- Not in zone.
							atc('FON: ' .. v.name .. ' is not in zone, not following.')
						else
							if ptymember.valid_target then
								windower.send_command('send ' .. v.name .. ' hb f dist 2')
								windower.send_command('send ' .. v.name .. ' hb follow ' .. currentPC.name)
							else
								atc('FON: ' .. v.name .. ' is not in range, not following.')
							end
						end
					end
				end
		end
end

function foff()
	atc('FOFF: Follow OFF')
	windower.send_command('hb follow off')
end

function unload(addonarg)
	atc('UNLOAD: Unloading Specific ADDON.')
	windower.send_command('lua u ' ..addonarg)
end

function reload(addonarg)
	atc('RELOAD: Reload Specific ADDON.')
	if addonarg == 'multictrl' then
		atcwarn('RELOAD: Not supported!')
	else
		windower.send_command('lua r ' ..addonarg)
	end
end

function fin()
	atc('FIN: Dispel/Finale.')
	local player_job = windower.ffxi.get_player()
	if player_job.main_job == "BRD" then
		windower.send_command('fin <t>')
	elseif player_job.main_job == "RDM" or player_job.sub_job == "RDM" then
		windower.send_command('dis <t>')
	end
end

function nitro()
	atc('NITRO')
	local player_job = windower.ffxi.get_player()
	if player_job.main_job == "BRD" then
		windower.send_command('input /ja "Nightingale" <me>; wait 1.5; input /ja "Troubadour" <me>')
	else
		atc('Not BRD')
	end
end

function sv5()
	atc('SV5')
	local player_job = windower.ffxi.get_player()
	if player_job.main_job == "BRD" then
		windower.send_command('sing off; sing pl sv5; gs c set autozergmode on')
	else
		atc('Not BRD')
	end
end

function brd(cmd2)
	atc('BRD')
	local player_job = windower.ffxi.get_player()
	if player_job.main_job == "BRD" then
		if cmd2 == 'ambu' then
			atc('BRD: Ambu')
			windower.send_command("hb buff " ..settings.char1.. " mage's ballad III; hb buff " ..settings.char1.. "  sentinel's scherzo;")
		elseif cmd2 == 'ody' then
			atc('BRD: Odyssey')
			windower.send_command("hb buff " ..settings.char1.. " sentinel's scherzo; hb buff " ..settings.char1.. " foe sirvente; hb buff " ..settings.char1.. " scop's operetta; hb buff " ..settings.char1.. " victory march")
		elseif cmd2 == 'reset' then
			atc('BRD: Reset')
			windower.send_command("hb cancelbuff " ..settings.char1.. " mage's ballad III; hb cancelbuff " ..settings.char1.. " mage's ballad II; hb cancelbuff " ..settings.char1.. " sentinel's scherzo; hb cancelbuff " ..settings.char1.. " foe sirvente; hb cancelbuff " ..settings.char1.. " scop's operetta; hb cancelbuff " ..settings.char1.. " victory march")
		else
			atc('BRD: Invalid command')
		end
	else
		atc('Not BRD')
	end
end

function sch(cmd2)
	local player_job = windower.ffxi.get_player()
	if player_job.main_job == "SCH" then
		if cmd2 == 'heal' then
			atc('SCH Stance: Healing')
			autoarts='Light'
			windower.send_command('gs c set autoarts light; hb enable cure; hb enable curaga; hb enable na; wait 2; gs c set autobuffmode Healing')
		elseif cmd2 == 'nuke' then
			atc('SCH Stance: Nuking')
			autoarts='Dark'
			windower.send_command('gs c set autoarts dark; hb disable cure; hb disable curaga; hb disable na; wait 2; gs c set autobuffmode Nuking')
		else
			atc('SCH Stance: No parameter specified')
		end
	else
		atc('SCH Stance: Not SCH')
	end
end

function lotall()
	windower.send_command('tr lotall;')
end

function ws(cmd2)
	if cmd2 == 'off' then
		atc('WS: AutoWS DISABLED')
		settings.autows = false
		windower.send_command('gs c set autowsmode off')
	elseif cmd2 == 'on' then
		atc('WS: AutoWS ACTIVE')
		settings.autows = true
		windower.send_command('gs c set autowsmode on')
	end
	display_box()
end

function sleep(cmd2)
	local player_job = windower.ffxi.get_player()
	if cmd2 == 'off' then
		if player_job.sub_job == "SCH" then
			if player_job.main_job ~= "RDM" then
				windower.send_command('gs c set autosubmode on')
			end
		end
		atc('SLEEP: AntiSleep DISABLED')
		settings.antisleep = false
	elseif cmd2 == 'on' then
		if player_job.sub_job == "SCH" then
			if player_job.main_job ~= "RDM" then
				windower.send_command('gs c set autosubmode sleep')
			end
		end
		atc('SLEEP: AntiSleep ACTIVE')
		settings.antisleep = true
	end
	display_box()
end

function food()
	local MeleeJobs = S{'WAR','SAM','DRG','NIN','MNK','COR','BLU','DNC','THF','RNG'}
	local MeleeJobsAcc = S{'DRK','PUP','BST'}
	local Tanks = S{'RUN','PLD'}
	
	local player_job=windower.ffxi.get_player()
	
	if MeleeJobs:contains(player_job.main_job) then
		atc("FOOD: Grape Daifuku")
		windower.send_command('input /item "Grape Daifuku" <me>')
	elseif MeleeJobsAcc:contains(player_job.main_job) then
		atc("FOOD: Sublime Sushi")
		windower.send_command('input /item "Sublime Sushi" <me>')
	elseif Tanks:contains(player_job.main_job) then
		atc("FOOD: Om. Sandwich")
		windower.send_command('input /item "Om. Sandwich" <me>')
	else
	
	end
	
end

-- if cmd2 == 'off' then
	-- atc('AutoFood DISABLED')
	-- settings.autofood = false
-- elseif cmd2 == 'on' then
	-- atc('Autofood ACTIVE')
	-- settings.autofood = true
-- end
-- display_box()

function rng(cmd2)
	if cmd2 == 'off' then
		atc('RNG Helper DISABLED')
		settings.rangedmode = false
	elseif cmd2 == 'on' then
		atc('RNG Helper ACTIVE')
		settings.rangedmode = true
	end
	display_box()
end


function buy(cmd2)

	if cmd2 == 'on' then
		atc('Turning on BUY function, loading addons')
		settings.buy = true
		windower.send_command('lua r powder; wait 1; lua r sparks; wait 1; lua r sellnpc')
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('buy on')
		end
		ipcflag = false
	elseif cmd2 == 'off' then
		atc('Shutting off BUY function, unloading addons')
		settings.buy = false
		windower.send_command('lua u powder; wait 1; lua u sparks; wait 1')
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('buy off')
		end
		ipcflag = false
	end
	
	if settings.buy then
	-- ACTIVE
		if (cmd2 == 'shield') then
			atc('Buying SINGLE CHAR SHIELD!')
			--coroutine.sleep(5)
			windower.send_command('sparks buyall acheron shield')		
		elseif (cmd2 == 'powder' and settings.buy == true) then
			atc('Buying powders!')
			windower.send_command('powder buy 3315; wait 10; fa prize powder')
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
			windower.send_command('input /lockon; wait 1; setkey enter down; wait 0.5; setkey enter up; wait 10; fa prize powder')
			if ipcflag == false then
				ipcflag = true
				windower.send_ipc_message('buy sp')
			end
			ipcflag = false	
		elseif (cmd2 == 're' and settings.buy == true) then
			windower.send_command('buy re')
			
			windower.send_command('lua r sparks; wait 0.5; lua r powder; wait 10; fa acheron shield')

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
	atc('Buffing Up!')
	local player_job = windower.ffxi.get_player()
	local buff_jobs = S{"WHM","RDM","GEO","BRD","SMN","BLM","SCH","RUN"}
	if buff_jobs:contains(player_job.main_job) then
		windower.send_command('gs c buffup')
	end
end

function gettarget(term)
	if (term ~= nil) then
		local targetid = windower.ffxi.get_mob_by_name('' .. term .. '')
		atc('Get Target: ' .. term .. ' ID: ' .. targetid.id)
		windower.send_command('settarget ' .. targetid.id)
	else
		atc('No target specified!')
	end
end

function fight()
	atc('Fight distance.')
	local player_job = windower.ffxi.get_player()
	if player_job.main_job == "WHM" then
		windower.send_command('hb f dist 18;')
	elseif player_job.main_job == "GEO" or player_job.main_job == "BRD" then
		windower.send_command('hb f dist 2.3')
	elseif player_job.main_job == "SMN" or player_job.main_job == "BLM" or player_job.main_job == "SCH" or player_job.main_job == "RDM" then
		windower.send_command('hb f dist 19')
	else
		windower.send_command('hb f dist 1.9')
	end
end

function fightmage()
	atc('Fight MAGE distance.')
	local player_job = windower.ffxi.get_player()
	local mage_jobs = S{"WHM","RDM","GEO","BRD","SMN","BLM","SCH","COR"}
	
	if mage_jobs:contains(player_job.main_job) then
		windower.send_command('hb f dist 19.5;')
	else
		windower.send_command('hb f dist 3.5')
	end
end

function fightsmall()
	atc('Close quarters fight distnace.')
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
		atc('Sending all chars: \"' .. commands .. '\"')
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
		atc('FPS is 30')
		windower.send_command('config FrameRateDivisor 2')
	elseif cmd2 == "60" then
		atc('FPS is 60')
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
			atc('Assisting this char - Melee ONLY')
			ipcflag = true
			windower.send_command('hb assist off')
			windower.send_command('hb assist attack off')
			windower.send_ipc_message('assist melee ' .. currentPC.name)
		elseif ipcflag == true then
			local player_job = windower.ffxi.get_player()
			local MeleeJobs = S{'WAR','SAM','DRG','DRK','NIN','MNK','COR','BLU','PUP','DNC','RUN','PLD','THF','BST','RNG'}		
			if MeleeJobs:contains(player_job.main_job) then
				atc('Assist & Attack -> ' ..namearg)
				windower.send_command('hb assist ' .. namearg)
				windower.send_command('hb f ' .. namearg)
				windower.send_command('wait 0.5; hb assist attack on')
				windower.send_command('wait 0.5; hb on')
			else
				atc('Disabling assist, not melee job.')
				windower.send_command('hb assist off')
				windower.send_command('hb assist attack off')
			end
		end
	elseif cmd == 'mag' then
	
		if ipcflag == false then
			atc('Assisting this char - Melee+Mage BRD')
			ipcflag = true
			windower.send_command('hb assist off')
			windower.send_command('hb assist attack off')
			windower.send_ipc_message('assist mag ' .. currentPC.name)
		elseif ipcflag == true then
			local player_job = windower.ffxi.get_player()
			local MeleeJobs = S{'WAR','SAM','DRG','DRK','NIN','MNK','COR','BLU','PUP','DNC','RUN','PLD','THF','BST','RNG','BRD'}		
			if MeleeJobs:contains(player_job.main_job) then
				atc('Assist & Attack -> ' ..namearg)
				windower.send_command('hb assist ' .. namearg)
				windower.send_command('hb f ' .. namearg)
				windower.send_command('wait 0.5; hb assist attack on')
				windower.send_command('wait 0.5; hb on')
			else
				atc('Disabling assist, not melee job.')
				windower.send_command('hb assist off')
				windower.send_command('hb assist attack off')
			end
		end
	elseif cmd == 'all' then
		if ipcflag == false then
			atc('Assisting this char - ALL JOBS')
			ipcflag = true
			windower.send_command('hb assist off')
			windower.send_command('hb assist attack off')
			windower.send_ipc_message('assist all ' .. currentPC.name)
		elseif ipcflag == true then
			atc('Assist & Attack -> ' .. namearg)
			windower.send_command('hb assist ' .. namearg)
			windower.send_command('wait 0.5; hb assist attack on')
		end
	elseif cmd == 'on' then
		if ipcflag == false then
			atc('Leader for assisting in spells.')
			ipcflag = true
			windower.send_command('hb assist off')
			windower.send_command('hb assist attack off')
			windower.send_ipc_message('assist on ' .. currentPC.name)
		elseif ipcflag == true then
			atc('Assist ONLY -> ' ..namearg)
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
						atc(v.name .. ' is not in zone, skipping')
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
											atc('Resting for MP')
											windower.send_command('input /heal')
											coroutine.sleep(3)
										else -- idle
											atc('Resting for MP')
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
								atc('Warping ' .. v.name)
								
								--Check if still casting		
								while isCasting do
									coroutine.sleep(0.5)
								end

						else
							atc(v.name .. ' is too far to warp, skipping')
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
						atc('Resting for MP')
						windower.send_command('input /heal')
						coroutine.sleep(3)
					else -- idle
						atc('Resting for MP')
						windower.send_command('input /heal')
						coroutine.sleep(3)
					end
					isWaiting = true
				end
			end
			
		end

		coroutine.sleep(1.1)
		atc('Warping')
		windower.send_command('input /ma "Warp" ' .. currentPC.name)
		
	else
		atc('Not BLM main or sub or no warp spells!')
	end
	
end


function buyshields()

	player = windower.ffxi.get_player()
	get_spells = windower.ffxi.get_spells()
	
	atc('Starting buying SHIELDS!')
	
	for k, v in pairs(windower.ffxi.get_party()) do
	
		if type(v) == 'table' then
			if v.name ~= currentPC.name then
			
				coroutine.sleep(2)
			
				ptymember = windower.ffxi.get_mob_by_name(v.name)
				-- check if party member in same zone.

				if v.mob == nil then
					-- Not in zone.
					atc(v.name .. ' is not in zone, skipping buying shields.')
					coroutine.sleep(0.5)
				else
					-- In zone, do distance check
					if math.sqrt(ptymember.distance) < 8  and windower.ffxi.get_mob_by_name(v.name).in_party then
						coroutine.sleep(1.63)
						windower.send_command('send ' .. v.name .. ' sparks buyall acheron shield')
						atc('Buying shields for: ' .. v.name)
						coroutine.sleep(45)
					else
						atc(v.name .. ' is too far to buy shields with sparks, skipping')
						coroutine.sleep(0.5)
					end
				end
			end
		end
	end

	-- Buy shield for self
	windower.send_command('sparks buyall acheron shield')
	coroutine.sleep(42)
	atc('DONE!')
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
				atc('Invalid Avatar choice')
			end
		else
			atc('Missing argument for Avatar')
		end
		
	elseif cmd2 == 'on' then
		settings.active = true
		windower.add_to_chat(11,'Usage: //mc burn Command Variable \n')
		windower.add_to_chat(11,'\ ')
		windower.add_to_chat(11,'-Commands- \ \ \ -Variables- \n')
		windower.add_to_chat(11,'\ ')
		windower.add_to_chat(11,'\ avatar \ \ \ \ \ \ \ \ \ ramuh/ifrit')
		windower.add_to_chat(11,'\ dia \ \ \ \ \ \ \ \ \ \ \ \ \ on/off')
		windower.add_to_chat(11,'\ indi \ \ \ \ \ \ \ \ \ \ \ \ torpor/malaise')
		windower.add_to_chat(11,'\ assist \ \ \ \ \ \ \ \ \ \ name of character that is engaging mob')
		windower.add_to_chat(11,'\ init \ \ \ \ \ \ \ \ \ \ \ \ *** Intializes commands to all chars, MUST RUN THIS AFTER setting variables. ***')
	elseif cmd2 == 'off' then
		settings.active = false
		
	elseif cmd2 == 'dia' then
		if cmd3 ~= nil then
			if cmd3 == 'on' then
				settings.dia = true
			elseif cmd3 == 'off' then
				settings.dia = false
			else
				atc('Invalid DIA choice')
			end
		else
			atc('Missing argument for DIA')
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
			atc('Missing argument for INDI')
		end
	elseif cmd2 == 'init' then
		
		if settings.assist == '' then
			atc('Cannot initialize until you set assist name')
		else
			for k, v in pairs(windower.ffxi.get_party()) do
				if type(v) == 'table' then
					if string.lower(v.name) == string.lower(settings.assist) then
						if v.mob == nil then
							-- Not in zone.
							atc(v.name .. ' is not in zone, HB will NOT assist if player is not in zone.  Try again later.')
						
						else
							atc('Initialize HB and assist, and disabled cures')
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
							atc(v.name .. ' is not in zone, HB will NOT assist if player is not in zone.  Try again later.')
						
						else
							atc('You are now assisting ' ..cmd3)
							settings.assist = cmd3
						end
					end
				end
			end
			
		else
			atc('Missing argument for ASSIST')
		end
	else
		atc('Invalid command')
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
			atc('Helper for SMN BPing DISABLED')
			settings.smnhelp = false
				if ipcflag == false then
				ipcflag = true
				windower.send_ipc_message('smnhelp')
			end
			ipcflag = false
		else
			atc('Helper for SMN BPing ACTIVE')
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
				atc('SMN Skillchain DISABLED')
				settings.smnsc = false
					if ipcflag == false then
					ipcflag = true
					windower.send_ipc_message('smnhelp SC')
				end
				ipcflag = false
			else
				atc('SMN Skillchain ACTIVE')
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
			atc('Helper for Ranged SC DISABLED')
			settings.rngsc = false
				if ipcflag == false then
				ipcflag = true
				windower.send_ipc_message('rngsc')
			end
			ipcflag = false
		else
			atc('Helper for Ranged SC ACTIVE')
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
		atc('Check GEO for burn.')
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
			atc('Not GEO job, skipping')
		end
	else
		atc('OneHour BURN not active!')
	end
end

function smnburn()

	player = windower.ffxi.get_player()
	if settings.active then
		atc('Check SMN for burn.')
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
			atc('Not SMN job, skipping')
		end
	else
		atc('OneHour BURN not active!')
	end
end

-- External addons

function warp()
	local zone = windower.ffxi.get_info()['zone']
	local world = res.zones[windower.ffxi.get_info().zone].name
	
	if not(areas.Cities:contains(world)) then
		atc('WARP: Warping.')
		windower.send_command('myhome')
	else
		atcwarn('WARP: In a city zone, skipping.')
	end
end

function omen()
	atc('Heading to Omen.')
	windower.send_command('myomen')
end

function trib()
	atc('Getting Tribulens')
	windower.send_command('escha trib')
end

function rads()
	atc('Getting Radialens')
	windower.send_command('escha rads')
end

function buyalltemps()
	atc('Getting ALL TEMPS!')
	windower.send_command('escha buyall')
end

function get(cmd2)
	local zone = windower.ffxi.get_info()['zone']

	if cmd2 == 'mog' and zone == 247  then
		atc('GET: Obtaining Moglophone KI.')
		get_npc_dialogue('17789078',3)
		windower.send_command('wait 3; setkey enter down; wait 0.5; setkey enter up; wait 2; setkey escape down; wait 0.3; setkey escape up;')
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('get mog')
		end
		ipcflag = false
	elseif cmd2 == 'mog2' and zone == 247 then
		atc('GET: Moglophone II.')
		get_npc_dialogue('17789078',3)
		windower.send_command('wait 3; setkey down down; wait 0.1; setkey down up; wait 1; setkey down down; wait 0.1; setkey down up; wait 1; setkey down down; wait 0.1; setkey down up; wait 1; setkey down down; wait 0.1; setkey down up; wait 3.5; setkey enter down; wait 0.5; setkey enter up;')
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('get mog2')
		end
		ipcflag = false
	elseif cmd2 == 'pot' and zone == 291 then
		atc('GET: Potpourri KI')
		get_npc_dialogue('17970037',3)
		windower.send_command('wait 3; setkey right down; wait 1; setkey right up; wait 2; setkey up down; wait 0.1; setkey up up; wait 2; setkey enter down; wait 0.5; setkey enter up; wait 2; setkey up down; wait 0.1; setkey up up; wait 2; setkey enter down; wait 0.5; setkey enter up;')
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('get pot')
		end
		ipcflag = false
	elseif cmd2 == 'srki' and zone == 276  then
		atc('GET: SR KI.')
		get_npc_dialogue('17908273',3)
		windower.send_command('wait 3; setkey down down; wait 0.1; setkey down up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 1.0; setkey up down; wait 0.5; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('get srki')
		end
		ipcflag = false
	elseif cmd2 == 'srdrops' and zone == 276 then
		atc('GET: SR Rewards.')
		get_npc_dialogue('17908273',3)
		windower.send_command('wait 3; setkey down down; wait 0.1; setkey down up; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('get srdrops')
		end
		ipcflag = false
	elseif cmd2 == 'tag' and zone == 50 then
		atc('GET: Assault tag.')
		get_npc_dialogue('npc',3)
		windower.send_command('wait 3; setkey enter down; wait 0.5; setkey enter up;')
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('get tag')
		end
		ipcflag = false
	elseif cmd2 == 'canteen' and zone == 291 then
		atc('GET: Omen Canteen.')
		get_npc_dialogue('17970043',3)
		windower.send_command('wait 3; setkey enter down; wait 0.5; setkey enter up;')
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('get canteen')
		end
		ipcflag = false
	elseif cmd2 == 'mgexit' and zone == 280 then
		atc('GET: Exit Mog Garden.')
		get_npc_dialogue('17924124',3)
		windower.send_command('wait 3; setkey right down; wait 0.5; setkey right up; wait 1.0; ' .. 
			'setkey right down; wait 0.5; setkey right up; wait 1.0; setkey up down; wait 0.1; setkey up up; wait 1.0; ' ..
			'setkey enter down; wait 0.5; setkey enter up; wait 1.5; setkey right down; wait 0.1; setkey right up; wait 1.0; ' ..
			'setkey enter down; wait 0.5; setkey enter up;')
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('get mgexit')
		end
		ipcflag = false
	elseif cmd2 == 'aby' and areas.Abyssea:contains(zone) then
		atc('GET: Abyssea Visitation - Remaining time')
		get_poke_check('Conflux Surveyor')
		if npc_dialog == true then
			windower.send_command('wait 3; setkey down down; wait 0.1; setkey down up; wait 1; setkey down down; wait 0.1; setkey down up; wait 1.5; setkey enter down; wait 0.5; setkey enter up; wait 1.5; ' ..
				'setkey down down; wait 0.06; setkey down up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 1.5;' ..
				'setkey up down; wait 0.1; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 1.5; setkey up down; wait 0.1; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
		end
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('get aby')
		end
		ipcflag = false
	elseif cmd2 == 'aby1' and areas.Abyssea:contains(zone) then
		atc('GET: Abyssea Visitation - 1 Stone')
		get_poke_check('Conflux Surveyor')
		if npc_dialog == true then
			windower.send_command('wait 3; setkey down down; wait 0.1; setkey down up; wait 1; setkey down down; wait 0.1; setkey down up; wait 1.5; setkey enter down; wait 0.5; setkey enter up; wait 1.5; ' ..
				'setkey down down; wait 0.06; setkey down up; wait 1.0; setkey down down; wait 0.1; setkey down up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 1.5;' ..
				'setkey up down; wait 0.1; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 1.5; setkey up down; wait 0.1; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
		end
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('get aby1')
		end
		ipcflag = false
	elseif cmd2 == 'aby2' and areas.Abyssea:contains(zone) then
		atc('GET: Abyssea Visitation - 2 Stone')
		get_poke_check('Conflux Surveyor')
		if npc_dialog == true then
			windower.send_command('wait 3; setkey down down; wait 0.1; setkey down up; wait 1; setkey down down; wait 0.1; setkey down up; wait 1.5; setkey enter down; wait 0.5; setkey enter up; wait 1.5; ' ..
				'setkey down down; wait 0.06; setkey down up; wait 1.0; setkey down down; wait 0.1; setkey down up; wait 1.0; setkey down down; wait 0.1; setkey down up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 1.5;' ..
				'setkey up down; wait 0.1; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 1.5; setkey up down; wait 0.1; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
		end
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('get aby2')
		end
		ipcflag = false
	else
		atc('GET: Incorrect Zone/Command.')
	end
end

function go()
	atc('GO: TargetNPC + ENTER.')
	if ipcflag == false then
		ipcflag = true
		windower.send_ipc_message('go')
		get_npc_dialogue('npc',2)
	elseif ipcflag == true then
		get_npc_dialogue('npc',2)
	end
	ipcflag = false
end

function ent()
	atc('ENT: Sending ENTER Key.')
	windower.send_command('wait 1.5; setkey enter down; wait 0.5; setkey enter up;')
end

function enter()
	atc('ENTER: Enter menu.')
	
	if ipcflag == false then
		ipcflag = true
		windower.send_ipc_message('enter')
		get_npc_dialogue('npc',3)
		windower.send_command('setkey up down; wait 0.5; setkey up up; wait 0.7; setkey enter down; wait 0.5; setkey enter up;')
	elseif ipcflag == true then
		get_npc_dialogue('npc',3)
		windower.send_command('setkey up down; wait 0.5; setkey up up; wait 0.7; setkey enter down; wait 0.5; setkey enter up;')
	end
	ipcflag = false
end


function endown()
	if ipcflag == false then
		ipcflag = true
		windower.send_command('setkey down down; wait 0.5; setkey down up; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
		windower.send_ipc_message('endown')
	elseif ipcflag == true then
		windower.send_command('setkey down down; wait 0.5; setkey down up; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
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
	windower.send_command('setkey escape down; wait 0.5; setkey escape up;')
end

function cleanstones()
	local stone_types = {'Pluton case','Pluton Box','Boulder case','Boulder Box','Beitetsu Parcel','Beitetsu Box'}
	
	for count = 1,6 do
		windower.send_command('get "' ..stone_types[count].. '" 200')
		coroutine.sleep(2.5)
		windower.send_command('put "' ..stone_types[count].. '" sack 200')
		coroutine.sleep(1.2)
	end

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
					atc('Target: ' .. targetid.id)
					windower.send_command('settarget ' .. targetid.id)
					windower.send_command('wait 0.5; input /lockon; wait 2; setkey enter down; wait 0.5; setkey enter up; wait 6; setkey down down; wait 0.5; setkey down up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 1.0; setkey up down; wait 0.5; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up')
			elseif zone == 31 then -- Monarch
				windower.send_command('input /targetnpc; wait 1; input /lockon; wait 2; setkey enter down; wait 0.5; setkey enter up; wait 17; setkey down down; wait 0.5; setkey down up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 1.0; setkey up down; wait 0.5; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up')
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

function done()
	local zone = windower.ffxi.get_info()['zone']
	local assault_zone = S{55,56,63,66,69}
	
	if assault_zone:contains(zone) then

		local ror = windower.ffxi.get_mob_by_name('Rune of Release').id
		--local book = 'Ilrusi Ledger'
		--local book = 'Leujaoam Log'
		local book = 'Mamool Ja Journal'
		--local book = 'Lebros Chronicle'
		--local book = 'Periqia Diary'
			windower.send_command('settarget ' .. ror)
			coroutine.sleep(1)
			windower.send_command('input /lockon; wait 1; input /item \"' .. book .. '\" <t>')
	else
		atc('Assault Book: Not in zone.')
	end
	if ipcflag == false then
		ipcflag = true
		windower.send_ipc_message('done')
	end
	ipcflag = false
end

function drop(cmd2)
	local rem = S{4069,4070,4071,4072,4073}
	local cells = S{5365,5366,5367,5368,5369,5370,5371,5372,5373,5374,5375,5376,5377,5378,5379,5380,5381,5382,5383,5384}

	if cmd2 == 'rem' then
		local items = windower.ffxi.get_items()
		for index, item in pairs(items.inventory) do
			if type(item) == 'table' and rem:contains(item.id) then
				atc('Dropping: ' .. cmd2 .. ' ' .. item.id)
				windower.ffxi.drop_item(index, item.count)
			end
		end
	elseif cmd2 == 'cells' then
		local items = windower.ffxi.get_items()
		for index, item in pairs(items.inventory) do
			if type(item) == 'table' and cells:contains(item.id) then
				atc('Dropping: ' .. cmd2 .. ' ' .. item.id)
				windower.ffxi.drop_item(index, item.count)
			end
		end
	else
		atc('Nothing specified')
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
			atc("Ein: Entering Einherjar.")
			if ipcflag == false then
				windower.send_command('input /targetnpc; wait 1; input /lockon; wait 1; input /item \'glowing lamp\' <t>; wait 3; setkey up down; wait 0.5; setkey up up; wait 1; setkey enter down; wait 0.5; setkey enter up')
				ipcflag = true
				windower.send_ipc_message('ein enter')
			else
				windower.send_command('input /targetnpc; wait 1; input /lockon; wait 10; input /item \'glowing lamp\' <t>; wait 3; setkey up down; wait 0.5; setkey up up; wait 1; setkey enter down; wait 0.5; setkey enter up')
			end
			ipcflag = false
		elseif (cmd2 == 'exit') then
			local items = windower.ffxi.get_items()
			local exitflag = false
			for index, item in pairs(items.inventory) do
				if type(item) == 'table' and item.id == 5414 then
					atc('Ein: Dropping lamp to exit.')
					windower.ffxi.drop_item(index, item.count)
					exitflag = true
				end
			end
			if exitflag == false then
				atc('Ein: No lamp in inventory!')
			end
			if ipcflag == false then
				ipcflag = true
				windower.send_ipc_message('ein exit')
			end
			ipcflag = false
		else
			atc('Ein: No sub command specified')
		end
	else
		atcwarn("Ein: Not in proper zone, skipping.")
	end
end

-- Beta functions

function buffall(cmd2)
	player = windower.ffxi.get_player()
	for k, v in pairs(windower.ffxi.get_party()) do
		if type(v) == 'table' then
			if v.mob == nil then
				-- Not in zone.
				atc(v.name .. ' is not in zone!')
			elseif windower.ffxi.get_mob_by_name(v.name).in_party then
				windower.send_command('hb buff ' .. v.name .. ' ' .. cmd2)
			end
		end
		end
end

function rand()
	

	if ipcflag == false then
		windower.send_ipc_message('rand')
	elseif ipcflag == true then
		windower.send_command('hb f dist 20')
		pivot = math.random(-5,5)
		windower.ffxi.turn(pivot)
		coroutine.sleep(1.2)
		windower.ffxi.run(true)
		runtime = math.random(5.1,8.3)
		coroutine.sleep(runtime)
		windower.ffxi.run(false)
		coroutine.sleep(1.2 +runtime)
		
		pivot = math.random(-5,5)
		windower.ffxi.turn(pivot)
		coroutine.sleep(1.2)
		windower.ffxi.run(true)
		runtime = math.random(3.8,7.9)
		coroutine.sleep(runtime)
		windower.ffxi.run(false)
	end
	ipcflag = false

end


function wstype(cmd2)
	local player_job = windower.ffxi.get_player()
	local WSjobs = S{'COR','DRG','SAM','BLU','DRK','WAR'}		

	if cmd2 == 'leaden' then
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('wstype leaden')
		end
		ipcflag = false
		if WSjobs:contains(player_job.main_job) then
			if player_job.main_job == 'COR' then
				if player_job.sub_job == 'NIN' or player_job.sub_job == 'DNC' then
					atc('WS-Type: Leaden Salute')
					windower.send_command('gs c autows Leaden Salute')
					windower.send_command('gs c set weapons DualLeaden')
				else
					atc('WS-Type: Leaden Salute')
					windower.send_command('gs c autows Leaden Salute')
					windower.send_command('gs c set weapons DeathPenalty')
				end
			else
				atc('WS-Type: Leaden - Not COR, no WS change.')
			end
		else
			atc('WS-Type: Leaden - Skipping')
		end
	elseif cmd2 == 'savage' then
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('wstype savage')
		end
		ipcflag = false
		if WSjobs:contains(player_job.main_job) then
			if player_job.main_job == 'COR' then
				if player_job.sub_job == 'NIN' or player_job.sub_job == 'DNC' then
					atc('WS-Type: Savage Blade')
					windower.send_command('gs c autows Savage Blade')
					windower.send_command('gs c set weapons DualSavage')
				else
					atc('WS-Type: Savage Blade')
					windower.send_command('gs c autows Savage Blade')
					windower.send_command('gs c set weapons Naegling')
				end
			else
				atc('WS-Type: Savage - Not COR, no WS change.')
			end
		else
			atc('WS-Type: Savage - Skipping')
		end
	elseif cmd2 == 'laststand' then
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('wstype laststand')
		end
		ipcflag = false
		if WSjobs:contains(player_job.main_job) then
			if player_job.main_job == 'COR' then
				if player_job.sub_job == 'NIN' or player_job.sub_job == 'DNC' then
					atc('WS-Type: Last Stand')
					windower.send_command('gs c autows Last Stand')
					windower.send_command('gs c set weapons DualLastStand')
				else
					atc('WS-Type: Last Stand')
					windower.send_command('gs c autows Last Stand')
					windower.send_command('gs c set weapons Fomalhaut')
				end
			else
				atc('WS-Type: Last Stand - Not COR, no WS change.')
			end
		else
			atc('WS-Type: Last Stand - Skipping')
		end
	elseif cmd2 == 'wildfire' then
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('wstype wildfire')
		end
		ipcflag = false
		if WSjobs:contains(player_job.main_job) then
			if player_job.main_job == 'COR' then
				if player_job.sub_job == 'NIN' or player_job.sub_job == 'DNC' then
					atc('WS-Type: Wildfire')
					windower.send_command('gs c autows Wildfire')
					windower.send_command('gs c set weapons DualLeaden')
				else
					atc('WS-Type: Wildfire')
					windower.send_command('gs c autows Wildfire')
					windower.send_command('gs c set weapons DeathPenalty')
				end
			else
				atc('WS-Type: Wildfire - Not COR, no WS change.')
			end
		else
			atc('WS-Type: Wildfire - Skipping')
		end	
	elseif cmd2 == 'mace' then
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('wstype mace')
		end
		ipcflag = false
		if WSjobs:contains(player_job.main_job) then
			if player_job.main_job == 'DRK' or  player_job.main_job == 'WAR' then
				atc('WS is Judgment')
				windower.send_command('gs c set weapons Loxotic; gs c autows tp 1692')
			else
				atc('WS-Type: WAR/DRK Mace - Not WAR/DRK, no WS change.')
			end
		else
			atc('WS-Type: WAR/DRK Mace - Skipping')
		end	
	elseif cmd2 == 'slash' then
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('wstype slash')
		end
		ipcflag = false
		if WSjobs:contains(player_job.main_job) then
			if player_job.main_job == 'COR' then
				atc('WS is Savage')
				windower.send_command('gs c autows Savage Blade')
				windower.send_command('gs c set weapons DualSavage')
			elseif player_job.main_job == 'DRG' then
				atc('WS is Savage')
				windower.send_command('gs c autows Savage Blade')
				windower.send_command('gs c set weapons Naegling')
			elseif player_job.main_job == 'SAM' then
				atc('WS is Fudo')
				windower.send_command('gs c autows Tachi: Fudo')
				windower.send_command('gs c set weapons Masamune')
			elseif player_job.main_job == 'DRK' then
				atc('WS is Torcleaver')
				windower.send_command('gs c set weapons Caladbolg; gs c autows tp 1000')
			elseif player_job.main_job == 'BLU' then
				atc('WS is Savage')
				windower.send_command('gs c set weapons TizThib')
			elseif player_job.main_job == 'WAR' then
				atc('WS is Savage')
				windower.send_command('gs c set weapons Naegling; gs c autows tp 1000')
			end
		else
			atc('WS-Type: Slashing - Skipping')
		end
	elseif cmd2 == 'pierce' then
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('wstype pierce')
		end
		ipcflag = false
		if WSjobs:contains(player_job.main_job) then
			if player_job.main_job == 'COR' then
				atc('WS is Savage')
				windower.send_command('gs c autows Last Stand')
				windower.send_command('gs c set weapons DualLastStand')
			elseif player_job.main_job == 'DRG' then
				atc('WS is Stardiver')
				windower.send_command('gs c autows Stardiver')
				windower.send_command('gs c set weapons Trishula')
			elseif player_job.main_job == 'SAM' then
				atc('WS is Impulse')
				windower.send_command('gs c autows Tachi: Fudo')
				windower.send_command('gs c set weapons ShiningOne')
			elseif player_job.main_job == 'DRK' then
				atc('WS is Torcleaver')
				windower.send_command('gs c set weapons Caladbolg; gs c autows tp 1000')
			elseif player_job.main_job == 'BLU' then
				atc('WS is Expaciation')
				windower.send_command('gs c set weapons TizThib')
			elseif player_job.main_job == 'WAR' then
				atc('WS is Impulse')
				windower.send_command('gs c set weapons ShiningOne; gs c autows tp 1000')
			end
		else
			atc('WS-Type: Piercing - Skipping')
		end
	elseif cmd2 == 'blunt' then
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('wstype blunt')
		end
		ipcflag = false
		if WSjobs:contains(player_job.main_job) then
			if player_job.main_job == 'BLU' then
				atc('WS is Black Halo')
				windower.send_command('gs c set weapons Magic')
			elseif player_job.main_job == 'DRK' then
				atc('WS is Judgment')
				windower.send_command('gs c set weapons Loxotic; gs c autows tp 1692')
			elseif player_job.main_job == 'SAM' then
				atc('WS is Kagero')
				windower.send_command('gs c set weapons Dojikiri')
				windower.send_command('gs c autows Tachi: Kagero')
			elseif player_job.main_job == 'COR' then
				atc('WS is WildFire')
				windower.send_command('gs c autows Wildfire')
				windower.send_command('gs c set weapons DualLeaden')
				elseif player_job.main_job == 'DRG' then
				atc('WS is Retribution')
				windower.send_command('gs c autows Retribution')
				windower.send_command('gs c set weapons Malignance')
			elseif player_job.main_job == 'WAR' then
				atc('WS is Judgment')
				windower.send_command('gs c set weapons Loxotic; gs c autows tp 1692')
			end
		else
			atc('WS-Type: Blunt - Skipping')
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
			atc('Proc casting ON')
			windower.send_command('gs c set castingmode proc')
			windower.send_command('gs c set MagicBurstMode off')
			windower.send_command('gs c set AutoNukeMode off')
			windower.send_command('lua u maa')
			if player_job.main_job == "GEO" then
				windower.send_command('gs c autoindi refresh; gs c autogeo haste')
			end
		else
			atc('Skipping')
		end
	elseif cmd2 == 'off' then
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('proc off')
		end
		ipcflag = false
		if MageNukeJobs:contains(player_job.main_job) then
			atc('Proc casting OFF')
			windower.send_command('gs c set castingmode normal')
			windower.send_command('gs c set MagicBurstMode lock')
			windower.send_command('gs c set AutoNukeMode off')
			windower.send_command('lua r maa')
			if player_job.main_job == "GEO" then
				windower.send_command('gs c autoindi acumen; gs c autogeo malaise')
			end
		else
			atc('Skipping')
		end
	elseif cmd2 == 'nuke' then
		if ipcflag == false then
			ipcflag = true
			windower.send_ipc_message('proc nuke - low tier')
		end
		ipcflag = false
		if MageNukeJobs:contains(player_job.main_job) then
			atc('Auto nuke - low tier')
			windower.send_command('gs c set castingmode normal')
			windower.send_command('gs c set MagicBurstMode off')
			windower.send_command('gs c set AutoNukeMode on')
			windower.send_command('lua u maa')
			if player_job.main_job == "GEO" then
				windower.send_command('gs c autoindi refresh; gs c autogeo haste')
			end
		else
			atc('Skipping')
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
			finaldelay = (os.clock() / 1000000) + settings.send_all_delay
            --return (k - 1) * finaldelay
			return (k - 1) * settings.send_all_delay
        end
    end
end

function get_npc_dialogue(target_id,cycles)
	npc_dialog = false
	count = 0
	if target_id == 'npc' then
		while npc_dialog == false and count < cycles
		do
			count = count + 1
			if count == 0 then
				windower.send_command('input /targetnpc; wait 0.5; input /lockon; wait 0.7; setkey enter down; wait 0.5; setkey enter up;')
			else
				windower.send_command('setkey escape down; wait 0.5; setkey escape up; wait 0.5; input /targetnpc; wait 0.5; input /lockon; wait 0.7; setkey enter down; wait 0.5; setkey enter up;')
			end
			coroutine.sleep(5.2)
		end
	else
		while npc_dialog == false and count < cycles
		do
			count = count + 1
			if count == 0 then
				windower.send_command('wait 1.5; settarget ' .. target_id .. '; wait 1; input /lockon; wait 1; setkey enter down; wait 0.5; setkey enter up;')
			else
				windower.send_command('setkey escape down; wait 0.5; setkey escape up; wait 1.0; settarget ' .. target_id .. '; wait 1; input /lockon; wait 1; setkey enter down; wait 0.5; setkey enter up;')
			end
			coroutine.sleep(6.5)
		end
	end
end

function get_poke_check(npc_name)
	npc_dialog = false
	count = 0
	npcstats = windower.ffxi.get_mob_by_name(npc_name)

	while npc_dialog == false and count < 3
	do
		count = count + 1
		if math.sqrt(npcstats.distance)<6 and npcstats.valid_target then
			atc('Poke #: ' ..count.. ' -NPC: ' .. npc_name)
			poke_npc(npcstats.id,npcstats.index)
		else
			atcwarn('POKE: NPC Target is too far!')
		end
		coroutine.sleep(4.5)
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
			ipcflag = true
			if(DelayCMDS:contains(cmd)) then
				coroutine.sleep(delay)
			end
			send_int_cmd(cmd)
			--loadstring(cmd.."()")()
		else
			ipcflag = true
			if(DelayCMDS:contains(cmd)) then
				coroutine.sleep(delay)
			end
			send_int_cmd(cmd,cmd2)
			--_G[cmd](cmd2)
		end
	elseif cmd == 'assist' then
		if cmd2 == 'melee' then
			ipcflag = true
			assist(cmd2,cmd3)
		elseif cmd2 == 'mag' then
			ipcflag = true
			assist(cmd2,cmd3)
		elseif cmd2 == 'all' then
			ipcflag = true
			assist(cmd2,cmd3)
		elseif  cmd2 == 'on' then
			ipcflag = true
			assist(cmd2,cmd3)
		elseif cmd2 == 'off' then
			ipcflag = true
			assist(cmd2)
		end
	elseif cmd == 'fps' then
		ipcflag = true
		fps(cmd2)
	elseif cmd == 'send' then
		coroutine.sleep(delay)
		ipcflag = true
		send(send_cmd)
	elseif cmd == 'burnset' then
		ipcflag = true
		burnset(cmd2, cmd3, cmd4)
	elseif cmd == 'smnburn' then
		ipcflag = true
		smnburn()
	elseif cmd == 'geoburn' then
		ipcflag = true
		geoburn()
	elseif cmd == 'smnhelp' then
		ipcflag = true
		smnhelp(cmd2)
	elseif cmd == 'rngsc' then
		ipcflag = true
		rngsc(cmd2)
	elseif cmd == 'stage' then
		ipcflag = true
		stage(cmd2)
	elseif cmd == 'jc' then
		local moredelay = delay + 1.8	
		coroutine.sleep(moredelay)
		ipcflag = true
		jc(cmd2)
	elseif cmd == 'buy' then
		coroutine.sleep(delay)
		ipcflag = true
		buy(cmd2)	
	elseif cmd == 'zerg' then
		ipcflag = true
		zerg(cmd2)
	elseif cmd == 'proc' then
		ipcflag = true
		proc(cmd2)	
	elseif cmd == 'wstype' then
		ipcflag = true
		wstype(cmd2)	
	elseif cmd == 'rand' then
		ipcflag = true
		rand()	
	-- Might move these to separate addon
	elseif cmd == 'ein' then
		coroutine.sleep(delay)
		ipcflag = true
		ein(cmd2)
	elseif cmd == 'go' then
		coroutine.sleep(delay)
		ipcflag = true
		go()
	elseif cmd == 'enter' then
		coroutine.sleep(delay)
		ipcflag = true
		enter()
	elseif cmd == 'get' then
		coroutine.sleep(delay)
		ipcflag = true
		get(cmd2)
	elseif cmd == 'endown' then
		coroutine.sleep(delay)
		ipcflag = true
		endown()
	elseif cmd == 'enup' then
		coroutine.sleep(delay)
		ipcflag = true
		enup()
	elseif cmd == 'htmb' then
		local moredelay = delay + 0.3
		coroutine.sleep(moredelay)
		ipcflag = true
		htmb(cmd2)	
	elseif cmd == 'done' then
		coroutine.sleep(delay)
		ipcflag = true
		done()	
	end
end)

function loaded()
	settings = config.load(default)
	init_box_pos()
end

windower.register_event('load', loaded)

windower.register_event("status change", function(new,old)
    local target = windower.ffxi.get_mob_by_target('t')
    if not target or target then
        if new == 4 then
            npc_dialog = true
        elseif old == 4 then
            npc_dialog = false
        end
    end
end)

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