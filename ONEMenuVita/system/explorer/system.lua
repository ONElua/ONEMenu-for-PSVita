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
	os.delay(750)

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
	else
		if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
			message_wait(STRINGS_APP_NO.." "..STRINGS_APP_REFOLDERS_GAME.." "..path)
		os.delay(1000)
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

	if theme.data["list"] then theme.data["list"]:blit(0,0) end
		message_wait(STRINGS_SCANNING)
	os.delay(1000)

	local tb_delete = {}
	--Eliminar carpetas vacias de picture y video
	local paths = { "ux0:music/", "ux0:picture/ALL/", "ux0:picture/CAMERA/", "ux0:picture/SCREENSHOT/", "ux0:video/" }
	for i=1,#paths do
		local tmp = files.listdirs(paths[i])
		if tmp and #tmp > 0 then
			table.sort(tmp, function (a,b) return a.name<b.name end)
			for j=1, #tmp do

				local tmp2 = files.list(paths[i]..tmp[j].name)
				if tmp2 and #tmp2> 0 then
				else
					table.insert(tb_delete,paths[i]..tmp[j].name)
				end
			end
		end
	end

	game_move = true
	for i=1,#tb_delete do
		files.delete(tb_delete[i])
	end
	game_move = false

	if theme.data["list"] then theme.data["list"]:blit(0,0) end
		message_wait(" ( "..#tb_delete.." ) "..STRINGS_FOLDERS_DELETE)
	os.delay(750)

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

local video_callback = function ()
	while true do
		buttons.read()

		local mp4 = video.import(theme.data["back"])
		if mp4 != -1 then
			video.mount()
				VideoPlayer(mp4)
			video.umount()
		else
			break
		end

		if buttons.released.cancel then break end

	end
	os.delay(25)
end

function SubOptions2()

    Sub_Options2 = { -- Handle Option Text and Option Function

		{ text = STRINGS_REFRESH_LIVEAREA,  	funct = refresh_callback,						descr = STRINGS_RELOAD_CONTENT_DESCR },

		{ text = STRINGS_USB,           		funct = usb_callback,							descr = STRINGS_USB_DESCR },
		{ text = STRINGS_SUBMENU_FTP,       	funct = ftp_callback,							descr = STRINGS_FTP_DESCR },

		{ text = STRINGS_REFOLDERS_CLEANUP,		funct = Re_Folders_Cleanup_callback,			descr = STRINGS_REFOLDERS_DESCR },
		{ text = STRINGS_MULTIMEDIA_CLEANUP,	funct = Multimedia_Folders_Cleanup_callback,	descr = STRINGS_MULTIMEDIA_DESCR },

		{ text = STRINGS_SUBMENU_RESTART,   	funct = restart_callback,						descr = STRINGS_RESTART_DESCR },
        { text = STRINGS_SUBMENU_RESET,     	funct = reboot_callback,						descr = STRINGS_REBOOT_DESCR },
        { text = STRINGS_SUBMENU_POWEROFF,  	funct = shutdown_callback,						descr = STRINGS_POWEROFF_DESCR },

		{ text = STRINGS_UPDATE_DB, 			funct = updatedb_callback,						descr = STRINGS_UPDATE_DB_DESCR },
		{ text = STRINGS_REBUILD_DB, 			funct = rebuilddb_callback,						descr = STRINGS_REBUILD_DB_DESCR },

		{ text = STRINGS_SUBMENU_CUSTOMTHEMES,	funct = themesLiveArea_callback,				descr = STRINGS_CUSTOMTHEMES_DESCR },

		{ text = STRINGS_VIDEO_PLAYER,			funct = video_callback,							descr = STRINGS_VIDEO_PLAYER_DESCR },
    }

end

function SubSystem2()

	Sub_Options2 = {} -- Handle Option Text and Option Function
    SubOptions2()
	local scrollsys = newScroll(Sub_Options2, #Sub_Options2)

	local x_scrext = 20
	buttons.interval(16,5)
	while true do
		buttons.read()
		if theme.data["back"] then theme.data["back"]:blit(0,0) end

		draw.fillrect(0,0,960,544,color.black:a(105))

		screen.print(480,15,STRINGS_SUBMENU_TITLE,1,theme.style.TITLECOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
		local y = 70
		for i=scrollsys.ini,scrollsys.lim do
			if i == scrollsys.sel then draw.fillrect(10,y-2,930,23,theme.style.SELCOLOR) end

			screen.print(480,y, Sub_Options2[i].text,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)

			if i == 1 or i == 3 or i == 5 or i == 8 or i == 10 or i == 11 then
				y+=36
			else
				y+=26
			end

		end

		if screen.textwidth(Sub_Options2[scrollsys.sel].descr) > 935 then
			x_scrext = screen.print(x_scrext, 520, Sub_Options2[scrollsys.sel].descr,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__SLEFT,915)
		else
			screen.print(480, 520, Sub_Options2[scrollsys.sel].descr,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
		end

		screen.flip()

		--Controls
		if buttons.up or buttons.analogly < -60 then
			if scrollsys:up() then x_scrext = 20 end
		end
		if buttons.down or buttons.analogly > 60 then
			if scrollsys:down() then x_scrext = 20 end
		end

		if buttons.cancel then
			os.delay(80)
			break
		end

		if buttons.accept or ( (buttons.left or buttons.right) and Sub_Options2[scrollsys.sel].pad ) then Sub_Options2[scrollsys.sel].funct() end

	end--while

end
