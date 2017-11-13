--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

menuadv = {}

local themesAppManager_callback = function ()
	menuadv.wakefunct()
	theme.manager()
	advanced_options()
end

local themesLiveArea_callback = function ()
	menuadv.wakefunct()
	customthemes()
	advanced_options()
end

local scanvpk_callback = function ()
	menuadv.wakefunct()

	message_wait()

	scan(0)
	advanced_options()
end

local reloadconfig_callback = function ()
	menuadv.wakefunct()

	os.taicfgreload()
	os.delay(100)
	os.message(strings.configtxt)
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
		{ text = strings.themes,      	funct = themesAppManager_callback },
		{ text = strings.cthemesman,   	funct = themesLiveArea_callback },
	}
end

menuadv.wakefunct()

function advanced_options()
	local scroll = newScroll(menuadv.options, #menuadv.options)
	buttons.interval(10,10)
	while true do
		buttons.read()

		if theme.data["list"] then theme.data["list"]:blit(0,0) end

		screen.print(480,15,strings.advanced,1,theme.style.TITLECOLOR,color.gray,__ACENTER)

		if buttons.up or buttons.analogly < -60 then scroll:up() end
		if buttons.down or buttons.analogly > 60 then scroll:down() end

		if buttons[accept] then
			menuadv.options[scroll.sel].funct()
		end

		local y = 70
		for i=scroll.ini,scroll.lim do
			if i == scroll.sel then draw.fillrect(10,y-2,930,23,theme.style.SELCOLOR) end

			screen.print(480,y, menuadv.options[i].text,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)

			y+=26
		end

		if buttons[cancel] then
			os.delay(150)
			break
		end

		if (buttons.held.l and buttons.held.r and buttons.up) and reboot then os.restart() end
		if (buttons.held.l and buttons.held.r and buttons.down) and reboot then power.restart() end

		screen.flip()

	end
end
