--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

local refresh_callback = function ()
	refresh_init(theme.data["back"])
	restart_cronopic()
end

local usb_callback = function ()
	local vbuff = screen.toimage()
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
	usbMassStorage()
	os.delay(150)
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
end

local ftp_callback = function ()
	local vbuff = screen.toimage()
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
	buttons.homepopup(0)
		startftp()
	buttons.homepopup(1)

	os.delay(15)
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
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

	os.delay(15)
	if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
end

local Multimedia_Folders_Cleanup_callback = function ()

	if theme.data["back"] then theme.data["back"]:blit(0,0) end
		message_wait(STRINGS_SCANNING)
	os.delay(250)
	--Eliminar carpetas vacias de picture y video
	local path_photo = { "ux0:music/", "ux0:picture/ALL/", "ux0:picture/CAMERA/", "ux0:picture/SCREENSHOT/", "ux0:video/" }
	for i=1,#path_photo do
		local tmp = files.listdirs(path_photo[i])
		if tmp and #tmp > 0 then
			table.sort(tmp, function (a,b) return a.name<b.name end)
			for j=1, #tmp do
				local tmp2 = files.list(path_photo[i]..tmp[j].name)

				if tmp2 and #tmp2> 0 then
				else
					files.delete(path_photo[i]..tmp[j].name)
				end
			end
		end
	end

	os.delay(15)
	if theme.data["back"] then theme.data["back"]:blit(0,0) end
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

local updatedb_callback = function ()
	os.delay(150)
	_print=false
	os.updatedb()
	os.message(STRINGS_RESTART_UPDATEDB)
	os.delay(1500)
	power.restart()
end

local rebuilddb_callback = function ()
	os.delay(150)
	_print=false
	os.rebuilddb()
	os.message(STRINGS_RESTART_REBUILDDB)
	os.delay(1500)
	power.restart()
end

local themesLiveArea_callback = function ()
	customthemes()
end

function SubOptions2()

    Sub_Options2 = { -- Handle Option Text and Option Function

		{ text = STRINGS_REFRESH_LIVEAREA,  	funct = refresh_callback },

		{ text = STRINGS_USB,           		funct = usb_callback },
		{ text = STRINGS_SUBMENU_FTP,       	funct = ftp_callback },

		{ text = STRINGS_REFOLDERS_CLEANUP,		funct = Re_Folders_Cleanup_callback },
		{ text = STRINGS_MULTIMEDIA_CLEANUP,	funct = Multimedia_Folders_Cleanup_callback },

		{ text = STRINGS_SUBMENU_RESTART,   	funct = restart_callback },
        { text = STRINGS_SUBMENU_RESET,     	funct = reboot_callback },
        { text = STRINGS_SUBMENU_POWEROFF,  	funct = shutdown_callback },

		{ text = STRINGS_UPDATE_DB, 			funct = updatedb_callback },
		{ text = STRINGS_REBUILD_DB, 			funct = rebuilddb_callback },

		{ text = STRINGS_SUBMENU_CUSTOMTHEMES,	funct = themesLiveArea_callback },
    }

end

function SubSystem2()

	Sub_Options2 = {} -- Handle Option Text and Option Function
    SubOptions2()
	local scrollsys = newScroll(Sub_Options2, #Sub_Options2)

	buttons.interval(16,5)
	while true do
		buttons.read()
		if theme.data["back"] then theme.data["back"]:blit(0,0) end

		draw.fillrect(0,0,960,544,color.black:a(105))

		screen.print(480,15,"System Settings",1,theme.style.TITLECOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
		local y = 70
		for i=scrollsys.ini,scrollsys.lim do
			if i == scrollsys.sel then draw.fillrect(10,y-2,930,23,theme.style.SELCOLOR) end

			screen.print(480,y, Sub_Options2[i].text,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)

			if i == 1 or i == 3 or i == 5 or i == 8 or i == 10 then
				y+=36
			else
				y+=26
			end

		end

		screen.flip()

		--Controls
		if buttons.up or buttons.analogly < -60 then scrollsys:up() end
		if buttons.down or buttons.analogly > 60 then scrollsys:down() end

		if buttons.cancel then
			os.delay(80)
			break
		end

		if buttons.accept or ( (buttons.left or buttons.right) and Sub_Options2[scrollsys.sel].pad ) then Sub_Options2[scrollsys.sel].funct() end

	end--while

end
