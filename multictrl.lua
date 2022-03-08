_addon.name = 'MC'
_addon.author = 'Kate'
_addon.version = '3.0.1'
_addon.commands = {'mc'}

require('functions')
require('logger')
require('tables')
config = require('config')
packets = require('packets')
require('coroutine')
res = require('resources')
texts = require('texts')
npc_map = require('npc_map')

-- job registry is a key->value table/db of player name->jobs we have encountered
job_registry = T{}

default = {

	avatar='ramuh',
	indi='refresh',
	dia=true,
	active=false,
	assist='',
	smnhelp=false,
	smnsc=false,
	smnauto=false,
	smnlead='',
	buy=false,
	autows=false,
	rangedmode=false,
	send_all_delay = 1.08,
	antisleep=true,
	autosc=false,
	autoarts='',
	npc_dialog=false,
	battletarget='Raskovniche',
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

	--Battle
	'on','off','stage','fight','fightmage','fightsmall','ws','food','sleep','fin',
	'wsall','cc','zerg','wstype','buffup','dd','attackon','mb',
	
	--Job
	'brd','bst','cor','sch','smnburn','geoburn','burn','rng','proc','crit','wsproc',
	--Travel
	'mnt','dis','warp','omen','enup','endown','ent','esc','go','enter','get','deimos','macro',
	--Misc
	'reload','unload','fps','lotall','cleanstones','drop','buyalltemps','book'
	--Inactive
	--'jc',
}

DelayCMDS = S{'buyalltemps','get','enter','go','book','deimos'}
	
isCasting = false
isResting = false
ipcflag = false
currentPC=windower.ffxi.get_player()
new = 0
old = 0

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
	elseif cmd == 'job' then
		find_job_charname(string.upper(cmd2),cmd3)
	elseif cmd == 'jobtype' then
		find_job_type(string.lower(cmd2))
	elseif cmd == 'rand' then
		local leader = windower.ffxi.get_player()
		rand(leader.name)
		send_to_IPC(cmd,leader.name)
	elseif cmd == 'buy' then						-- Leader
		local leader = windower.ffxi.get_player()
		buy:schedule(0, cmd2,leader.name)
		send_to_IPC:schedule(1, cmd,cmd2,leader.name)
	elseif cmd == 'deimos' then
		local leader = windower.ffxi.get_player()
		deimos:schedule(0, leader.name)
		send_to_IPC:schedule(1, cmd,leader.name)
	elseif cmd == 'macro' then
		local leader = windower.ffxi.get_player()
		macro:schedule(0, leader.name)
		send_to_IPC:schedule(1, cmd,leader.name)
	elseif cmd == 'ein' then						-- Long delay
		ein:schedule(0, cmd2)
		if cmd2 == 'enter' then
			send_to_IPC:schedule(10, cmd, cmd2)
		else
			send_to_IPC:schedule(1, cmd, cmd2)
		end
	elseif cmd == 'buffall' then					-- No IPC
		buffall(cmd2)
	elseif cmd == 'd2' then							-- No IPC
		d2()
	elseif cmd == 'fon' then						-- No IPC
		fon(cmd2)
	elseif cmd == 'foff' then						-- No IPC
		foff(cmd2)
	elseif cmd == 'as' then							-- Leader
		local leader = windower.ffxi.get_player()
		as:schedule(0, cmd2,leader.name)
		send_to_IPC:schedule(0, cmd,cmd2,leader.name)
	elseif cmd == 'smn' then						-- Leader
		local leader = windower.ffxi.get_player()
		smn:schedule(0, cmd2, leader.name, cmd3)
		send_to_IPC:schedule(0, cmd, cmd2, leader.name, cmd3)
	elseif cmd == 'autosc' then						-- Leader
		local leader = windower.ffxi.get_player()
		autosc:schedule(0, cmd2, leader.name)
		send_to_IPC:schedule(0, cmd, cmd2, leader.name)
	elseif cmd == 'send' then						-- Special parameter
		send:schedule(0, term)
		send_to_IPC:schedule(0.95, cmd, term)
	elseif cmd == 'gt' then							-- Special parameter
		gt:schedule(0,term)
		send_to_IPC:schedule(0.95, cmd, term)
	elseif InternalCMDS:contains(cmd) then
		if DelayCMDS:contains(cmd) then
			_G[cmd]:schedule(0, cmd2,cmd3)
			send_to_IPC:schedule(0.75, cmd,cmd2,cmd3)
		else
			_G[cmd]:schedule(0, cmd2,cmd3)
			send_to_IPC:schedule(0, cmd,cmd2,cmd3)
		end
	end

end)

