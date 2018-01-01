--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

menuadv = {
	scroll = newScroll(), -- Scroll of menu options.
}

local scanfavs_callback = function ()
	local pos_menu = menuadv.scroll.sel
	favorites_manager()
	advanced_options()
	menuadv.scroll.sel = pos_menu
end

local font_callback = function ()
	local pos_menu = menuadv.scroll.sel
	if not __USERFNT then
		if __FNT == 2 then __FNT = 3 else __FNT = 2 end 
		write_config()
		font.setdefault(__FNT)
		menuadv.wakefunct()
	end
	menuadv.scroll.sel = pos_menu
end

local themesONEMenu_callback = function ()
	local pos_menu = menuadv.scroll.sel
	theme.manager()
	advanced_options()
	menuadv.scroll.sel = pos_menu
end

local themesLiveArea_callback = function ()
	local pos_menu = menuadv.scroll.sel
	customthemes()
	advanced_options()
	menuadv.scroll.sel = pos_menu
end

local scanvpk_callback = function ()
	local pos_menu = menuadv.scroll.sel
	message_wait()

	scan(0)
	advanced_options()
	menuadv.scroll.sel = pos_menu
end

local reloadconfig_callback = function ()
	local pos_menu = menuadv.scroll.sel

	os.taicfgreload()
	os.message(strings.configtxt)
	menuadv.scroll.sel = pos_menu
end

local rebuilddb_callback = function ()
	os.delay(150)
	_print=false
	os.rebuilddb()
	os.message(strings.restartredb)
	os.delay(1500)
	power.restart()
end

local updatedb_callback = function ()
	os.delay(150)
	_print=false
	os.updatedb()
	os.message(strings.restartupdb)
	os.delay(1500)
	power.restart()
end

function menuadv.wakefunct()
	menuadv.options = {
		{ text = strings.refreshdb, 	funct = updatedb_callback },
		{ text = strings.rebuilddb, 	funct = rebuilddb_callback },
		{ text = strings.reloadconfig,	funct = reloadconfig_callback },
		{ text = strings.scanvpks,		funct = scanvpk_callback },
		{ text = strings.themes,      	funct = themesONEMenu_callback },
		{ text = strings.cthemesman,   	funct = themesLiveArea_callback },
		{ text = strings.favorites,		funct = scanfavs_callback },
	}
	if __FNT == 3 then 
		table.insert(menuadv.options, { text = "< "..strings.pvf.." >",	funct = font_callback })
	else
		table.insert(menuadv.options, { text = "< "..strings.pgf.." >",	funct = font_callback })
	end

	menuadv.scroll = newScroll(menuadv.options, #menuadv.options)
end

menuadv.wakefunct()

function advanced_options()
	buttons.interval(16,5)
	while true do
		buttons.read()

		if theme.data["list"] then theme.data["list"]:blit(0,0) end

		screen.print(480,15,strings.advanced,1,theme.style.TITLECOLOR,theme.style.TXTBKGCOLOR,__ACENTER)

		if buttons.up or buttons.analogly < -60 then menuadv.scroll:up() end
		if buttons.down or buttons.analogly > 60 then menuadv.scroll:down() end

		if buttons[accept] and menuadv.scroll.sel != 8 then
			menuadv.options[menuadv.scroll.sel].funct()
		end
		if (buttons.left or buttons.right) and menuadv.scroll.sel == 8 then
			menuadv.options[menuadv.scroll.sel].funct()
		end

		local y = 70
		for i=menuadv.scroll.ini,menuadv.scroll.lim do
			if i == menuadv.scroll.sel then draw.fillrect(10,y-2,930,23,theme.style.SELCOLOR) end

			screen.print(480,y, menuadv.options[i].text,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)

			y+=26
		end

		if buttons[cancel] then
			os.delay(50)
			menuadv.scroll.sel = 1
			break
		end

		shortcuts()

		screen.flip()

	end
end
