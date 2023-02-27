command_map = {
	['mnt'] = 'input /mount \"Red Crab\"',
	['dis'] = 'input /dismount',
	['warp'] = 'myhome',
	['omen'] = 'myomen',
	['fps30'] = 'config FrameRateDivisor 2',
	['fps60'] = 'config FrameRateDivisor 2',
	['lotall'] = 'tr lotall',
} 

deimos_orb_map = {
	[23] = {name = {'Web of Recollections'}, entry_command ={10.5, {'right', 0.75}, 1.5, {'enter', 0.25}, 0.75, {'left', 1.15}, 0.75, {'enter', 0.25}}, follower_command = {5, {'down', 0.25}, 1.5, {'enter', 0.25}}},
    [139] = {name = {'Burning Circle'}, entry_command ={10.5, {'right', 0.75}, 1.5, {'enter', 0.25}, 0.75, {'left', 1.15}, 0.75, {'enter', 0.25}}, follower_command = {5, {'down', 0.25}, 1.5, {'enter', 0.25}}},
    [144] = {name = {'Burning Circle'}, entry_command ={10.5, {'right', 0.75}, 1.5, {'enter', 0.25}, 0.75, {'left', 1.15}, 0.75, {'enter', 0.25}}, follower_command = {5, {'down', 0.25}, 1.5, {'enter', 0.25}}},
	[146] = {name = {'Burning Circle'}, entry_command ={10.5, {'right', 0.75}, 1.5, {'enter', 0.25}, 0.75, {'left', 1.15}, 0.75, {'enter', 0.25}}, follower_command = {5, {'down', 0.25}, 1.5, {'enter', 0.25}}},	
    [163] = {name = {'Mahogany Door'}, entry_command ={10.5, {'right', 0.75}, 1.5, {'enter', 0.25}, 0.75, {'left', 1.15}, 0.75, {'enter', 0.25}}, follower_command = {5, {'down', 0.25}, 1.5, {'enter', 0.25}}},
    [168] = {name = {'Shimmering Circle'}, entry_command ={10.5, {'right', 0.75}, 1.5, {'enter', 0.25}, 0.75, {'left', 1.15}, 0.75, {'enter', 0.25}}, follower_command = {5, {'down', 0.25}, 1.5, {'enter', 0.25}}},
}

macro_orb_map =  {
    [139] = {name = {'Burning Circle'}, entry_command ={10.5, {'right', 0.75}, 1.5, {'enter', 0.25}, 0.75, {'left', 1.15}, 0.75, {'enter', 0.25}}, follower_command = {5, {'down', 0.25}, 1.5, {'enter', 0.25}}},
    [144] = {name = {'Burning Circle'}, entry_command ={10.5, {'right', 0.75}, 1.5, {'enter', 0.25}, 0.75, {'left', 1.15}, 0.75, {'enter', 0.25}}, follower_command = {5, {'down', 0.25}, 1.5, {'enter', 0.25}}},
	[146] = {name = {'Burning Circle'}, entry_command ={10.5, {'right', 0.75}, 1.5, {'enter', 0.25}, 0.75, {'left', 1.15}, 0.75, {'enter', 0.25}}, follower_command = {5, {'down', 0.25}, 1.5, {'enter', 0.25}}},	
    [163] = {name = {'Mahogany Door'}, entry_command ={10.5, {'right', 0.75}, 1.5, {'enter', 0.25}, 0.75, {'left', 1.15}, 0.75, {'enter', 0.25}}, follower_command = {5, {'down', 0.25}, 1.5, {'enter', 0.25}}}, -- Sacrificial Chamber (2x)
    [165] = {name = {'Throne Room'}, entry_command ={10.5, {'right', 0.75}, 1.5, {'enter', 0.25}, 0.75, {'left', 1.15}, 0.75, {'enter', 0.25}}, follower_command = {5, {'down', 0.25}, 1.5, {'enter', 0.25}}},
    [168] = {name = {'Shimmering Circle'}, entry_command ={10.5, {'right', 0.75}, 1.5, {'enter', 0.25}, 0.75, {'left', 1.15}, 0.75, {'enter', 0.25}}, follower_command = {5, {'down', 0.25}, 1.5, {'enter', 0.25}}},
	[206] = {name = {'Burning Circle'}, entry_command ={10.5, {'right', 0.75}, 1.5, {'enter', 0.25}, 0.75, {'left', 1.15}, 0.75, {'enter', 0.25}}, follower_command = {5, {'down', 0.25}, 1.5, {'enter', 0.25}}}, -- Qu'Bia Arena (2x)
}