local mprefix = ('[%s] '):format(_addon.name)


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
		
		if settings.smnauto then
			smn_help:append(string.format("\n%sAutoBP: %sON", clr.w, clr.r))
		else
			smn_help:append(string.format("\n%sAutoBP: %sOFF", clr.w, clr.r))
		end
		
		if settings.smnlead then
			smn_help:append(string.format("\n%sLeader: %s" .. settings.smnlead , clr.w, clr.r))
		else
			smn_help:append(string.format("\n%sLeader: %s", clr.w, clr.r))
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
	
	if settings.autosc then
		rng_sc:append(string.format("%sAUTO SC: %sON", clr.w, clr.r))
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
		
		if settings.assist then
			burn_status:append(string.format("\n%s Assiting: %s" .. settings.assist, clr.w, clr.h))
		else
			burn_status:append(string.format("\n%s Assiting: ", clr.w))
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

	-- Goblin month - BRD/NIN, GEO/WHM, WHM/SCH, PLD/RUN, RUN/DRK, SAM/WAR
	if cmd2 == 'ambu' then
		atc('[Stage]: Ambu')
		windower.send_command('gaze ap on')
		if player_job.main_job == 'BRD' then
			windower.send_command('lua r autows; autows use savage blade; autows on; autoss; sing pl ambu; sing n on; gs c set weapons dualsavage; sing debuffing on; sing sirvente ' .. find_job_charname('PLD'))
		elseif player_job.main_job == 'MNK' then
			windower.send_command('lua l dressup; gs c autows howling fist; gs c set weaponskillmode Emnity; gs c set weapons Malignance')
		elseif player_job.main_job == 'PLD' then
			windower.send_command('gaze ap off; hb mincure 4; gs c set runeelement lux; gs c set weapons Aegis')
		elseif player_job.main_job == 'COR' then
			windower.send_command('lua r autows; autows use savage blade; autows on; gs c set weapons dualsavage; roll melee')
		elseif player_job.main_job == 'RDM' then
			windower.send_command('hb debuff dia3; hb debuff gravity2; hb debuff distract3; lua r autows; autows use black halo; autows on; gs c autows black halo; gs c set weapons DualClubs; autoss; mc buffall haste2; hb mincure 4; hb buff ' ..find_job_charname('PLD').. ' refresh3; hb buff ' ..find_job_charname('WAR').. ' refresh3; hb buff ' ..find_job_charname('MNK').. ' refresh3')
		elseif player_job.main_job == 'WAR' then
			windower.send_command('lua l dressup; lua r autows; autows use Judgment; autows on; gs c set autotomahawkmode on; gs c autows Judgment; gs c set weaponskillmode Enmity; gs c set hybridmode Enmity; gs c set weapons Loxotic')
		end
		settings.autows = true
	elseif cmd2 == 'ambu2' then
		if player_job.main_job == 'RDM' then
			windower.send_command('hb f off; hb as off; hb off')
		end
	elseif cmd2 == 'ody' then
		atc('[Stage]: Odyssey A B C')
		windower.send_command('lua r gazecheck')
		windower.send_command('input /autotarget on')
		if player_job.main_job == 'WHM' then
			windower.send_command('wait 1.5; gs c set castingmode DT; gs c set idlemode DT; gaze ap off; hb buff ' .. find_job_charname('RUN') .. ' haste; hb buff ' .. find_job_charname('SAM') .. ' haste; hb buff ' .. find_job_charname('RUN') .. ' regen4; hb ignore_debuff all poison')
		elseif player_job.main_job == 'RUN' then
			windower.send_command('wait 1.5; gaze ap off; gs c set runeelement sulpor; hb mincure 5;')
		elseif player_job.main_job == 'BRD' then
			windower.send_command('wait 1.5; gs c set idlemode DT; gaze ap on; gs c set weapons carnwenhan; sing pl melee; sing n off; sing p on; hb buff ' .. find_job_charname('COR') .. ' haste; hb buff ' .. find_job_charname('SAM','2') .. ' haste;')
		elseif player_job.main_job == 'COR' then
			windower.send_command('wait 1.5; roll melee; gaze ap on; gs c autows Leaden Salute')
		elseif player_job.main_job == 'SAM' or player_job.main_job == 'DRK' then
			windower.send_command('wait 1.5; gaze ap on;')
		elseif player_job.main_job == 'WAR' or player_job.main_job == 'DRG' then
			windower.send_command('wait 1.5; gaze ap on; gs c set weapons Naegling;')
		end
		settings.autows = true
	elseif cmd2 == 'cleave' then
		atc('[Stage]: Cleaving')
		if player_job.main_job == 'BRD' then
			windower.send_command('sing n off; sing pl mage')
		elseif player_job.main_job == 'BLU' then
			windower.send_command('gaze ap off; gs c set weapons Magic; azuresets set solo;')
		elseif player_job.main_job == 'COR' then
			windower.send_command('roll exp')
		elseif player_job.main_job == 'GEO' then
			windower.send_command('gs c autoindi refresh; gs c autogeo haste')
		end
	elseif cmd2 == 'shin' then
		-- MNK BLU THF GEO WHM BRD
		atc('[Stage] Shinryu')
		if player_job.main_job == 'WHM' then
			windower.send_command('gaze ap off; hb buff <me> barfira; gs c set castingmode DT; gs c set idlemode DT; hb buff <me> auspice; hb buff <me> regen4; hb as off; hb buff ' ..settings.char3.. ' haste')
		elseif player_job.main_job == 'RUN' then
			windower.send_command('gs c set runeelement lux; gs c set autobuffmode auto; gs c set hybridmode DTLite;')
		elseif player_job.main_job == 'BRD' then -- sub WHM
			windower.send_command('gaze ap off; sing pl shin; sing n on; sing p on; hb mincure 5; hb mincuraga 2; sing ballad 1 ' ..settings.char6.. '; sing ballad 1 ' ..settings.char5.. '; sing ballad 1 ' ..settings.char4.. '; hb buff ' ..settings.char2.. ' haste')
		elseif player_job.main_job == 'THF' then
			windower.send_command('gs c set treasuremode fulltime; gaze ap on')
		elseif player_job.main_job == 'SAM' or player_job.main_job == 'DRK' or player_job.main_job == 'MNK' then
			windower.send_command('gaze ap on;')
		elseif player_job.main_job == 'BLU' then -- sub RDM
			windower.send_command('gaze ap on; gs c set weapons TizThib; azuresets set melee;')
		elseif player_job.main_job == 'SCH' then -- sub RDM
			windower.send_command('gs c set elementalmode light; gs c set castingmode DT; gs c set idlemode DT; schheal; hb buff <me> regen5; hb buff ' ..settings.char5.. ' aurorastorm2; hb buff ' ..settings.char4.. ' refresh')
		elseif player_job.main_job == 'GEO' then -- sub RDM
			windower.send_command('gs c set castingmode DT; gs c set idlemode DT; gs c autogeo fury; gs c autoindi regen; gs c autoentrust frailty; hb debuff dia2; hb buff ' ..settings.char4.. ' refresh; hb buff ' ..settings.char1.. ' haste')
		end
		settings.autows = true
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
	elseif cmd2 == 'arebati' then
		if player_job.main_job == 'SCH' or player_job.main_job == 'WHM' then
			windower.send_command(' hb disable erase; hb buff ' ..settings.char1.. ' haste;')
			windower.send_command('gs c set castingmode DT; gs c set idlemode DT;')
			if player_job.main_job == 'SCH' then
				windower.send_command('mc sch heal; gs c set autoapmode on;')
			end
		elseif player_job.main_job == 'RUN' then
			windower.send_command('gs c set runeelement ignis; hb buff <me> barblizzard; lua r react')
		elseif player_job.main_job == 'BRD' then
			windower.send_command('mc brd reset; sing pl arebati; sing n on; sing p on; gs c set idlemode DT; sing sirvente ' ..settings.char1.. '; sing ice 1 ' ..settings.char1)
		elseif player_job.main_job == 'GEO' then
			windower.send_command('gs c autoindi fury; gs c autogeo agi; gs c autoentrust attunement; gs c set castingmode DT; gs c set idlemode DT; gs c autoentrustee ' ..settings.char1)
		elseif player_job.main_job == 'RNG' then
			windower.send_command('gs c set weapons Armageddon; gs c set rnghelper on; wait 2; gs c autows Last Stand;')
		elseif player_job.main_job == 'COR' then
			windower.send_command('roll melee; gs c set weapons Fomalhaut; gs c set rnghelper on; wait 2; gs c autows Last Stand;')
		end
		settings.autows = true
		settings.rangedmode = true
	elseif cmd2 == 'arewar' then
		if player_job.main_job == 'WHM' or player_job.main_job == 'WHM' then
			windower.send_command('hb debuff dia2; hb debuff slow; hb debuff silence; hb buff <me> barblizzara; hb disable erase; hb buff <me> auspice; hb buff ' ..settings.char3.. ' haste; hb buff ' ..settings.char1.. ' haste; hb buff ' ..settings.char2.. ' haste; hb buff ' ..settings.char4.. ' haste')
			windower.send_command('gs c set castingmode DT; gs c set idlemode DT;')
		elseif player_job.main_job == 'PLD' then
			--windower.send_command('')
		elseif player_job.main_job == 'BRD' then
			windower.send_command('mc brd reset; wait 2; sing debuff nocturne; sing debuffing on; sing p on; gs c set weapons Aeneas; sing pl arewar; sing n off; sing p off; gs c set idlemode DT; sing ballad 2 ' ..settings.char6.. '; sing ballad 2 ' ..settings.char1)
		elseif player_job.main_job == 'BST' then
			windower.send_command('gs c set JugMode SweetCaroline')
		elseif player_job.main_job == 'WAR' then
			windower.send_command('gs c set weapons ShiningOne; gs c set hybridmode SubtleBlow')
		elseif player_job.main_job == 'COR' then
			windower.send_command('roll melee; gs c set weapons Fomalhaut; gs c autows Last Stand; gs c set castingmode resistant')
		end
		settings.autows = true
	elseif cmd2 == 'are2' then
		if player_job.main_job == 'GEO' then
			windower.send_command('gs c autoindi fury; gs c autogeo barrier; gs c autoentrust attunement; gs c set castingmode DT; gs c set idlemode DT; gs c autoentrustee ' ..settings.char1)
		elseif player_job.main_job == 'COR' then
			--windower.send_command('roll roll1 gallant;')
		elseif player_job.main_job == 'RNG' then
			--windower.send_command('gs c set rangedmode DT;')
		elseif player_job.main_job == 'BRD' then
			windower.send_command('mc brd arebati')
		end
		settings.autows = true
		settings.rangedmode = true
	elseif cmd2 == 'arepre' then
		if player_job.main_job == 'SCH' then
			windower.send_command('gs c set castingmode DT; gs c set idlemode DT;')
			windower.send_command('mc sch heal; gs c set autoapmode off; hb buff ' .. settings.char1 .. ' regen5;')
		elseif player_job.main_job == 'PLD' then
			windower.send_command('gs c set weapons aegis')
		elseif player_job.main_job == 'THF' then
			--windower.send_command('')
		elseif player_job.main_job == 'SAM' then
			windower.send_command('gs c weapons ShiningOne;')
		elseif player_job.main_job == 'WAR' then
			windower.send_command('gs c weapons ShiningOne;')
		elseif player_job.main_job == 'RDM' then
			--windower.send_command('dsmall;')
		end
		settings.autows = true
		settings.rangedmode = true
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
		settings.autows = true
	elseif cmd2 == 'mboze' then
		windower.send_command('gaze ap off')
		if player_job.main_job == 'WHM' then
			windower.send_command('hb buff <me> barstonra; gs c set castingmode DT; gs c set idlemode DT; hb debuff slow; hb debuff dia2; hb debuff paralyze; hb buff <me> auspice; hb buff ' ..find_job_type('dd').. ' haste')
		elseif player_job.main_job == 'DRK' or player_job.main_job == 'SAM' or player_job.main_job == 'WAR' then
			windower.send_command('lua l dressup; gs c set defensedownmode tag')
			if player_job.main_job == 'DRK' then
				windower.send_command('gs c set weapons KajaChopper; gs c set hybridmode SubtleBlow; gs c autows tp 1750;')
			elseif player_job.main_job == 'SAM' then
				windower.send_command('gs c set hybridmode SubtleBlow; gs c autows Tachi: Ageha;')
			elseif player_job.main_job == 'WAR' then
				windower.send_command('gs c set hybridmode SubtleBlow; gs c set weapons Naegling; gs c autows Savage Blade')
			end
		elseif player_job.main_job == 'BRD' then
			windower.send_command('sing pl mboze; sing n off; sing p off; sing debuffing off; gs c set idlemode DT; sing debuff wind threnody 2; hb debuff wind threnody ii;')-- hb debuff pining nocturne; hb debuff Foe Requiem VII;')
		elseif player_job.main_job == 'BLU' then
			windower.send_command('azuresets set mboze; gs c set castingmode resistant; gs c set AutoBLUSpam on; gs c set weapons MACC; hb debuff silent storm')
			windower.send_command('input /p Check buff+spam modes')
		elseif player_job.main_job == 'COR' then
			windower.send_command('roll melee; gs c set weapons Naegling; gs c set castingmode resistant;')
		elseif player_job.main_job == 'BST' then
			windower.send_command('gs c set JugMode ScissorlegXerin')
		end
	elseif cmd2 == 'mbozepre' then
		windower.send_command('gaze ap off')
		if player_job.main_job == 'RDM' then
			windower.send_command('dfull')
		elseif player_job.main_job == 'DRK' or player_job.main_job == 'SAM' or player_job.main_job == 'WAR' then
			windower.send_command('lua l dressup; gs c set defensedownmode tag')
			if player_job.main_job == 'DRK' then
				windower.send_command('gs c set weapons KajaChopper; gs c set hybridmode SubtleBlow; gs c autows tp 1750;')
			elseif player_job.main_job == 'SAM' then
				windower.send_command('gs c set hybridmode SubtleBlow; gs c autows Tachi: Ageha;')
			elseif player_job.main_job == 'WAR' then
				windower.send_command('gs c set hybridmode SubtleBlow; gs c set weapons Naegling; gs c autows Savage Blade')
			end
		elseif player_job.main_job == 'GEO' then
			windower.send_command('gs c autogeo vit')-- hb debuff pining nocturne; hb debuff Foe Requiem VII;')
		elseif player_job.main_job == 'SCH' then
			windower.send_command('')
		elseif player_job.main_job == 'SMN' then
			windower.send_command('')
		elseif player_job.main_job == 'MNK' then
		end
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
	elseif cmd2 == 'lilsam' then
		atc('[Stage]: Lilith Samurai')
		if player_job.main_job == 'WHM' then
			windower.send_command('hb buff <me> boost-str; gs c set castingmode DT; gs c set idlemode DT; hb buff <me> auspice; hb ignore_debuff all curse;')
		elseif player_job.main_job == 'BRD' then
			windower.send_command('sing pl melee; sing n on; sing p on; sing debuffing off; sing ballad 1 <me>; gs c set treasuremode tag; hb disable na')
		elseif player_job.main_job == 'BLU' then
			windower.send_command('lua l roller; wait 1.5; gs c set weapons MACC; gs c set castingmode resistant; gs c set autobluspam on; gs c set autobuffmode auto; roller roll1 fighters;')
		elseif player_job.main_job == 'COR' then
			windower.send_command('roll roll1 sam; roll roll2 allies; gs c set treasuremode tag; gs c set idlemode refresh;')
		elseif player_job.main_job == 'GEO' then
			windower.send_command('gs c autogeo frailty; gs c autoindi fury; gs c autoentrust haste; gs c set castingmode DT; gs c set idlemode DT; gs c autonuke Absorb-TP; gs c set autonukemode on;')
		end
	elseif cmd2 == 'lil' then
		atc('[Stage]: Lilith MNK')
		if player_job.main_job == 'WHM' then
			windower.send_command('hb disable erase; hb buff <me> boost-str; gs c set castingmode DT; gs c set idlemode DT; hb buff <me> auspice; hb ignore_debuff all curse;')
		elseif player_job.main_job == 'BRD' then
			windower.send_command('sing pl lilmnk; sing n on; sing p on; sing debuffing off; gs c set treasuremode tag;')
		elseif player_job.main_job == 'THF' then
		elseif player_job.main_job == 'COR' then
			windower.send_command('roll roll1 sam; roll roll2 allies; gs c set treasuremode tag; gs c set idlemode refresh;')
		elseif player_job.main_job == 'GEO' then
			windower.send_command('gs c autogeo frailty; gs c autoindi fury; gs c autoentrust refresh; gs c set castingmode DT; gs c set idlemode DT;')
		end
		if player_job.sub_job == 'DRK' then
			windower.send_command('gs c autonuke Absorb-TP; gs c set autonukemode on;')
		end
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
	elseif cmd2 == 'dae' then
		windower.send_command('autoitem off')
		if player_job.main_job == 'SCH' then
			windower.send_command('hb enable cure; hb enable na; hb buff <me> reraise; hb disable erase; hb buff <me> aurorastorm2;')
		elseif player_job.main_job == 'SAM' then
			windower.send_command('gs c set weapons ShiningOne')
		elseif player_job.main_job == 'BST' then
			windower.send_command('gs c set weapons Kaja; gs c set jugmode GenerousArthur; gs c toggle AutoCallPet')
		end
	elseif cmd2 == 'kraken' then
		windower.send_command('autoitem off')
		if player_job.main_job == 'PUP' then
			windower.send_command('gs c set petmode melee; gs c set AutoManeuvers melee; gs c set weapons sakpata; autocontrol equipset kraken')
		elseif player_job.main_job == 'COR' then
			windower.send_command('roll roll1 beast; roll roll2 drachen')
		elseif player_job.main_job == 'BST' then
			windower.send_command('gs c set weapons Kaja; gs c set jugmode GenerousArthur; gs c toggle AutoCallPet')
		end
	else
		atc('[Stage]: Invalid option.')
	end
	display_box()
end

function jc(cmd2)
	local player_job = windower.ffxi.get_player()

	if cmd2 == 'ody' then
		atc('[JC] Odyssey C farm.')
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
	else
		atc('[JC] Nothing specified.')
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
				windower.send_command('input /ws \'Expiacion\' <t>')
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
			windower.send_command('gs c set autorunemode on; gs c set autobuffmode auto')
		elseif player_job.main_job == "BRD" then
			windower.send_command('singer on')
		elseif player_job.main_job == "COR" or player_job.sub_job == "COR" then
			windower.send_command('roller on')
		elseif player_job.main_job == "SCH" then
			windower.send_command('gs c set autosubmode on')
		elseif player_job.main_job == "RDM" then
			windower.send_command('gs c set autoarts on;')
			windower.send_command('input /ja composure <me>')
		elseif player_job.main_job == "WHM" then
			windower.send_command('gs c set autoarts on;')
		elseif player_job.main_job == "BLU" then
			windower.send_command('gs c set autobuffmode auto;')
		elseif player_job.main_job == "DNC" or player_job.sub_job == "DNC" then
			windower.send_command('gs c set autosambamode haste')
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
		--windower.send_command('gs c set autoapmode off')
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

-- Does NOT use IPC
function fon()
	atc('FON: Follow ON.')
	currentPC=windower.ffxi.get_player()
	
	windower.send_command('hb follow off')
	windower.send_command('hb f dist 1.8')

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
						windower.send_command('send ' .. v.name .. ' hb f dist 1.8')
						windower.send_command('send ' .. v.name .. ' hb follow ' .. currentPC.name)
					else
						atc('FON: ' .. v.name .. ' is not in range, not following.')
					end
				end
			end
		end
	end
end

-- Does NOT use IPC
function foff()
	atc('FOFF: Follow OFF')
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
					atc('FOFF: ' .. v.name .. ' is not in zone.')
				else
					if ptymember.valid_target then
						atcwarn('FOFF: Setting ' ..v.name.. ' to stop following.')
						windower.send_command('send ' .. v.name .. ' hb f off')
					else
						atc('FOFF: ' .. v.name .. ' is not in range.')
					end
				end
			end
		end
	end
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

