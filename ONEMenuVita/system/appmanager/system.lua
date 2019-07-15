--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

local pic1_callback = function ()

	if __PIC1 == 1 then
		__PIC1,showpic = 0,STRINGS_APP_NO
	else
		__PIC1,showpic = 1,STRINGS_APP_YES
	end

	write_config()
	os.delay(150)
	 SubOptions()
end

local update_callback = function ()

	if __UPDATE == 1 then 
		_update = STRINGS_APP_NO
		__UPDATE = 0
	else
		_update = STRINGS_APP_YES
		__UPDATE = 1
	end

	write_config()
	os.delay(150)

	 SubOptions()
end

local slides_callback = function ()

	if __SLIDES == 100 then
		__SLIDES = 415
		var = STRINGS_APP_SLIDE_ORIGINAL
	else
		__SLIDES = 100
		var = STRINGS_APP_SLIDE_PS4
	end

	write_config()
	os.delay(150)

	 SubOptions()
end

local themesONEMenu_callback = function ()

	local vbuff = screen.toimage()
	if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end

		theme.manager()

	os.delay(15)
	if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
end

function Search_ReFolders(path,mount)
	if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
		message_wait(path)
	os.delay(1250)

	local size = 0
	local tmp, tb = files.listdirs(path), {}
	if tmp and #tmp > 0 then
		for i=1, #tmp do
			if tmp[i].directory then
				if not game.exists(tmp[i].name) then

					local flg = false
					if not files.exists(mount.."app/"..tmp[i].name) then
						flg = true
					end
				
					if flg then
						local _size = files.size(tmp[i].path) or 0
						size += _size
						if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
							message_wait(path.."\n"..tmp[i].name)
						os.delay(750)
						table.insert(tb, { path = tmp[i].path, name = tmp[i].name, size = _size })
					end

				end--not game.exists
			end
		end
	end

	--Delete?
	if #tb > 0 then
		if os.message(STRINGS_APP_FOUND_REFOLDERS.." : "..#tb.." "..STRINGS_APP_REFOLDERS_GAME.." "..path.."\n"..STRINGS_CALLBACKS_SIZE_ALL..files.sizeformat(size or 0).."\n"..STRINGS_APP_REFOLDERS_DELETE,1) == 1 then
			for i=1,#tb do
				files.delete(tb[i].path)
			end
		end
	end

end

local Re_Folders_Cleanup_callback = function ()

	local vbuff = screen.toimage()
	if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end

	local path_ReAddcont = { 
		{ path="ux0:ReAddcont", mount="ux0:"},
		{ path="uma0:ReAddcont", mount="uma0:"},
		{ path="imc0:ReAddcont", mount="imc0:"},
		{ path="xmc0:ReAddcont", mount="xmc0:"},
	}
	local path_RePatch = {
		{ path="ux0:RePatch", mount="ux0:"},
		{ path="uma0:RePatch", mount="uma0:"},
		{ path="imc0:RePatch", mount="imc0:"},
		{ path="xmc0:RePatch", mount="xmc0:"},
	}

--ReAddcont
	for i=1, #path_ReAddcont do
		Search_ReFolders(path_ReAddcont[i].path, path_ReAddcont[i].mount)
	end

--Repatch
	for i=1, #path_RePatch do
		Search_ReFolders(path_RePatch[i].path, path_RePatch[i].mount)
	end

--Eliminar carpetas vacias de picture y video
	local tmp = files.listdirs("ux0:picture/SCREENSHOT")
	if tmp and #tmp > 0 then
		table.sort(tmp, function (a,b) return a.name<b.name end)
		for i=1, #tmp do
			local tmp2 = files.list("ux0:picture/SCREENSHOT/"..tmp[i].name)

			if tmp2 and #tmp2> 0 then
			else
				files.delete("ux0:picture/SCREENSHOT/"..tmp[i].name)
			end
		end
	end

	local tmp = files.listdirs("ux0:video")
	if tmp and #tmp > 0 then
		table.sort(tmp, function (a,b) return a.name<b.name end)
		for i=1, #tmp do
			local tmp2 = files.list("ux0:video/"..tmp[i].name)

			if tmp2 and #tmp2> 0 then
			else
				files.delete("ux0:video/"..tmp[i].name)
			end
		end
	end

	os.delay(15)
	if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
end

local restart_callback = function ()
    os.delay(150)
    os.restart()
end

local reboot_callback = function ()
    os.delay(1000)
    power.restart()
end

local shutdown_callback = function ()
    os.delay(1000)
    power.shutdown()
end

function SubOptions()
	if __PIC1 == 1 then showpic = STRINGS_APP_YES else showpic = STRINGS_APP_NO end
	if __SLIDES == 100 then var = STRINGS_APP_SLIDE_ORIGINAL else var = STRINGS_APP_SLIDE_PS4 end

    Sub_Options = { -- Handle Option Text and Option Function
		{ text = STRINGS_APP_SHOW_PIC..showpic, 		funct = pic1_callback,		pad = true },
		{ text = STRINGS_APP_SLIDES..var,       		funct = slides_callback,	pad = true },

		{ text = STRINGS_REFOLDERS_CLEANUP,				funct = Re_Folders_Cleanup_callback },

		{ text = STRINGS_SUBMENU_THEMES,            	funct = themesONEMenu_callback },

		{ text = STRINGS_ENABLE_UPDATE.._update,   		funct = update_callback,    pad = true },
		{ text = STRINGS_SUBMENU_RESTART,         		funct = restart_callback },
        { text = STRINGS_SUBMENU_RESET,             	funct = reboot_callback },
        { text = STRINGS_SUBMENU_POWEROFF,              funct = shutdown_callback },
    }

end

function SubSystem()

	Sub_Options = {} -- Handle Option Text and Option Function
    SubOptions()
	local scrollsys = newScroll(Sub_Options, #Sub_Options)

	while true do
		buttons.read()
		if theme.data["back"] then theme.data["back"]:blit(0,0) end

		screen.print(480,15,"System Settings",1,theme.style.TITLECOLOR,theme.style.TXTBKGCOLOR,__ACENTER)

		local y = 70
		for i=scrollsys.ini,scrollsys.lim do
			if i == scrollsys.sel then draw.fillrect(10,y-2,930,23,theme.style.SELCOLOR) end

			screen.print(480,y, Sub_Options[i].text,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)

			y+=26
		end

		screen.flip()

		--Controls
		if buttons.up or buttons.analogly < -60 then scrollsys:up() end
		if buttons.down or buttons.analogly > 60 then scrollsys:down() end

		if buttons.cancel or buttons.start then
			os.delay(80)
			break
		end

		if buttons.accept or ( (buttons.left or buttons.right) and Sub_Options[scrollsys.sel].pad ) then Sub_Options[scrollsys.sel].funct() end

	end--while

end