htmb_map = {
	[31] = {name = {'Spatial Displacement'}, entry_command ={17, {'down', 0.75}, 0.6, {'enter', 0.15}, 0.75, {'down', 0.5}, 0.6, {'enter', 0.15}}},
	[67] = {name = {'Ornamental Door'}, entry_command ={12.3, {'down', 0.15}, 0.6, {'enter', 0.15}, 1.0, {'up', 1.0}, 0.7, {'enter', 0.15}}},
    [163] = {name = {'Mahogany Door'}, entry_command ={}},
    [165] = {name = {'Throne Room'}, entry_command ={}},
    [168] = {name = {'Shimmering Circle'}, entry_command ={}},
	[201] = {name = {'Wind Protocrystal'}, entry_command ={5, {'right', 0.75}, 0.6, {'enter', 0.25}, 0.75, {'left', 0.75}, 0.6, {'enter', 0.25}}},
	[202] = {name = {'Lightning Protocrystal'}, entry_command ={5, {'right', 0.75}, 0.6, {'enter', 0.25}, 0.75, {'left', 0.75}, 0.6, {'enter', 0.25}}},
	[203] = {name = {'Ice Protocrystal'}, entry_command ={5, {'right', 0.75}, 0.6, {'enter', 0.25}, 0.75, {'left', 0.75}, 0.6, {'enter', 0.25}}},
	[207] = {name = {'Fire Protocrystal'}, entry_command ={5, {'right', 0.75}, 0.6, {'enter', 0.25}, 0.75, {'left', 0.75}, 0.6, {'enter', 0.25}}},
	[209] = {name = {'Earth Protocrystal'}, entry_command ={5, {'right', 0.75}, 0.6, {'enter', 0.25}, 0.75, {'left', 0.75}, 0.6, {'enter', 0.25}}},
	[211] = {name = {'Water Protocrystal'}, entry_command ={5, {'right', 0.75}, 0.6, {'enter', 0.25}, 0.75, {'left', 0.75}, 0.6, {'enter', 0.25}}},
	[255] = {name = {'Transcendental Radiance'}, entry_command = {2.5, {'right', 0.75}, 0.6, {'enter', 0.25}, 0.75, {'left', 0.75}, 0.6, {'enter', 0.25}}},
}