function brd(cmd2)
	local player_job = windower.ffxi.get_player()
	if player_job.main_job == "BRD" then
		if cmd2 == 'ambu' then
			atc('[BRD] Ambu')
			windower.send_command("hb buff " ..find_job_type('tank').. " mage's ballad III; hb buff " ..find_job_type('tank').. "  sentinel's scherzo;")
		elseif cmd2 == 'ody' then
			atc('[BRD] Odyssey')
			windower.send_command("hb buff " ..find_job_type('tank').. " sentinel's scherzo; hb buff " ..find_job_type('tank').. " foe sirvente; hb buff " ..find_job_type('tank').. " scop's operetta; hb buff " ..find_job_type('tank').. " victory march")
		elseif cmd2 == 'arebati' then
			windower.send_command("hb buff " ..find_job_type('tank').. " ice carol; hb buff " ..find_job_type('tank').. " foe sirvente; hb buff " ..find_job_type('tank').. " scop's operetta; hb buff " ..find_job_type('tank').. " ice carol II")
		elseif cmd2 == 'reset' then
			atc('[BRD] Reset')
			windower.send_command("hb nobuff " ..find_job_type('tank').. " all")
		elseif cmd2 == 'sv5' then
			atc('[BRD] SV5')
			windower.send_command('sing off; sing pl sv5; gs c set autozergmode on')
		elseif cmd2 == 'sv' then
			atc('[BRD] SV - Soul Voice')
			windower.send_command('sing off; input /ja "Soul Voice" <me>;')
		elseif cmd2 == 'nitro' then
			atc('[BRD] NITRO')
			windower.send_command('sing off; input /ja "Nightingale" <me>; wait 1.5; input /ja "Troubadour" <me>')
		elseif cmd2 == 'zerg' then
			windower.send_command('sing off; gs c set autozergmode on')
		else
			atc('[BRD] Invalid command')
		end
	else
		atc('[BRD] Incorrect job, skipping.')
	end
end

function bst(cmd2)
	local player_job = windower.ffxi.get_player()
	if player_job.main_job == "BST" then
		if cmd2 == 'killer' then
			atc('[BST] Killer Toggle')
		windower.send_command('gs c set AutoCallPet off; gs c set AutoFightMode off; gs c set AutoReadyMode off; gs c set JugMode ScissorlegXerin; wait 5.0; input /ja "Leave" <me>; wait 2.5; gs c set AutoCallPet on')
				--windower.send_command('gs c set AutoCallPet off; gs c set AutoFightMode off; gs c set AutoReadyMode off; gs c set JugMode SweetCaroline; wait 1.3; input /ja "Leave" <me>; wait 1.8; gs c set AutoCallPet on')
			windower.send_command:schedule(11.0, 'input /ja "Killer Instinct" <me>; gs c set JugMode FatsoFargann; wait 3.5; input /ja "Leave" <me>; wait 3.5; gs c set AutoCallPet on; gs c set AutoReadyMode on;')
		elseif cmd2 == 'init' then
			atc('[BST] Use Killer then reset to TP pet')
			windower.send_command('wait 1.5; input /ja "Killer Instinct" <me>; wait 1.8; gs c set JugMode FatsoFargann; input /ja "Leave" <me>; wait 1.8; input /ja "Call Beast" <me>; gs c set AutoCallPet on;')
		else
			atc('[BST] Invalid command')
		end
	else
		atc('[BST] Incorrect job, skipping.')
	end
end

function cor(cmd2)
	local player_job = windower.ffxi.get_player()
	if player_job.main_job == "COR" then
		if cmd2 == 'melee' then
			atc('[COR] Melee rolls + lower radius')
			windower.send_command('gs c set luzafring off; roll melee;')			
		elseif cmd2 == 'back' then
			atc('[COR] Backline rolls + lower radius')
			windower.send_command('gs c set luzafring off; roll roll1 warlock; roll roll2 gallant;')
		elseif cmd2 == 'aoe' then
			atc('[COR] Set Luzaf ON')
			windower.send_command('gs c set luzafring on')
		elseif cmd2 == 'statue' then
			atc('[COR] Killing statues')
			windower.send_command('gs c killstatue')
		else
			atc('[COR] Invalid command')
		end
	else
		atc('[COR] Incorrect job, skipping.')
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
		atc('[WS]: AutoWS DISABLED')
		settings.autows = false
		windower.send_command('gs c set autowsmode off')
	elseif cmd2 == 'on' then
		atc('[WS]: AutoWS ACTIVE')
		settings.autows = true
		windower.send_command('gs c set autowsmode on')
	else
		atcwarn('[WS]: Invalid parameter specified.')
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

function rng(cmd2)
	local player_job=windower.ffxi.get_player()
	local RangedJobs = S{'RNG','COR'}
	
	if cmd2 == 'off' then
		atc('RNG Helper DISABLED')
		settings.rangedmode = false
		if RangedJobs:contains(player_job.main_job) then
			windower.send_command('gs c set rnghelper off')
		end
	elseif cmd2 == 'on' then
		atc('RNG Helper ACTIVE')
		settings.rangedmode = true
		if RangedJobs:contains(player_job.main_job) then
			windower.send_command('gs c set rnghelper on')
		end
	end
	display_box()
end


function buy(cmd2,leader_buy)
	local player=windower.ffxi.get_player()
	
	if cmd2 == 'on' then
		atc('[BUY] ON, loading addons.')
		settings.buy = true
		windower.send_command('lua r powder; wait 1; lua r sparks; wait 1; lua r sellnpc')
	elseif cmd2 == 'off' then
		atc('[BUY] OFF, unloading addons.')
		settings.buy = false
		windower.send_command('lua u powder; wait 1; lua u sparks; wait 1')
	end

	-- ACTIVE	
	if settings.buy then
		if (cmd2 == 'shield' and player.name == leader_buy) then
			atc('[BUY] Single character shields.')
			windower.send_command('sparks buyall acheron shield')		
		elseif cmd2 == 'powder' then
			atc('[BUY] Powder.')
			windower.send_command('powder buy 3315; wait 15; fa prize powder')
		elseif cmd2 == 'ss' then
			windower.send_command('sellnpc s')
			local targetid = windower.ffxi.get_mob_by_name('Corua')
			windower.send_command('settarget ' .. targetid.id)
			windower.send_command('wait 2.1; input /lockon; wait 1; setkey enter down; wait 0.5; setkey enter up;')
		elseif cmd2 == 'sp' then
			windower.send_command('sellnpc p')
			local targetid = windower.ffxi.get_mob_by_name('Corua')
			windower.send_command('settarget ' .. targetid.id)
			windower.send_command('wait 2.1; input /lockon; wait 1; setkey enter down; wait 0.5; setkey enter up; wait 15; fa prize powder')
		elseif cmd2 == 're' then
			windower.send_command('lua r sparks; wait 0.5; lua r powder;')
		elseif cmd2 == 'allshields' and player.name == leader_buy then
			atc('[BUY] All characters buy shields.')
			
			for k, v in pairs(windower.ffxi.get_party()) do
				if type(v) == 'table' then
					if v.name ~= player.name then
						coroutine.sleep(2)
						ptymember = windower.ffxi.get_mob_by_name(v.name)
						-- check if party member in same zone.

						if v.mob == nil then
							-- Not in zone.
							atc('[BUY] ' ..v.name .. ' is not in zone, skipping buying shields.')
							coroutine.sleep(0.5)
						else
							-- In zone, do distance check
							if math.sqrt(ptymember.distance) < 8  and windower.ffxi.get_mob_by_name(v.name).in_party then
								coroutine.sleep(1.63)
								windower.send_command('send ' .. v.name .. ' sparks buyall acheron shield')
								atc('[BUY] Buying shields for: ' .. v.name)
								coroutine.sleep(47)
							else
								atc('[BUY] ' ..v.name .. ' is too far to buy shields with sparks, skipping')
								coroutine.sleep(0.5)
							end
						end
					end
				end
			end
			-- Buy shield for self
			windower.send_command('sparks buyall acheron shield')
			coroutine.sleep(47)
			atc('[BUY] All done buying shields.')
		end
	end
	display_box()
end

function buffup()
	atc('[Buffup] Buffing up jobs.')
	local player_job = windower.ffxi.get_player()
	local buff_jobs = S{"WHM","RDM","GEO","BRD","SMN","BLM","SCH","RUN"}
	if buff_jobs:contains(player_job.main_job) then
		windower.send_command('gs c buffup')
	else
		atc('[Buffup] Not a buffup job')
	end
end

function gt(term)
	if (term ~= nil) then
		local targetid = windower.ffxi.get_mob_by_name('' ..term.. '')
		if targetid and targetid.valid_target then
			atc('[GT] Target: ' .. term .. ' ID: ' .. targetid.id)
			windower.send_command('settarget ' .. targetid.id)
		else
			atc('[GT] Target is not valid or too far.')
		end
	else
		atc('[GT] No target specified!')
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
	atc('[Send] Sending all chars with delay: \"' .. commands .. '\"')
	windower.send_command(commands)
end

function fps(cmd2)
	if cmd2 == "30" then
		atc('[FPS] Set to 30')
		windower.send_command('config FrameRateDivisor 2')
	elseif cmd2 == "60" then
		atc('[FPS] Set to 60')
		windower.send_command('config FrameRateDivisor 1')
	end
end

function as(cmd,namearg)

	currentPC=windower.ffxi.get_player()
	if cmd == 'melee' then
		if currentPC.name:lower() == namearg:lower() then
			atc('[Assist] Leader for assisting - Melee ONLY')
			windower.send_command('hb assist off')
			windower.send_command('hb assist attack off')
		else
			local player_job = windower.ffxi.get_player()
			local MeleeJobs = S{'WAR','SAM','DRG','DRK','NIN','MNK','COR','BLU','PUP','DNC','RUN','PLD','THF','BST','RNG'}		
			if MeleeJobs:contains(player_job.main_job) then
				atc('[Assist] Attack -> ' ..namearg)
				windower.send_command('hb assist ' .. namearg)
				windower.send_command('hb f ' .. namearg)
				windower.send_command('wait 0.5; hb assist attack on')
				windower.send_command('wait 0.5; hb on')
			else
				atc('[Assist] Disabling assist, not melee job.')
				windower.send_command('hb assist off')
				windower.send_command('hb assist attack off')
			end
		end
	elseif cmd == 'mag' then
		if currentPC.name:lower() == namearg:lower() then
			atc('[Assist] Leader for assisting - Melee+Mage BRD')
			windower.send_command('hb assist off')
			windower.send_command('hb assist attack off')
		else
			local player_job = windower.ffxi.get_player()
			local MeleeJobs = S{'WAR','SAM','DRG','DRK','NIN','MNK','COR','BLU','PUP','DNC','RUN','PLD','THF','BST','RNG','BRD'}		
			if MeleeJobs:contains(player_job.main_job) then
				atc('[Assist] Attack -> ' ..namearg)
				windower.send_command('hb assist ' .. namearg)
				windower.send_command('hb f ' .. namearg)
				windower.send_command('wait 0.5; hb assist attack on')
				windower.send_command('wait 0.5; hb on')
			else
				atc('[Assist] Disabling assist, not melee job.')
				windower.send_command('hb assist off')
				windower.send_command('hb assist attack off')
			end
		end
	elseif cmd == 'all' then
		if currentPC.name:lower() == namearg:lower() then
			atc('[Assist] Leader for assisting attack - ALL JOBS')
			windower.send_command('hb assist off')
			windower.send_command('hb assist attack off')
		else
			atc('[Assist] Attack -> ' .. namearg)
			windower.send_command('hb assist ' .. namearg)
			windower.send_command('wait 0.5; hb assist attack on')
			windower.send_command('wait 0.5; hb on')
		end
	elseif cmd == 'on' then
		if currentPC.name:lower() == namearg:lower() then
			atc('[Assist] Leader for assisting in spells - ALL JOBS')
			windower.send_command('hb assist off')
			windower.send_command('hb assist attack off')
			windower.send_command('wait 0.5; hb on')
		else
			atc('[Assist] Spell only -> ' ..namearg)
			windower.send_command('hb assist ' .. namearg)
		end
	elseif cmd == 'off' then
		atc('[Assist] OFF')
		windower.send_command('hb assist off; hb assist attack off')
	end
end

function d2()

	player = windower.ffxi.get_player()
	get_spells = windower.ffxi.get_spells()
	spell = S{player.main_job_id,player.sub_job_id}[4] and (get_spells[261] 
		and {japanese='デジョン',english='"Warp"'} or get_spells[262] 
		and {japanese='デジョンII',english='"Warp II"'})
	
	if spell then
	-- Have right job/sub job and spells

		for k, v in pairs(windower.ffxi.get_party()) do
		
			if type(v) == 'table' then
				if v.name ~= currentPC.name then
	
					ptymember = windower.ffxi.get_mob_by_name(v.name)
					-- check if party member in same zone.

					if v.mob ~= nil and math.sqrt(ptymember.distance) < 19 and windower.ffxi.get_mob_by_name(v.name).in_party then
						-- Checking recast
						check_mp_rest(262)
						coroutine.sleep(1.5)
						atc('[D2] Warping ' .. v.name)
						windower.send_command('input /ma "Warp II" ' .. v.name)
						coroutine.sleep(2.0)

						--Check if still casting
						while isCasting do
							coroutine.sleep(0.5)
						end
					end

				end
				
			end
		end

		-- Warp self
		check_mp_rest(261)
		coroutine.sleep(2.2)
		atc('[D2] Warping')
		windower.send_command('input /ma "Warp" ' .. currentPC.name)
	else
		atc('[D2] Not BLM main or sub or no warp spells!')
	end
	
end

function check_mp_rest(spell)
	isWaiting = true
	while isWaiting == true do
		coroutine.sleep(0.75)
		
		spell_recasts = windower.ffxi.get_spell_recasts()
		playernow = windower.ffxi.get_player().vitals.mp

		if playernow and playernow >= res.spells[spell].mp_cost and spell_recasts[spell] == 0 then
			if isResting then	-- If resting then stop resting
				coroutine.sleep(2.5)
				windower.send_command('input /heal')
			end
			isWaiting = false
		elseif spell_recasts[spell] > 0 then -- Recast
			coroutine.sleep(1.8)
		else --Not enough MP 
			if not isResting then	-- If not resting then rest
				atc('[MP Check] Resting for MP')
				windower.send_command('input /heal')
				coroutine.sleep(3)
			end
			isWaiting = true
		end
	end
end

-- Burn functions SMN/GEO
function burn(cmd2,cmd3)
	
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
				atc('[BurnSet] DIA ON')
			elseif cmd3 == 'off' then
				settings.dia = false
				atc('[BurnSet] DIA OFF')
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
						ptymember = windower.ffxi.get_mob_by_name(v.name)
						if v.mob == nil or not ptymember.valid_target then
							atcwarn('[BurnSet] ' ..v.name .. ' is not in zone or out of range.')
						else
							atc('[BurnSet] Initialize HB and assist, and disabled cures')
							
							local healers = S{'COR','WHM','RDM','RUN','THF','SCH'}
							-- Potential healers or /SJ healers don't disable hb.
							if not (healers:contains(player.main_job)) then
								windower.send_command('hb reload; wait 1.5; hb disable cure; hb disable na; hb assist ' ..settings.assist .. '; wait 1.0; hb on')
							end
							if player.main_job == 'THF' then
								atc('[BurnSet] THF Init')
								windower.send_command('wait 1.0; hb f dist 1.5; hb f ' ..settings.assist)
								windower.send_command('hb disable cure; hb disable na; hb assist ' ..settings.assist .. '; wait 1.0; hb on')
							elseif player.main_job == 'RUN' then
								atc('[BurnSet] RUN Init')
								windower.send_command('gs c set autobuffmode off; hb f off; gs c set runeelement tenebrae')
								if settings.indi == 'malaise' then
									windower.send_command('gs c set runeelement ignis')
								end
							elseif player.main_job == 'COR' then
								atc('[BurnSet] COR Init')
								windower.send_command('hb reload; wait 1.5; hb on')
								if settings.indi == 'malaise' then
									windower.send_command('roll roll1 beast; wait 1.0; roll roll2 pup;')
								else
									windower.send_command('roll roll1 beast; wait 1.0; roll roll2 drachen;')
								end
							elseif player.main_job == 'SMN' then
								atc('[BurnSet] SMN Init')
								if settings.avatar == 'ramuh' then
									windower.send_command('input /ma "Ramuh" <me>; gs c set avatar ramuh;')
								elseif settings.avatar == 'ifrit' then
									windower.send_command('input /ma "Ifrit" <me>; gs c set avatar ifrit')
								elseif settings.avatar == 'siren' then
									windower.send_command('input /ma "Siren" <me>; gs c set avatar siren')
								end
							elseif player.main_job == 'GEO' then
								atc('[BurnSet] GEO Init')
								windower.send_command('gs c set autobuffmode off')
								if settings.indi == 'torpor' then
									windower.send_command('gs c autogeo frailty; wait 1; gs c autoindi torpor')
									windower.send_command('input /ma "Indi-Torpor" <me>;')
								elseif settings.indi == 'malaise' then
									windower.send_command('gs c autogeo frailty; wait 1; gs c autoindi malaise')
									windower.send_command('wait 2.0; hb follow ' ..settings.assist .. '; wait 1.0; hb f dist 5')
									windower.send_command('input /ma "Indi-Malaise" <me>;')
								elseif settings.indi == 'refresh' then
									windower.send_command('gs c autogeo frailty; wait 1; gs c autoindi refresh')
									windower.send_command('input /ma "Indi-Refresh" <me>;')
								elseif settings.indi == 'fury' then
									windower.send_command('gs c autogeo frailty; wait 1; gs c autoindi fury')
									windower.send_command('input /ma "Indi-Fury" <me>;')
								end
							end
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
						ptymember = windower.ffxi.get_mob_by_name(v.name)
						if v.mob == nil or not ptymember.valid_target then
							atcwarn('[BurnSet] ' ..v.name .. ' is not in zone or too far away, HB will NOT function correctly.')
						else
							atc('You are now assisting ' ..cmd3)
							settings.assist = cmd3
						end
					end
				end
			end
		else
			atc('[BurnSet] Missing argument for ASSIST')
		end
	else
		atc('[BurnSet] Invalid command')
	end
	display_box()
end

function smn(cmd2,leader_smn,cmd3)
	currentPC=windower.ffxi.get_player()

	if cmd2 and cmd2:lower() == 'on' then
		atc('[SMN] Helper for SMN ON')
		settings.smnhelp = true
	elseif cmd2 and cmd2:lower() == 'off' then
		atc('[SMN] Helper for SMN OFF')
		settings.smnhelp = false
	elseif cmd2 == nil then
		if settings.smnhelp then
			atc('[SMN] Helper for SMN OFF')
			settings.smnhelp = false
		else
			atc('[SMN] Helper for SMN ON')
			settings.smnhelp = true
		end
	end
	
	--Active
	if settings.smnhelp then
		
		if cmd2 and cmd2:lower() == 'sc' then
			if cmd3 and cmd3:lower() == 'on' then
				atc('[SMN] SC ON')
				settings.smnsc = true
			elseif cmd3 and cmd3:lower() == 'off' then
				atc('[SMN] SC OFF')
				settings.smnsc = false
			end
			-- if settings.smnsc then
				-- atc('SMN Skillchain DISABLED')
				-- settings.smnsc = false
			-- else
				-- atc('SMN Skillchain ACTIVE')
				-- settings.smnsc = true
			-- end
		elseif cmd2 and cmd2:lower() == 'auto' then
			if cmd3 and cmd3:lower() == 'off' then
				atc('[SMN] Auto OFF')
				settings.smnauto = false
				if currentPC.main_job == 'SMN' then
					windower.send_command('gs c set AutoAvatarMode off; gs c set AutoBPMode off; gs c set AutoSMNSCMode off;')
				end
			-- if settings.smnauto then
				-- atc('SMN Auto DISABLED')
				-- settings.smnauto = false
				-- if currentPC.main_job == 'SMN' then
					-- windower.send_command('gs c set AutoAvatarMode off; gs c set AutoBPMode off')
				-- end
			elseif cmd3 and cmd3:lower() == 'on' then
				--Auto SC
				if settings.smnsc then
					if settings.smnlead ~= nil then
						atc('[SMN] Auto ON')
						settings.smnauto = true
						-- Leader does AutoBP and Ramuh
						if currentPC.name:lower() == settings.smnlead and currentPC.main_job == 'SMN' then
							windower.send_command('gs c set avatar Ramuh; gs c set AutoBPMode on; gs c set AutoSMNSCMode on;')
						-- Other SMN's use Ifrit and just autoavatar
						else
							if currentPC.main_job == 'SMN' then
								windower.send_command('gs c set avatar Ifrit; gs c set AutoBPMode off; gs c set AutoAvatarMode on')
							end
						end
					else
						atcwarn('[SMN] No leader, cannot start Auto BP SC')
					end
				--BP Spam
				else
					if currentPC.main_job == 'SMN'  then
						windower.send_command('gs c set avatar Ramuh; gs c set AutoBPMode on')
					end
					settings.smnauto = true
				end
			end
		elseif cmd2 and cmd2:lower() == 'lead' and cmd3 ~= nil then
			settings.smnlead = cmd3
		end
		-- SMN Auto/manual logic
		if currentPC.main_job == 'SMN' then
			if cmd2 then
				if cmd2:lower() == 'assault' then
					windower.send_command('input /ja "Assault" <t>')
				elseif cmd2:lower() == 'release' then
					windower.send_command('input /ja "Release" <me>')
				elseif cmd2:lower() == 'retreat' then
					windower.send_command('input /ja "Retreat" <me>')
				elseif cmd2:lower() == 'vs' then
					if settings.smnsc then
						if currentPC.name ~= leader_smn then
							windower.send_command('wait 4.0; input /ja "Flaming Crush" <t>')
						end
					else
						windower.send_command('input /ja "Volt Strike" <t>')
					end
				elseif cmd2:lower() == 'fc' then
					if settings.smnsc then
						if currentPC.name ~= leader_smn then
							windower.send_command('wait 4.0; input /ja "Volt Strike" <t>')
						end
					else
						windower.send_command('input /ja "Flaming Crush" <t>')
					end
				elseif cmd2:lower() == 'ha' then
					if settings.smnsc then
						if currentPC.name ~= leader_smn then
							windower.send_command('wait 4.0; input /ja "Flaming Crush" <t>')
						end
					else
						windower.send_command('input /ja "Hysteric Assault" <t>')
					end				
				elseif cmd2:lower() == 'ramuh' then
					if settings.smnsc then
						if currentPC.name ~= leader_smn then
							windower.send_command('input /ma "Ifrit" <me>')
						end
					else
						windower.send_command('input /ma "Ramuh" <me>')
					end
				elseif cmd2:lower() == 'ifrit' then
					if settings.smnsc then
						if currentPC.name ~= leader_smn then
							windower.send_command('input /ma "Ramuh" <me>')
						end
					else
						windower.send_command('input /ma "Ifrit" <me>')
					end
				elseif cmd2:lower() == 'siren' then
					if settings.smnsc then
						if currentPC.name ~= leader_smn then
							windower.send_command('input /ma "Ifrit" <me>')
						end
					else
						windower.send_command('input /ma "Siren" <me>')
					end
				elseif cmd2:lower() == 'apogee' then
					windower.send_command('input /ja "Apogee" <me>')
				elseif cmd2:lower() == 'thunderspark' then
					windower.send_command('input /ja "Thunderspark" <t>')
				elseif cmd2:lower() == 'thunderstorm' then
					windower.send_command('input /ja "thunderstorm" <t>')
				elseif cmd2:lower() == 'NB' then
					windower.send_command('input /ja "Nether Blast" <t>')
				elseif cmd2:lower() == 'diabolos' then
					windower.send_command('input /ma "Diabolos" <me>')
				elseif cmd2:lower() == 'super' then
					windower.send_command('input /item "Super Revitalizer" <me>')
				elseif cmd2:lower() == 'elixir' then
					windower.send_command('input /item "Lucid Elixir II" <me>')
					windower.send_command('input /item "Lucid Elixir I" <me>')
				end
			end
		end
	end
	display_box()
end	