npc_map = {
	[33] = {name = {
		['Swirling Vortex'] = {entry_command = {4, {'up', 0.15}, 1.1, {'enter', 0.15}}},
		}},
	[50] = {name = {
		['Ironbound Gate'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}}, 
		['Gate: The Pit'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}}, 
		['Gate: Chocobo Circuit'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},	
	[51] = {name = {
		['Engraved Tablet'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[61] = {name = {
		['Engraved Tablet'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[70] = {name = {
		['Ilsorie'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[79] = {name = {
		['Engraved Tablet'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[71] = {name = {
		['Gate: The Pit'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[72] = {name = {
		['Gilded Doors'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[111] = {name = {
		['Trail Markings'] = {entry_command = {2.5, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[112] = {name = {
		['Trail Markings'] = {entry_command = {2.5, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[126] = {name = {
		['Transcendental Radiance'] = {entry_command = {3, {'up', 0.15}, 1.1, {'enter', 0.15}}},
		}},
	[133] = {name = {
		['Diaphanous Device'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Device #A'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Device #B'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Device #C'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Device #D'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #A'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #B'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #C'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #D'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #E'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #F'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #G'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #H'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Bitzer #A'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Bitzer #B'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Bitzer #C'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Bitzer #D'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Bitzer'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}, 0.5, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
    [137] = {name = {
		['Veridical Conflux'] = {entry_command = {2.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[182] = {name = {
		['Veridical Conflux'] = {entry_command = {1.8, {'enter', 0.15}}},
		['Veridical Conflux #01'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #02'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #03'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #04'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #05'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #06'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #07'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #08'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #09'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #10'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #11'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #12'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #13'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #14'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #15'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		}},
	[230] = {name = {
		['Gate: Chocobo Circuit'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[234] = {name = {
		['Gate: Chocobo Circuit'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[241] = {name = {
		['Gate: Chocobo Circuit'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[246] = {name = {
		['Gate: Chocobo Circuit'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[255] = {name = {
		['Cavernous Maw'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[256] = {name = {
		['Dangueubert'] = {entry_command = {1.3, {'enter', 0.15}}},
		}},
	[257] = {name = {	-- Eastern Adoulin
		['Cunegonde'] = {entry_command = {1.3, {'enter', 0.15}}},
		['Krepol'] = {entry_command = {0.85, {'enter', 0.15}}},
		['Glowing Hearth'] = {entry_command = {0.85, {'enter', 0.15}}},
		}},
	[261] = {name = { -- [Ceizak]
		['???'] = {index = {
			[497] = {entry_command = {1.5, {'down', 0.05}, 0.7, {'enter', 0.15}, 2.1, {'up', 0.15}, 0.7, {'enter', 0.15}}}, -- WKR Ceizak
			[593] = {entry_command = {0.85, {'down', 0.15}, 0.5, {'enter', 0.15}}}, --Beam Up - To Sih Gates
		}}}},
	[262] = {name = { -- [Foret]
		['???'] = {index = {
			[531] = {entry_command = {1.5, {'down', 0.05}, 0.7, {'enter', 0.15}, 2.1, {'up', 0.15}, 0.7, {'enter', 0.15}}}, -- WKR Foret
			[625] = {entry_command = {0.85, {'down', 0.15}, 0.5, {'enter', 0.15}}}, --Beam Up - To Dho Gates
		}}}},
	[263] = {name = { -- [Yorcia]
		['???'] = {index = {
			[562] = {entry_command = {1.5, {'down', 0.05}, 0.7, {'enter', 0.15}, 2.1, {'up', 0.15}, 0.7, {'enter', 0.15}}},	--WKR Yorcia
			[649] = {entry_command = {0.85, {'down', 0.15}, 0.5, {'enter', 0.15}}},  --Beam Up - To Cirdas
		}}}},
	[265] = {name = { -- [Morimor]
		['???'] = {index = { 
			[734] = {entry_command = {1.5, {'down', 0.05}, 0.7, {'enter', 0.15}, 2.1, {'up', 0.15}, 0.7, {'enter', 0.15}}}, --WKR Morimor
			[844] = {entry_command = {0.85, {'down', 0.15}, 0.5, {'enter', 0.15}}},  --Beam Up - To Moh Gates
		}}}},
	[266] = {name = { -- [Marjami]
		['???'] = {index = { 
			[416] = {entry_command = {1.5, {'down', 0.05}, 0.7, {'enter', 0.15}, 2.1, {'up', 0.15}, 0.7, {'enter', 0.15}}}, --WKR Marjami
			[507] = {entry_command = {0.85, {'down', 0.15}, 0.5, {'enter', 0.15}}},  --Beam Up - To Woh Gates
		}},
		['Scalable Area'] = {entry_command = {0.85, {'enter', 0.15}}},
		}},
	[267] = {name = { -- [Kamihr]
		['???'] = {entry_command = {1.5, {'down', 0.05}, 0.7, {'enter', 0.15}, 2.1, {'up', 0.15}, 0.7, {'enter', 0.15}}}, --WKR Kamihr
		}},
	[268] = {name = { -- [Sih Gates]
		['???'] = {entry_command = {0.85, {'down', 0.15}, 0.5, {'enter', 0.15}}},	--Beam Up/Down - To Ceizak /  Ra'Kaznar Inner Court
		}},
	[269] = {name = { -- [Moh Gates]
		['???'] = {entry_command = {0.85, {'down', 0.15}, 0.5, {'enter', 0.15}}},	--Beam Up/Down - To Morimor / Ra'Kaznar Inner Court
		}},
	[270] = {name = { -- [Cirdas Caverns]
		['???'] = {entry_command = {0.85, {'down', 0.15}, 0.5, {'enter', 0.15}}},	--Beam Up/Down - To Yorcia /  Ra'Kaznar Inner Court
		}},
	[272] = {name = { -- [Dho Gates]
		['???'] = {entry_command = {0.85, {'down', 0.15}, 0.5, {'enter', 0.15}}},	--Beam Up/Down - To Foret /  Ra'Kaznar Inner Court
		}},
	[273] = {name = { -- [Woh Gates]
		['???'] = {entry_command = {0.85, {'down', 0.15}, 0.5, {'enter', 0.15}}},	--Beam Up/Down - To Marjami /  Ra'Kaznar Inner Court
		}},
	[274] = {name = {
		['Entwined Roots'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[275] = {name = {
		['Diaphanous Device'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Device #A'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Device #B'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Device #C'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Device #D'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #A'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #B'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #C'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #D'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #E'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #F'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #G'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #H'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Bitzer #A'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Bitzer #B'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Bitzer #C'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Bitzer #D'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Bitzer'] = {entry_command = {0.3, {'up', 0.15}, 0.5, {'enter', 0.15}, 0.5, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[279] = {name = {
		['Translocator #1'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Translocator #2'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #1'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #2'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #3'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #4'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #5'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #6'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #7'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #8'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #9'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #10'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #11'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Otherworldly Vortex'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[283] = {name = {
		['Dusky Forest'] = {entry_command = {0.85, {'enter', 0.15}}},
		['Reglert'] = {entry_command = {0.85, {'enter', 0.15}}},
		}},
	[298] = {name = {
		['Translocator #1'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Translocator #2'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #1'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #2'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #3'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #4'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #5'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #6'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #7'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #8'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #9'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #10'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #11'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Otherworldly Vortex'] = {entry_command = {0.1, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
}

basic_key_sequence = {
	['ent'] = {command = {0.7, {'enter', 0.15}}},
	['enup'] = {command = {0.7, {'up', 0.15}, 0.5, {'enter', 0.15}}},
	['endown'] = {command = {0.7, {'down', 0.15}, 0.5, {'enter', 0.15}}},
	['esc'] = {command = {0.7, {'escape', 0.15}}},
}

return entry_map