function autosc(cmd2, leader_rng)
	currentPC=windower.ffxi.get_player()
	
	local rangedjobs = S{'COR','SCH','BLM','RUN'}

	if cmd2 == nil then
		if settings.autosc then
			atc('Helper for Auto SC DISABLED')
			settings.autosc = false
		else
			atc('Helper for Auto SC ACTIVE')
			settings.autosc = true
		end
	end
	
	
	if settings.autosc then
		if rangedjobs:contains(currentPC.main_job) then
			if cmd2 and cmd2:lower() == 'freezebite' then
				if currentPC.main_job == 'SCH' then				
					atc('[AUTOSC] ENDING SCH - Water [Fragmentation]')
					windower.send_command('input /ja "Immanence" <me>')
					windower.send_command:schedule(3.4, 'gs c elemental tier1 Raskovniche')
				elseif currentPC.main_job == 'COR' then
					atc('[AUTOSC] COR Last Stand')
					local abil_recasts = windower.ffxi.get_ability_recasts()
					local latency = 0.7
					if abil_recasts[195] < latency then
						windower.send_command:schedule(3.7, 'input /ja "Wind Shot" <t>')
					end
					windower.send_command:schedule(10.1, 'input /ws "Last Stand" <t>')
					windower.send_command:schedule(13.5, 'autora start')
				elseif currentPC.main_job == 'BLM' then
					atc('[AUTOSC] BLM PreNuke')
					windower.send_command:schedule(3.9, 'gs c elemental aja Raskovniche')
				elseif currentPC.main_job == 'RUN' then
					local abil_recasts = windower.ffxi.get_ability_recasts()
					local latency = 0.7
					atc('[AUTOSC] Rayke/Gambit')
					--windower.send_command:schedule(3.2, 'gs c set autowsmode off')
					if abil_recasts[116] < latency then
						windower.send_command('gs c set autotankmode off; gs c set autobuffmode off; gs c set autorunemode off')
						windower.send_command:schedule(2.5, 'input /p Gambit - 86s duration; wait 86; input /p Gambit OFF! <scall20>')
						windower.send_command:schedule(3.1, 'input /ja "Gambit" <t>')
						windower.send_command:schedule(4.2, 'gs c set autotankmode on; gs c set autorunemode on')
					elseif abil_recasts[119] < latency then
						windower.send_command('gs c set autotankmode off; gs c set autobuffmode off; gs c set autorunemode off')
						windower.send_command:schedule(2.5, 'input /p Rayke - 44s duration; wait 44; input /p Rayke OFF! <scall20>')
						windower.send_command:schedule(3.1, 'input /ja "Rayke" <t>')
						windower.send_command:schedule(4.2, 'gs c set autotankmode on; gs c set autorunemode on')
					end
				end
			elseif cmd2 and cmd2:lower() == 'frostbite' then
				if currentPC.main_job == 'SCH' then				
					atc('[AUTOSC] ENDING SCH - Water [Fragmentation]')
					windower.send_command('input /ja "Immanence" <me>')
					windower.send_command:schedule(3.4, 'gs c elemental tier1 Marmorkrebs')
				elseif currentPC.main_job == 'COR' then
					atc('[AUTOSC] COR Last Stand')
					local abil_recasts = windower.ffxi.get_ability_recasts()
					local latency = 0.7
					if abil_recasts[195] < latency then
						windower.send_command:schedule(3.7, 'input /ja "Thunder Shot" <t>')
					end
					windower.send_command:schedule(10.1, 'input /ws "Last Stand" <t>')
					windower.send_command:schedule(13.5, 'autora start')
				elseif currentPC.main_job == 'BLM' then
					atc('[AUTOSC] BLM PreNuke')
					windower.send_command:schedule(3.9, 'gs c elemental aja Marmorkrebs')
				elseif currentPC.main_job == 'RUN' then
					local abil_recasts = windower.ffxi.get_ability_recasts()
					local latency = 0.7
					atc('[AUTOSC] Rayke/Gambit')
					--windower.send_command:schedule(3.2, 'gs c set autowsmode off')
					if abil_recasts[116] < latency then
						windower.send_command('gs c set autotankmode off; gs c set autobuffmode off; gs c set autorunemode off')
						windower.send_command:schedule(3.1, 'input /ja "Gambit" <t>')
						windower.send_command:schedule(4.2, 'gs c set autotankmode on; gs c set autorunemode on')
					elseif abil_recasts[119] < latency then
						windower.send_command('gs c set autotankmode off; gs c set autobuffmode off; gs c set autorunemode off')
						windower.send_command:schedule(3.1, 'input /ja "Rayke" <t>')
						windower.send_command:schedule(4.2, 'gs c set autotankmode on; gs c set autorunemode on')
					end
				end
			--Upheaval > Gambit/Rayke/Earth Shot > Leaden Saluate > Steel Cyclone > Wild fire.
			elseif cmd2 and cmd2:lower() == 'upheaval' then
				if currentPC.main_job == 'COR' then
					atc('[AUTOSC] COR Leaden and Earth Shot')
					local abil_recasts = windower.ffxi.get_ability_recasts()
					local latency = 0.7
					if abil_recasts[195] < latency then
						windower.send_command:schedule(1.7, 'input /ja "Earth Shot" <t>')
					end
					windower.send_command:schedule(3.4, 'input /ws "Leaden Salute" <t>')
					windower.send_command:schedule(7.2, 'autora start')
					windower.send_command:schedule(16.3, 'input /ws "Wildfire" <t>')
					windower.send_command:schedule(20.1, 'autora start')
				elseif currentPC.main_job == 'RUN' then
					local abil_recasts = windower.ffxi.get_ability_recasts()
					local latency = 0.7
					windower.send_command('hb off; gs c set autotankmode off; gs c set autobuffmode off; gs c set autorunemode off; gs c set autowsmode off')
					atc('[AUTOSC] Rayke/Gambit')
					if abil_recasts[116] < latency then
						windower.send_command:schedule(1.8, 'input /ja "Gambit" <t>')
					elseif abil_recasts[119] < latency then
						windower.send_command:schedule(1.8, 'input /ja "Rayke" <t>')
					end
					windower.send_command:schedule(12.0, 'input /ws "Steel Cyclone" <t>')
					windower.send_command:schedule(14.2, 'gs c set autotankmode on; gs c set autorunemode on')
					--windower.send_command:schedule(25, 'gs c set autowsmode on;')
				elseif currentPC.main_job == 'BLM' then
					atc('[AUTOSC] BLM PreNuke')
					windower.send_command:schedule(4.1, 'gs c elemental aja Ongo')
				end
			end
		else
			atc('[AUTOSC] Not COR/RUN/SCH/BLM job, skipping.')
		end
	end
	display_box()
end	


function geoburn()
	
	player = windower.ffxi.get_player()
	local target = windower.ffxi.get_mob_by_target('t')
	local world = res.zones[windower.ffxi.get_info().zone].name

	if settings.active and settings.assist ~= '' and not(areas.Cities:contains(world)) then
		if player.main_job == 'GEO' then
			if target and target.is_npc == true and target.valid_target == true then
				atcwarn('[GEOBurn]: GEO Burn Activated for Bolster!')
				
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
				atcwarn('[GEOBurn]: CANCELLING, NO TARGET!')
			end
		else
			atc('[GEOBurn]: Not GEO job.')
		end
	else
		atc('[GEOBurn]: Not active or in city zone.')
	end
end

function smnburn()

	player = windower.ffxi.get_player()
	local target = windower.ffxi.get_mob_by_target('t')
	local world = res.zones[windower.ffxi.get_info().zone].name
	
	if settings.active and settings.assist ~= '' and not(areas.Cities:contains(world)) then
		if player.main_job == 'SMN' then
			if target and target.is_npc == true and target.valid_target == true then
				atcwarn('[SMNBurn]: SMN Burn Activated!')
				windower.send_command('hb on')
				-- check distance 21 or less
				coroutine.sleep(1.5)
				windower.send_command('input /ja "Astral Flow" <me>')
				coroutine.sleep(2.5)
				windower.send_command('input /ja "Assault" <t>')
				coroutine.sleep(4.2)
				windower.send_command('input /ja "Astral Conduit" <me>')
				coroutine.sleep(1.6)
				-- 9.8s
				if settings.avatar == 'ramuh' then
					if haveBuff('Vorseal') then
						windower.send_command('exec VoltStrike.txt')
					else
						windower.send_command('exec VoltStrikeREG.txt')
					end
				elseif settings.avatar == 'ifrit' then
					if haveBuff('Vorseal') then
						windower.send_command('exec FlamingCrush.txt')
					else
						windower.send_command('exec FlamingCrushREG.txt')
					end
				elseif settings.avatar == 'siren' then
					if haveBuff('Vorseal') then
						windower.send_command('exec HystericAssault.txt')
					else
						windower.send_command('exec HystericAssaultREG.txt')
					end
				end
			else
				atcwarn('[SMNBurn]: CANCELLING, NO TARGET!')
			end
		else
			atc('[SMNBurn]: Not SMN job.')
		end
	else
		atc('[SMNBurn]: Not active or in city zone.')
	end
end

-- External addons

function warp()
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

function attackon()
	atc('[ATTACK ON]')
	local player = windower.ffxi.get_player()
	local MeleeJobs = S{'WAR','SAM','DRG','DRK','NIN','MNK','COR','BLU','PUP','DNC','RUN','PLD','THF','BST','RNG','BRD'}
	if MeleeJobs:contains(player.main_job) then
		windower.send_command('input /attack on')
	end
end

function crit(cmd2)
	if cmd2 then
		atc('[CRIT]: ' .. cmd2)
	else
		atc('[CRIT] No parameter')
	end
	local player = windower.ffxi.get_player()
	local MeleeJobs = S{'RNG','COR'}
	if MeleeJobs:contains(player.main_job) then
		if cmd2 and cmd2:lower() == 'on' then
			windower.send_command('gs c set rangedmode Crit')
		elseif cmd2 and cmd2:lower() == 'off' then
			windower.send_command('gs c set rangedmode Normal')
		end
	end
end

function get(cmd2)
	local zone = windower.ffxi.get_info()['zone']
	local EschaZones = S{288,289,291}

	if cmd2 == 'mog' and zone == 247  then
		atc('GET: Obtaining Moglophone KI.')
		get_poke_check_id('17789078')
		windower.send_command('wait 3; setkey enter down; wait 0.5; setkey enter up; wait 2; setkey escape down; wait 0.3; setkey escape up;')
	elseif cmd2 == 'mog2' and zone == 247 then
		atc('GET: Moglophone II.')
		get_poke_check_id('17789078')
		windower.send_command('wait 3; setkey down down; wait 0.05; setkey down up; wait 1; setkey down down; wait 0.05; setkey down up; wait 1; setkey down down; wait 0.05; setkey down up; wait 1; setkey down down; wait 0.05; setkey down up; wait 3.5; setkey enter down; wait 0.5; setkey enter up; wait 2.0; setkey enter down; wait 0.5; setkey enter up; wait 1.3; ')
	elseif cmd2 == 'pot' and zone == 291 then
		atc('GET: Potpourri KI')
		get_poke_check('Emporox')
		windower.send_command('wait 3; setkey right down; wait 1; setkey right up; wait 2; setkey up down; wait 0.1; setkey up up; wait 2; setkey enter down; wait 0.5; setkey enter up; wait 2; setkey up down; wait 0.1; setkey up up; wait 2; setkey enter down; wait 0.5; setkey enter up;')
	elseif cmd2 == 'srki' and zone == 276  then
		atc('GET: SR KI.')
		get_poke_check('Malobra')
		windower.send_command('wait 1.1; setkey down down; wait 0.1; setkey down up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 1.0; setkey up down; wait 0.5; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
	elseif cmd2 == 'srdrops' and zone == 276 then
		atc('GET: SR Rewards.')
		get_poke_check('Malobra')
		windower.send_command('wait 1; setkey down down; wait 0.1; setkey down up; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
	elseif cmd2 == 'tag' and zone == 50 then
		atc('GET: Assault tag.')
		get_poke_check('Rytaal')
		windower.send_command('wait 2; setkey enter down; wait 0.5; setkey enter up;')
	elseif cmd2 == 'nyzul' and zone == 50 then
		atc('GET: Nyzul tag.')
		get_poke_check('Sorrowful Sage')
		windower.send_command('wait 2; setkey enter down; wait 0.5; setkey enter up; wait 0.75; setkey enter down; wait 0.5; setkey enter up; wait 0.75; setkey up down; wait 0.3; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
	elseif cmd2 == 'canteen' and zone == 291 then
		atc('GET: Omen Canteen.')
		get_poke_check('Incantrix')
		windower.send_command('wait 3; setkey enter down; wait 0.5; setkey enter up;')
	elseif cmd2 == 'mgexit' and zone == 280 then
		atc('GET: Exit Mog Garden.')
		get_poke_check_id('17924124')
		if npc_dialog == true then
			windower.send_command('wait 3; setkey right down; wait 0.5; setkey right up; wait 1.0; ' .. 
				'setkey right down; wait 0.5; setkey right up; wait 1.0; setkey up down; wait 0.1; setkey up up; wait 1.0; ' ..
				'setkey enter down; wait 0.5; setkey enter up; wait 1.5; setkey right down; wait 0.1; setkey right up; wait 1.0; ' ..
				'setkey enter down; wait 0.5; setkey enter up;')
		end
	elseif cmd2 == 'gobbiekey' and zone == 239 then
		atc('GET: Gobbie Key.')
		get_poke_check('Arbitrix')
		if npc_dialog == true then
			windower.send_command('wait 3; setkey enter down; wait 0.5; setkey enter up; wait 1.5; setkey right down; wait 1.0; setkey right up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 9; setkey escape down; wait 0.05; setkey escape up; ')
		end
	elseif cmd2 == 'abystone' and zone == 246 then
		atc('GET: Abyssea - Traveler Stone')
		get_poke_check('Joachim')
		if npc_dialog == true then
			windower.send_command('wait 3; setkey enter down; wait 0.5; setkey enter up;')
		end
	elseif cmd2 == 'aby' and areas.Abyssea:contains(zone) then
		atc('GET: Abyssea Visitation - Remaining time')
		get_poke_check('Conflux Surveyor')
		if npc_dialog == true then
			windower.send_command('wait 3; setkey down down; wait 0.05; setkey down up; wait 1; setkey down down; wait 0.05; setkey down up; wait 1.5; setkey enter down; wait 0.5; setkey enter up; wait 1.5; ' ..
				'setkey down down; wait 0.05; setkey down up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 1.5;' ..
				'setkey up down; wait 0.05; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 1.5; setkey up down; wait 0.05; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
		end
	elseif cmd2 == 'aby1' and areas.Abyssea:contains(zone) then
		atc('GET: Abyssea Visitation - 1 Stone')
		get_poke_check('Conflux Surveyor')
		if npc_dialog == true then
			windower.send_command('wait 3; setkey down down; wait 0.05; setkey down up; wait 1; setkey down down; wait 0.05; setkey down up; wait 1.5; setkey enter down; wait 0.5; setkey enter up; wait 1.5; ' ..
				'setkey down down; wait 0.05; setkey down up; wait 1.0; setkey down down; wait 0.05; setkey down up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 1.5;' ..
				'setkey up down; wait 0.05; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 1.5; setkey up down; wait 0.05; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
		end
	elseif cmd2 == 'aby2' and areas.Abyssea:contains(zone) then
		atc('GET: Abyssea Visitation - 2 Stone')
		get_poke_check('Conflux Surveyor')
		if npc_dialog == true then
			windower.send_command('wait 3; setkey down down; wait 0.05; setkey down up; wait 1; setkey down down; wait 0.05; setkey down up; wait 1.5; setkey enter down; wait 0.5; setkey enter up; wait 1.5; ' ..
				'setkey down down; wait 0.05; setkey down up; wait 1.0; setkey down down; wait 0.05; setkey down up; wait 1.0; setkey down down; wait 0.05; setkey down up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 1.5;' ..
				'setkey up down; wait 0.05; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 1.5; setkey up down; wait 0.05; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
		end
	elseif cmd2 == 'moll' and EschaZones:contains(zone) then
		atc('GET: Mollifier')
		if not find_missing_ki(cmd2) then
			if zone == 288 then
				get_poke_check('Affi')
			elseif zone == 289 then
				get_poke_check('Dremi')
			elseif zone == 291 then
				get_poke_check('Shiftrix')
			end
			if npc_dialog == true then
				windower.send_command('wait 4.7; setkey right down; wait 1.5; setkey right up; wait 0.5; setkey up down; wait 0.05; setkey up up; wait 0.5; setkey up down; wait 0.05; setkey up up; wait 0.5; setkey up down; wait 0.05; setkey up up; wait 0.5; setkey up down; wait 0.05; setkey up up; wait 0.5; setkey up down; wait 0.05; setkey up up; wait 0.5; setkey up down; wait 0.05; setkey up up; wait 0.5; setkey enter down; wait 0.5; setkey enter up; wait 1.0; ' ..
					'setkey right down; wait 1.2; setkey right up; wait 0.5; setkey enter down; wait 0.5; setkey enter up; wait 1.0; ' ..
					'setkey up down; wait 0.05; setkey up up; wait 0.5; setkey enter down; wait 0.5; setkey enter up; wait 2.5; setkey escape down; wait 0.05; setkey escape up;')
			end
		else
			atc('GET: Already have Mollifier!')
		end
	elseif cmd2 == 'trib' and EschaZones:contains(zone) then
		atc('GET: Tribulens')
		if not find_missing_ki(cmd2) then
			if zone == 288 then
				get_poke_check('Affi')
			elseif zone == 289 then
				get_poke_check('Dremi')
			elseif zone == 291 then
				get_poke_check('Shiftrix')
			end
			if npc_dialog == true then
				windower.send_command('wait 4.7; setkey right down; wait 1.5; setkey right up; wait 0.5; setkey up down; wait 0.05; setkey up up; wait 0.5; setkey up down; wait 0.05; setkey up up; wait 0.5; setkey up down; wait 0.05; setkey up up; wait 0.5; setkey up down; wait 0.05; setkey up up; wait 0.5; setkey up down; wait 0.05; setkey up up; wait 0.5; setkey up down; wait 0.05; setkey up up; wait 0.5; setkey enter down; wait 0.5; setkey enter up; wait 1.0; ' ..
			--	windower.send_command('wait 4.7; setkey down down; wait 0.05; setkey down up; wait 1; setkey down down; wait 0.05; setkey down up; wait 1.5; setkey enter down; wait 0.5; setkey enter up; wait 1.5; ' ..
					'setkey down down; wait 0.05; setkey down up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 1.5; ' ..
					'setkey up down; wait 0.05; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 2.5; setkey escape down; wait 0.05; setkey escape up;')
			end
		else
			atc('GET: Already have Tribulens!')
		end
	-- elseif cmd2 == 'rads' and EschaZones:contains(zone) then
		-- atc('GET: Radialens')
		-- if not find_missing_ki(cmd2) then
			-- if zone == 288 then
				-- get_poke_check('Affi')
			-- elseif zone == 289 then
				-- get_poke_check('Dremi')
			-- elseif zone == 291 then
				-- get_poke_check('Shiftrix')
			-- end
			-- if npc_dialog == true then
				-- if find_missing_ki('moll') then
					-- windower.send_command('wait 4.7; setkey right down; wait 1.5; setkey right up; wait 0.5; setkey up down; wait 0.05; setkey up up; wait 0.5; setkey up down; wait 0.05; setkey up up; wait 0.5; setkey up down; wait 0.05; setkey up up; wait 0.5; setkey up down; wait 0.05; setkey up up; wait 0.5; setkey up down; wait 0.05; setkey up up; wait 0.5; setkey up down; wait 0.05; setkey up up; wait 0.5; setkey enter down; wait 0.5; setkey enter up; wait 1.0; ' ..
-- --					windower.send_command('wait 4.7; setkey down down; wait 0.05; setkey down up; wait 1; setkey down down; wait 0.05; setkey down up; wait 1.5; setkey enter down; wait 0.5; setkey enter up; wait 1.5; ' ..
						-- 'setkey right down; wait 1.2; setkey right up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 1.5; ' ..
						-- 'setkey up down; wait 0.05; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 2.5; setkey escape down; wait 0.05; setkey escape up;')
				-- else
					-- windower.send_command('wait 4.7; setkey right down; wait 1.5; setkey right up; wait 0.5; setkey up down; wait 0.05; setkey up up; wait 0.5; setkey up down; wait 0.05; setkey up up; wait 0.5; setkey up down; wait 0.05; setkey up up; wait 0.5; setkey up down; wait 0.05; setkey up up; wait 0.5; setkey up down; wait 0.05; setkey up up; wait 0.5; setkey up down; wait 0.05; setkey up up; wait 0.5; setkey enter down; wait 0.5; setkey enter up; wait 1.0; ' ..
	-- --				windower.send_command('wait 4.7; setkey down down; wait 0.05; setkey down up; wait 1; setkey down down; wait 0.05; setkey down up; wait 1.5; setkey enter down; wait 0.5; setkey enter up; wait 1.5; ' ..
						-- 'setkey right down; wait 1.2; setkey right up; wait 1.0; setkey up down; wait 0.05; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 1.5; ' ..
						-- 'setkey up down; wait 0.05; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; wait 2.5; setkey escape down; wait 0.05; setkey escape up;')
				-- end
			-- end
		-- else
			-- atc('GET: Already have Radialens!')
		-- end
	elseif cmd2 == 'deimos' and zone == 246 then
		atc('GET: Deimos Orb, will not check if you have enough seals!')
		get_poke_check('Shami')
		if npc_dialog == true then
			windower.send_command('wait 1.6; setkey right down; wait 0.05; setkey right up; wait 1.0; setkey enter down; wait 0.5; setkey enter up; ' ..
				'setkey down down; wait 0.05; setkey down up; wait 0.75; setkey down down; wait 0.05; setkey down up; wait 0.75; setkey enter down; wait 0.5; setkey enter up; wait 0.75; setkey enter down; wait 0.5; setkey enter up; wait 0.75; ' ..
				'setkey up down; wait 0.05; setkey up up; wait 0.75; setkey enter down; wait 0.5; setkey enter up;')
		end
	else
		atc('GET: Incorrect Zone/Command.')
	end
end

function go()
	atc('[GO] TargetNPC + ENTER.')
	get_npc_dialogue('npc',2)
end

function ent()
	atc('[ENT] Sending ENTER Key.')
	windower.send_command('wait 1.5; setkey enter down; wait 0.5; setkey enter up;')
end

function macro(leader)
	local zone = windower.ffxi.get_info()['zone']
	local player = windower.ffxi.get_player()
	local deimos_zones = S{146}
		
	if deimos_zones:contains(zone) then
		if leader == player.name then
			atc('[Macro Orb] - Leader with Orb.')
			local possible_npc = find_npc_to_poke()
			if possible_npc then
				windower.send_command('wait 1; tradenpc 1 "macrocosmic orb" "Burning Circle"; wait 5.5; setkey down down; wait 0.25; setkey down up; wait 1.5; setkey enter down; wait 0.25; setkey enter up; wait 0.75; setkey left down; wait 1.05; setkey left up; wait 0.5; setkey enter down; wait 0.25; setkey enter up;')
				coroutine.sleep(20)
				if haveBuff('Battlefield') then
					local items = windower.ffxi.get_items()
					for index, item in pairs(items.inventory) do
						if type(item) == 'table' and item.id == 4063 then
							atc('[Dropping]: ' .. item.id .. ' - ' .. item.extdata)
							windower.ffxi.drop_item(index, item.count)
						end
					end
				end
			end
		else
			atc('[Macro Orb] - Others to enter.')
			coroutine.sleep(15)
			if haveBuff('Battlefield') then
				local possible_npc = find_npc_to_poke()
				if possible_npc then
					get_poke_check_index(possible_npc.index)
					if npc_dialog == true then
						windower.send_command('wait 5; setkey down down; wait 0.25; setkey down up; wait 1.5; setkey enter down; wait 0.25; setkey enter up;')
					end
				end
			else
				atc('[Macro Orb] No battlefield, leader not in entry, cancelling.')
			end
		end
	else
		atc('[Macro Orb] Not in Deimos Orb zone, cancelling.')
	end
end

function deimos(leader)
	local zone = windower.ffxi.get_info()['zone']
	local player = windower.ffxi.get_player()
	local deimos_zones = S{146}
		
	if deimos_zones:contains(zone) then
		if leader == player.name then
			atc('[Deimos Orb] - Leader with Orb.')
			local possible_npc = find_npc_to_poke()
			if possible_npc then
				windower.send_command('wait 1; tradenpc 1 "deimos orb" "Burning Circle"; wait 5.5; setkey down down; wait 0.25; setkey down up; wait 1.5; setkey enter down; wait 0.25; setkey enter up;')
				coroutine.sleep(15)
				if haveBuff('Battlefield') then
					local items = windower.ffxi.get_items()
					for index, item in pairs(items.inventory) do
						if type(item) == 'table' and item.id == 3352 then
							atc('[Dropping]: ' .. item.id .. ' - ' .. item.extdata)
							windower.ffxi.drop_item(index, item.count)
						end
					end
				end
			end
		else
			atc('[Deimos Orb] - Others to enter.')
			coroutine.sleep(11)
			if haveBuff('Battlefield') then
				local possible_npc = find_npc_to_poke()
				if possible_npc then
					get_poke_check_index(possible_npc.index)
					if npc_dialog == true then
						windower.send_command('wait 5.5; setkey down down; wait 0.25; setkey down up; wait 1.5; setkey enter down; wait 0.25; setkey enter up;')
					end
				end
			else
				atc('[Deimos Orb] No battlefield, leader not in entry, cancelling.')
			end
		end
	else
		atc('[Deimos Orb] Not in Deimos Orb zone, cancelling.')
	end
end

function enter()
	atc('[ENTER] Enter menu.')
	local zone = windower.ffxi.get_info()['zone']
	local cloister_zones = S{201,202,203,207,209,211}
	local adoulin_beam_zones = S{265,268,269,272,273}
	local wkr_zones = S{261,262,263,265,266,267}
	local deimos_zones = S{146}

	if haveBuff('Invisible') then
		windower.send_command('cancel invisible')
		coroutine.sleep(2.0)
	elseif haveBuff('Mounted') then
		windower.send_command('input /dismount')
		coroutine.sleep(2.0)
	end

	--if not contains(deimos_zones, zone) then
	if deimos_zones:contains(zone) then
		atc('[ENTER] Nothing to poke for Deimos Orb.')
	else
		local possible_npc = find_npc_to_poke()
		
		if possible_npc then
			get_poke_check_index(possible_npc.index)
		else
			get_npc_dialogue('npc',3)
		end	
	end
	
	if npc_dialog == true then
		--Shinryu
		if zone == 255 then
			if possible_npc and possible_npc.name == "Transcendental Radiance" then
				windower.send_command('wait 2.3; setkey right down; wait 0.75; setkey right up; wait 0.6; setkey enter down; wait 0.25; setkey enter up; wait 0.75; setkey left down; wait 0.5; setkey left up; wait 0.6; setkey enter down; wait 0.25; setkey enter up')
			else
				windower.send_command('wait 0.85; setkey up down; wait 0.25; setkey up up; wait 0.7; setkey enter down; wait 0.25; setkey enter up;')
			end
		--Ouryu
		elseif zone == 31 then 
			windower.send_command('wait 17; setkey down down; wait 0.75; setkey down up; wait 0.6; setkey enter down; wait 0.25; setkey enter up; wait 0.75; setkey up down; wait 0.5; setkey up up; wait 0.6; setkey enter down; wait 0.25; setkey enter up')
		--Walk of Echos
		elseif zone == 137 then
			windower.send_command('wait 2.0; setkey up down; wait 0.25; setkey up up; wait 0.7; setkey enter down; wait 0.25; setkey enter up;')
		elseif zone == 182 then
			if possible_npc and possible_npc.name == "Veridical Conflux" then
				windower.send_command('wait 1.8; setkey enter down; wait 0.25; setkey enter up;')
			else
				windower.send_command('wait 3.5; setkey right down; wait 0.5; setkey right up; wait 0.6; setkey enter down; wait 0.25; setkey enter up;')
			end
		--6 Avatars
		elseif cloister_zones:contains(zone) then
			windower.send_command('wait 6; setkey down down; wait 0.75; setkey down up; wait 0.6; setkey enter down; wait 0.25; setkey enter up; wait 0.75; setkey up down; wait 0.5; setkey up up; wait 0.6; setkey enter down; wait 0.25; setkey enter up')
		--Adoulin beam up
		elseif adoulin_beam_zones:contains(zone) then
			windower.send_command('wait 0.85; setkey down down; wait 0.25; setkey down up; wait 0.7; setkey enter down; wait 0.25; setkey enter up;')
		--WKR
		elseif wkr_zones:contains(zone) then
			windower.send_command('wait 1.3; setkey down down; wait 0.15; setkey down up; wait 0.7; setkey enter down; wait 0.25; setkey enter up; wait 1.1; setkey up down; wait 0.25; setkey up up; wait 0.7; setkey enter down; wait 0.25; setkey enter up;')
		--MG
		elseif zone == 256 or zone == 257 then
			windower.send_command('wait 1.3; setkey enter down; wait 0.5; setkey enter up;')
		--Jade
		elseif zone == 67 then
			if possible_npc then
				windower.send_command('wait 12.3; setkey down down; wait 0.15; setkey down up; wait 0.7; setkey enter down; wait 0.25; setkey enter up; wait 1.1; setkey up down; wait 1.1; setkey up up; wait 0.7; setkey enter down; wait 0.5; setkey enter up;')
			else
				atc('Not close the entry NPC, cancelling')
			end
		--General
		else
			windower.send_command('wait 0.85; setkey up down; wait 0.25; setkey up up; wait 0.7; setkey enter down; wait 0.25; setkey enter up;')
		end
	end
	
end

function endown()
	atc('[EnterDOWN]')
	windower.send_command('setkey down down; wait 0.05; setkey down up; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
end

function enup()
	atc('[EnterUP]')
	windower.send_command('setkey up down; wait 0.05; setkey up up; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
end

function esc()
	atc('[ESC]')
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

function book()
	local zone = windower.ffxi.get_info()['zone']
	local assault_zone = S{55,56,63,66,69}
	
	if assault_zone:contains(zone) then
		if zone == 55 then
			windower.send_command('get Ilrusi Ledger; wait 1.7; tradenpc 1 "Ilrusi Ledger" "Rune of Release"')
		elseif zone == 56 then
			windower.send_command('get Periqia Diary; wait 1.7; tradenpc 1 "Periqia Diary" "Rune of Release"')
		elseif zone == 63 then
			windower.send_command('get Lebros Chronicle; wait 1.7; tradenpc 1 "Lebros Chronicle" "Rune of Release"')
		elseif zone == 66 then
			windower.send_command('get Mamool Ja Journal; wait 1.7; tradenpc 1 "Mamool Ja Journal" "Rune of Release"')
		elseif zone == 69 then
			windower.send_command('get Leujaoam Log; wait 1.7; tradenpc 1 "Leujaoam Log" "Rune of Release"')
		end

	else
		atc('[Book] Not in zone.')
	end
end

function drop(cmd2)
	local rem = S{4069,4070,4071,4072,4073}
	local cells = S{5365,5366,5367,5368,5369,5370,5371,5372,5373,5374,5375,5376,5377,5378,5379,5380,5381,5382,5383,5384}

	if cmd2 == 'rem' then
		atc('[Drop] Rem Chapters 6-10')
		local items = windower.ffxi.get_items()
		for index, item in pairs(items.inventory) do
			if type(item) == 'table' and rem:contains(item.id) then
				atc('[Drop] ' .. cmd2 .. ' ' .. item.id)
				windower.ffxi.drop_item(index, item.count)
			end
		end
	elseif cmd2 == 'cells' then
		atc('[Drop] Salvage cells.')
		local items = windower.ffxi.get_items()
		for index, item in pairs(items.inventory) do
			if type(item) == 'table' and cells:contains(item.id) then
				atc('[Drop] ' .. cmd2 .. ' ' .. item.id)
				windower.ffxi.drop_item(index, item.count)
			end
		end
	else
		atc('[Drop] Nothing specified.')
	end
end

function zerg(cmd2)
	if cmd2 == 'on' then
		atc('[Zerg] ON')
		windower.send_command('gs c set AutoZergMode on')
	elseif cmd2 == 'off' then
		atc('[Zerg] OFF')
		windower.send_command('gs c set AutoZergMode off')
	end
end

function ein(cmd2)
	local zone = windower.ffxi.get_info()['zone']
	if zone == 78 then
		if (cmd2 == 'enter') then
			atc("[Ein] Entering Einherjar.")
			windower.send_command('wait 1; tradenpc 1 "glowing lamp" "entry gate"')
			windower.send_command('wait 4.5; setkey up down; wait 0.25; setkey up up; wait 0.7; setkey enter down; wait 0.25; setkey enter up')
		elseif (cmd2 == 'exit') then
			local items = windower.ffxi.get_items()
			local exitflag = false
			for index, item in pairs(items.inventory) do
				if type(item) == 'table' and item.id == 5414 then
					atc('[Ein] Dropping lamp to exit.')
					windower.ffxi.drop_item(index, item.count)
					exitflag = true
				end
			end
			if exitflag == false then
				atc('[Ein] No lamp in inventory!')
			end
		else
			atc('[Ein] No sub command specified')
		end
	else
		atcwarn("[Ein] Not in proper zone, skipping.")
	end
end

function dd(cmd2)
	player = windower.ffxi.get_player()
	if not cmd2 then
		if player.main_job == 'BLU' then
			windower.send_command('input /ma "Tenebral Crush" <t>')
		elseif player.main_job == 'WHM' or player.main_job == 'RDM' or player.sub_job == 'RDM' or player.sub_job == 'WHM' and not haveBuff('SJ Restriction') then
			if player.main_job == 'RDM' then
				windower.send_command('input /ma "Dia III" <t>')
			else
				windower.send_command('input /ma "Dia II" <t>')
			end
		end
	elseif cmd2 == 'def' then
		if player.main_job == 'SAM' then
			atc('[DD] - SAM')
			windower.send_command('gs c autows Tachi: Ageha')
		elseif player.main_job == 'DRK' then
			atc('[DD] - DRK')
			windower.send_command('gs c set weapons KajaChopper')
		else
			atc('[DD] - Not proper job.')
		end
	end
	
end

function buffall(cmd2)
	player = windower.ffxi.get_player()
	for k, v in pairs(windower.ffxi.get_party()) do
		if type(v) == 'table' then
			if v.mob == nil then
				atc('[BuffAll] ' ..v.name .. ' is not in zone!')
			elseif windower.ffxi.get_mob_by_name(v.name).in_party then
				windower.send_command('hb buff ' .. v.name .. ' ' .. cmd2)
			end
		end
	end
end

function rand(leader)
	atc('[Rand] Randomize party position')
	player = windower.ffxi.get_player()
	if player.name:lower() ~= leader:lower() then
		windower.send_command('hb f off; gaze ap off')
		pivot = math.random(-5.27,8.39)
		windower.ffxi.turn(pivot)
		coroutine.sleep(0.5)
		--windower.ffxi.run(true)
		runtime = math.random(0.59,0.91)
		windower.send_command('setkey numpad8 down; wait ' ..runtime.. '; setkey numpad8 up; setkey numpad4 down; wait ' ..runtime.. '; setkey numpad4 up; setkey numpad8 down; wait ' ..runtime.. '; setkey numpad8 up;')
	end
	--coroutine.sleep(runtime)
	--windower.ffxi.run(false)
end

function mb(cmd2)
	
	local player_job = windower.ffxi.get_player()
	local MBjobs = S{'SCH','GEO'}		

	if MBjobs:contains(player_job.main_job) then
		if cmd2 == 'on' then
			atc('[MB]: ON!')
			windower.send_command('lua r maa')
		elseif cmd2 == 'off' then
			atc('[MB]: OFF!')
			windower.send_command('lua u maa')
		end
	else
		atc('[MB]: Not MB jobs.')
	end
end

function wstype(cmd2)
	local player_job = windower.ffxi.get_player()
	local WSjobs = S{'COR','DRG','SAM','BLU','DRK','WAR'}		

	if cmd2 == 'leaden' then
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
				atc('WS is Expiacion')
				windower.send_command('gs c set weapons TizThib')
			elseif player_job.main_job == 'WAR' then
				atc('WS is Impulse')
				windower.send_command('gs c set weapons ShiningOne; gs c autows tp 1000')
			end
		else
			atc('WS-Type: Piercing - Skipping')
		end
	elseif cmd2 == 'blunt' then
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
		if MageNukeJobs:contains(player_job.main_job) then
			atc('[Proc] Weak casting mode. -PROC ON-')
			if player_job.main_job == "GEO" then
				windower.send_command('gs c autoindi refresh; gs c autogeo haste')
			else
				windower.send_command('gs c set castingmode proc')
				windower.send_command('gs c set MagicBurstMode off')
				windower.send_command('gs c set AutoNukeMode off')
			end
			windower.send_command('lua u maa')
		else
			atc('[Proc] Incorrect JOB, Skipping.')
		end
	elseif cmd2 == 'off' then
		if MageNukeJobs:contains(player_job.main_job) then
			atc('[Proc] Regular casting mode. -PROC OFF-')
			windower.send_command('gs c set castingmode normal')
			windower.send_command('gs c set MagicBurstMode lock')
			windower.send_command('gs c set AutoNukeMode off')
			windower.send_command('lua r maa')
			if player_job.main_job == "GEO" then
				windower.send_command('gs c autoindi acumen; gs c autogeo malaise')
			end
		else
			atc('[Proc] Incorrect JOB, Skipping.')
		end
	elseif cmd2 == 'nuke' then
		if MageNukeJobs:contains(player_job.main_job) then
			atc('[Proc] Autonuke - low tier')
			windower.send_command('gs c set castingmode normal')
			windower.send_command('gs c set MagicBurstMode off')
			windower.send_command('gs c set AutoNukeMode on')
			windower.send_command('lua u maa')
			if player_job.main_job == "GEO" then
				windower.send_command('gs c autoindi refresh; gs c autogeo haste')
			end
		else
			atc('[Proc] Incorrect JOB, Skipping.')
		end
	end
end

function wsproc(cmd2)
	local player_job = windower.ffxi.get_player()
	local ProcJobs = S{'WAR','BLU','RUN'}		

	if cmd2 == 'phy' then
		if ProcJobs:contains(player_job.main_job) then
			atc('[Proc] Physical. -PROC ON-')
			if player_job.main_job == "WAR" then
				windower.send_command('gs c autows flat blade')
			elseif player_job.main_job == "BLU" then
				windower.send_command('gs c autows brainshaker')
			elseif player_job.main_job == "RUN" then
				windower.send_command('gs c autows shockwave')
			end
		else
			atc('[Proc] Incorrect JOB, Skipping.')
		end
	elseif cmd2 == 'magic' then
		if ProcJobs:contains(player_job.main_job) then
			atc('[Proc] Magical. -PROC ON-')
			if player_job.main_job == "WAR" then
				windower.send_command('gs c autows burning blade')
			elseif player_job.main_job == "BLU" then
				windower.send_command('gs c autows shining strike')
			elseif player_job.main_job == "RUN" then
				windower.send_command('gs c autows freezebite')
			end
		else
			atc('[Proc] Incorrect JOB, Skipping.')
		end
	elseif cmd2 == 'off' then
		if ProcJobs:contains(player_job.main_job) then
			atc('[Proc] OFF.')
			if player_job.main_job == "WAR" then
				windower.send_command('gs c autows Upheaval')
			elseif player_job.main_job == "BLU" then
				windower.send_command('gs c autows Expiacion')
			elseif player_job.main_job == "RUN" then
				windower.send_command('gs c autows Dimidiation')
			end
		else
			atc('[Proc] Incorrect JOB, Skipping.')
		end
	end
end

---------------------------------
--Helper functions--
---------------------------------

function calc_lazy_distance(a,b)
    return (a.x-b.x)^2 + (a.y-b.y)^2
end

function find_npc_to_poke()
    local npc_list = npc_map[windower.ffxi.get_info()['zone']]
    
    if not npc_list or #npc_list == 0 then
        return nil
    end
	local player = windower.ffxi.get_mob_by_target('me')
	
    npcs = T(T(windower.ffxi.get_mob_list()):filter(table.contains+{npc_list}):keyset()):map(windower.ffxi.get_mob_by_index):filter(table.get-{'valid_target'})
	
	closest_npc = npcs:reduce(function(current, npc_of_interest)
		local npc_of_interest_dist = calc_lazy_distance(player, npc_of_interest)
		local current_dist = calc_lazy_distance(player, current)
		return npc_of_interest_dist < current_dist and npc_of_interest or current
	end)
    if closest_npc and calc_lazy_distance(player, closest_npc) < 6^2 then
		atc('[Found]: ' ..closest_npc.name.. ' [Distance]: ' .. math.sqrt(closest_npc.distance))
        return closest_npc
    end

end

function check_party()

	currentPC=windower.ffxi.get_player()
	for k, v in pairs(windower.ffxi.get_party()) do
		if type(v) == 'table' then
			if v.name ~= currentPC.name then
				ptymember = windower.ffxi.get_mob_by_name(v.name)
				-- check if party member in same zone.
				if v.mob == nil then
					-- Not in zone.
					atc('Check: ' .. v.name .. ' is not in zone, not following.')
				else
					if ptymember.valid_target then

					else
						atc('Check: ' .. v.name .. ' is not in range, not following.')
					end
				end
			end
		end
	end
end

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
				atc('NPC Target #: ' ..count.. ' [NPC]')
				windower.send_command('input /targetnpc; wait 0.5; input /lockon; wait 0.7; setkey enter down; wait 0.5; setkey enter up;')
			else
				atc('NPC Target #: ' ..count.. ' [NPC]')
				windower.send_command('setkey escape down; wait 0.5; setkey escape up; wait 1.0; input /targetnpc; wait 0.5; input /lockon; wait 1.0; setkey enter down; wait 0.5; setkey enter up;')
			end
			coroutine.sleep(5.2)
		end
	else
		while npc_dialog == false and count < cycles
		do
			count = count + 1
			if count == 0 then
				atc('Poke #: ' ..count.. ' [ID: ' .. target_id.. ']')
				windower.send_command('wait 1.5; settarget ' .. target_id .. '; wait 1; input /lockon; wait 1; setkey enter down; wait 0.5; setkey enter up;')
			else
				atc('Poke #: ' ..count.. ' [ID: ' .. target_id.. ']')
				windower.send_command('setkey escape down; wait 0.5; setkey escape up; wait 1.0; settarget ' .. target_id .. '; wait 1; input /lockon; wait 1; setkey enter down; wait 0.5; setkey enter up;')
			end
			coroutine.sleep(6.5)
		end
	end
	coroutine.sleep(1.5)
	if npc_dialog == false then
		windower.send_command('wait 0.7; setkey escape down; wait 0.5; setkey escape up;')
	end
end

function get_poke_check(npc_name)
	npc_dialog = false
	count = 0
	npcstats = windower.ffxi.get_mob_by_name(npc_name)

	while npc_dialog == false and count < 3
	do
		count = count + 1
		if npcstats and math.sqrt(npcstats.distance)<6 and npcstats.valid_target then
			atc('Poke #: ' ..count.. ' [NPC: ' .. npc_name.. ' ID: ' .. npcstats.id.. ']')
			poke_npc(npcstats.id,npcstats.index)
		else
			atcwarn('POKE: NPC Target is too far!')
		end
		coroutine.sleep(3.5)
	end
end

function get_poke_check_index(npc_name)
	npc_dialog = false
	count = 0
	npcstats = windower.ffxi.get_mob_by_index(npc_name)

	while npc_dialog == false and count < 3
	do
		count = count + 1
		if npcstats and math.sqrt(npcstats.distance)<6 and npcstats.valid_target then
			atc('Poke #: ' ..count.. ' [NPC: ' .. npcstats.name.. ' ID: ' .. npcstats.id.. ']')
			poke_npc(npcstats.id,npcstats.index)
		else
			atcwarn('POKE: NPC Target is too far!')
		end
		coroutine.sleep(3.5)
	end
end

function get_poke_check_id(npc_id)
	npc_dialog = false
	count = 0
	npcstats = windower.ffxi.get_mob_by_id(npc_id)

	while npc_dialog == false and count < 3
	do
		count = count + 1
		if npcstats and math.sqrt(npcstats.distance)<6 and npcstats.valid_target then
			atc('Poke #: ' ..count.. ' [NPC: ' .. npcstats.name.. ' ID: ' ..npcstats.id.. ']')
			poke_npc(npcstats.id,npcstats.index)
		else
			atcwarn('POKE: NPC Target is too far!')
		end
		coroutine.sleep(3.5)
	end
end

function haveBuff(...)
	local args = S{...}:map(string.lower)
	local player = windower.ffxi.get_player()
	if (player ~= nil) and (player.buffs ~= nil) then
		for _,bid in pairs(player.buffs) do
			local buff = res.buffs[bid]
			if args:contains(buff.en:lower()) then
				return true
			end
		end
	end
	return false
end

function find_missing_ki(escha_ki_to_find)
	local keyitems = windower.ffxi.get_key_items()
	local match_ki

	if escha_ki_to_find == 'rads' then
		match_ki = 3031
	elseif escha_ki_to_find == 'trib' then
		match_ki = 2894
	elseif escha_ki_to_find == 'moll' then
		match_ki = 3032
	end
	
	for id,ki in pairs(keyitems) do
		if ki == match_ki then 
			atc('Found: ' ..ki)
			return ki
		end
	end
end
------------
--IPC Stuff
------------

function send_to_IPC(cmd,cmd2,cmd3,cmd4)
	if cmd4 and cmd3 and cmd2 and cmd then
		windower.send_ipc_message(cmd .. ' '..cmd2.. ' ' ..cmd3.. ' ' ..cmd4)
	elseif cmd3 and cmd2 and cmd then
		windower.send_ipc_message(cmd .. ' '..cmd2.. ' ' ..cmd3)
	elseif cmd2 and cmd then
		windower.send_ipc_message(cmd .. ' '..cmd2)
	elseif cmd then
		windower.send_ipc_message(cmd)
	else
		atcwarn('[IPC] - Error')
	end
end

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
		if(DelayCMDS:contains(cmd)) then
			 coroutine.sleep(delay)
		end
		_G[cmd](cmd2,cmd3)
	elseif cmd == 'rand' then
		coroutine.sleep(delay)
		rand(cmd2)
	elseif cmd == 'as' then
		as(cmd2, cmd3)
	elseif cmd == 'send' then
		coroutine.sleep(delay)
		send(send_cmd)
	elseif cmd == 'gt' then
		coroutine.sleep(delay)
		gt(send_cmd)
	elseif cmd == 'smn' then
		smn(cmd2, cmd3, cmd4)
	elseif cmd == 'autosc' then
		autosc(cmd2, cmd3)
	elseif cmd == 'ein' then
		coroutine.sleep(delay)
		ein(cmd2)
	elseif cmd == 'buy' then
		coroutine.sleep(delay+delay)
		buy(cmd2, cmd3)	
	end
end)


windower.register_event('load', function()
	settings = config.load(default)
	init_box_pos()
	atcwarn('Required addons: Selindrile\'s GearSwap, HealBot, FastCS, Organizer, TradeNPC, Send, MAA, Roller, Singer, Sparks, Powder, SellNPC')
end)

windower.register_event("status change", function(new,old)
    local target = windower.ffxi.get_mob_by_target('t')
    if not target or target then
        if new == 4 then
            npc_dialog = true
        elseif old == 4 then
            npc_dialog = false
        end
    end
	if new == 33 then	-- resting
		isResting = true
	elseif new == 00 then	-- idle
		isResting = false
	end
end)

windower.register_event("lose buff", function(buff_id)
	if buff_id == 254 then
		off()
    end
end)

windower.register_event('incoming chunk', function(id, data)
    if id == 0x028 then	-- Casting
        local action_message = packets.parse('incoming', data)
		if action_message["Category"] == 4 then
			isCasting = false
		elseif action_message["Category"] == 8 then
			isCasting = true
		end
	elseif id == 0x0DF then -- Char update
        local packet = packets.parse('incoming', data)
		if packet then
			local playerId = packet['ID']
			local job = packet['Main job']
			
			if playerId and playerId > 0 then
				set_registry(packet['ID'], packet['Main job'])
			end
		end
	elseif id == 0x0DD then -- Party member update
        local packet = packets.parse('incoming', data)
		if packet then
			local playerId = packet['ID']
			local job = packet['Main job']
			
			if playerId and playerId > 0 then
				set_registry(packet['ID'], packet['Main job'])
			end
		end
	elseif id == 0x0C8 then -- Alliance update
        local packet = packets.parse('incoming', data)
		if packet then
			local playerId = packet['ID']
			local job = packet['Main job']
			
			if playerId and playerId > 0 then
				set_registry(packet['ID'], packet['Main job'])
			end
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

-- Credit to partyhints
function set_registry(id, job_id)
    if not id then return false end
    job_registry[id] = job_registry[id] or 'NON'
    job_id = job_id or 0
    if res.jobs[job_id].ens == 'NON' and job_registry[id] and not S{'NON', 'UNK'}:contains(job_registry[id]) then 
        return false
    end
    job_registry[id] = res.jobs[job_id].ens
    return true
end

-- Credit to partyhints
function get_registry(id)
    if job_registry[id] then
        return job_registry[id]
    else
        return 'UNK'
    end
end

function find_job_type(classtype)
	if string.lower(classtype) == 'tank' then
		if find_job_charname('PLD') then 
			return find_job_charname('PLD')
		elseif find_job_charname('RUN') then 
			return find_job_charname('RUN')
		end
	elseif string.lower(classtype) == 'dd' then
		if find_job_charname('SAM') then 
			return find_job_charname('SAM')
		elseif find_job_charname('DRK') then 
			return find_job_charname('DRK')
		end
	elseif string.lower(classtype) == 'mage' then
	end
end

-- Find which char has which job
function find_job_charname(job, job_count)
	local count = 0
	local player = windower.ffxi.get_player()
	for k, v in pairs(windower.ffxi.get_party()) do
		if type(v) == 'table' then
			if v.name ~= player.name then
				ptymember = windower.ffxi.get_mob_by_name(v.name)
				if v.mob ~= nil then
					if ptymember.valid_target then
						if get_registry(ptymember.id) == job then
							count = count +1
							if job_count and job_count == (tostring(count)) then
								atc('[Job finder]: Job: '..job.. ' Name: ' .. v.name.. ' ID: ' .. ptymember.id)
								return v.name
							elseif not job_count then
								atc('[Job finder]: Job: '..job.. ' Name: ' .. v.name.. ' ID: ' .. ptymember.id)
								return v.name
							end
						end
					end
				end
			end
		end
	end
end