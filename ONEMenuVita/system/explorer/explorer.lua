--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

-- Create two scrolls :P
scroll = {
   list = newScroll(),
   menu = newScroll(),
}

xtitle,movx = 35,0
title_scr_x = 5
maxim_files=16
backl, explorer, multi, multi_delete = {},{},{},{} -- All explorer functions
slidex=0

-- ## Explorer Drawer List ## --
function explorer.listshow(posy)

	if movx==0 then	len_selector,len_clip = __DISPLAYW-25,500 else len_selector,len_clip = __DISPLAYW-173,600 end

	if menu_ctx.close and slidex > 0 then slidex -= 10 end
	if not menu_ctx.close and slidex < 86 then slidex += 10 end

	for i=scroll.list.ini, scroll.list.lim do

		if i==scroll.list.sel then
			ccc = theme.style.TXTBKGCOLOR--color.green:a(130)
			draw.fillrect(5+movx, posy-3, len_selector, 23, theme.style.SELCOLOR)

			if screen.textwidth(explorer.list[i].name or "",1) > len_clip then 
				xtitle = screen.print( xtitle+movx, posy, explorer.list[i].name,1, isopened[explorer.list[i].ext] or
									   theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __SLEFT, len_clip)
				xtitle -= movx
			else
				screen.clip(35+movx,0,len_clip+movx,544)
				screen.print(35+movx, posy, explorer.list[i].name,1, isopened[explorer.list[i].ext] or theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ALEFT)
				xtitle=35
			end
		else
			ccc = theme.style.TXTBKGCOLOR
			screen.clip(35+movx,0,len_clip+movx,544)
			screen.print(35+movx, posy, explorer.list[i].name,1, isopened[explorer.list[i].ext] or theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ALEFT)
		end
		screen.clip()

		if explorer.list[i].size then
			if icons_mimes[explorer.list[i].ext] then theme.data["icons"]:blitsprite(10+movx, posy, icons_mimes[explorer.list[i].ext]) -- mime type
			else theme.data["icons"]:blitsprite(10+movx, posy, 0) end -- file unk
		else
			theme.data["icons"]:blitsprite(10+movx, posy, 1) -- folder 
		end

		if explorer.list[i].multi then draw.fillrect(5+movx, posy-3, len_selector, 22, theme.style.MARKEDCOLOR) end

		screen.print((680+movx)+slidex, posy, explorer.list[i].size or "<DIR>", 1, theme.style.TXTCOLOR,ccc, __ARIGHT)
		screen.print((930+movx)+slidex, posy, explorer.list[i].mtime, 1.0, theme.style.TXTCOLOR,ccc, __ARIGHT)
		posy += 26

	end--for

end

--Cycle Main for Explorer Files: show_explorer_list()
local xtmp = 0
function show_explorer_list(first_path)

	explorer.refresh(true,first_path)
	buttons.interval(16,5)
	while true do

		buttons.read()
		if theme.data["list"] then theme.data["list"]:blit(0,0) end

		movx = menu_ctx.x + menu_ctx.w

		if screen.textwidth(Root[Dev] or "",1) > 860 then 
			title_scr_x = screen.print(title_scr_x+movx,5,Root[Dev],1,theme.style.PATHCOLOR,color.black,__SLEFT,860)
			title_scr_x -= movx
		else
			screen.print(5+movx,5,Root[Dev],1,theme.style.PATHCOLOR,color.black,__ALEFT)
			title_scr_x = 5
		end

		if infosize then
			xtmp = screen.print(5+movx,33,files.sizeformat(infosize.max or 0).."/"..files.sizeformat(infosize.free or 0),1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
		end

		--Partitions
		if menu_ctx.close then
			local xRoot = xtmp + 15
			local w = (955-xRoot)/#Root2
			for i=1, #Root2 do
				if Dev == i then
					draw.fillrect(xRoot,28,w,28, theme.style.SELCOLOR)
				end
				screen.print(xRoot+(w/2), 33, Root2[i], 1, color.white, 0x0, __ACENTER)
				xRoot += w
			end
		end

		screen.print(940+movx,5,scroll.list.maxim,1,theme.style.COUNTCOLOR,theme.style.TXTBKGCOLOR,__ARIGHT)

		if (multi and #multi > 0) and action then
			if movx==0 then
				screen.print(940-movx,515,STRINGS_SEL_ITEMS+#multi,1,color.new(255,69,0),color.black,__ARIGHT)
			else
				screen.print((940-movx)+160,515,STRINGS_SEL_ITEMS+#multi,1,color.new(255,69,0),color.black,__ARIGHT)
			end
		end

		--Bar Scroll
		local y,h=70, (maxim_files*26)-2
		if scroll.list.maxim > 0 then
			draw.fillrect(945+movx, y-2, 8, h, color.shine)
			if scroll.list.maxim >= maxim_files then -- Draw Scroll Bar
				local pos_height = math.max(h/scroll.list.maxim, maxim_files)
				draw.fillrect(945+movx, y-2 + ((h-pos_height)/(scroll.list.maxim-1))*(scroll.list.sel-1), 8, pos_height, color.new(0,255,0))
			end
			explorer.listshow(y)
		else
			screen.print(10+movx,80,"...".."\n"..STRINGS_BACK,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
		end

		screen.print(10+movx,515,os.date(_time.." %m/%d/%y").."  "..batt.lifepercent().."%",1,theme.style.DATETIMECOLOR,color.gray,__ALEFT)

		menu_ctx.run()

		screen.flip()

		ctrls_explorer_list()
	end

end

function explorer.refresh(onflag,first_path)
	if onflag then infosize = os.devinfo(Root2[Dev]) end
	explorer.list = files.listsort(first_path or Root[Dev])
	scroll.list:set(explorer.list,maxim_files)
	if first_path then Root[Dev]=first_path end
end

function ctrls_explorer_list()

	if menu_ctx.open then return end
	if not menu_ctx.close then return end

	if buttons.cancel then -- return directory

		if check_root() then return end

		if not action then multi = {} end
		Root[Dev]=files.nofile(Root[Dev])
		explorer.refresh(false)

		if #backl>0 then
			if scroll.list.maxim == backl[#backl].maxim then
				scroll.list.ini = backl[#backl].ini
				scroll.list.lim = backl[#backl].lim
				scroll.list.sel = backl[#backl].sel
			end
			backl[#backl] = nil
		end
		multi_delete = {}
	end

	if scroll.list.maxim > 0 then -- Is exists any?
		if buttons.up or buttons.analogly < -60 then scroll.list:up() end
		if buttons.down or buttons.analogly > 60 then scroll.list:down() end

		if buttons.accept then
			if explorer.list[scroll.list.sel].size then
				handle_files(explorer.list[scroll.list.sel])
			else
				table.insert(backl, {maxim = scroll.list.maxim, ini = scroll.list.ini, sel = scroll.list.sel, lim = scroll.list.lim, })
				Root[Dev]=explorer.list[scroll.list.sel].path
				explorer.refresh(false)
			end
			multi_delete = {}
			if not action then multi = {} end
		end
	end

	-- Switch device
	if buttons.released.r or buttons.released.l then
		if menu_ctx.open then return end
		if buttons.released.l then Dev -= 1 else Dev += 1 end

		if Dev > #Root then Dev = 1 end
		if Dev < 1 then Dev = #Root end
		os.delay(10)
		explorer.refresh(true)
	end

	-- Multi-Selection
	if buttons.square and scroll.list.maxim > 0 then
		explorer.list[scroll.list.sel].multi = not explorer.list[scroll.list.sel].multi
		if explorer.list[scroll.list.sel].multi then
			table.insert(multi, explorer.list[scroll.list.sel].path)
			explorer.list[scroll.list.sel].index = #multi
			
			table.insert(multi_delete, explorer.list[scroll.list.sel].path)
			
			
		else
			table.remove(multi, explorer.list[scroll.list.sel].index)
			table.remove(multi_delete, explorer.list[scroll.list.sel].index)
		end
	end

	--Return AppManager
	if buttons.select and menu_ctx.open==false then
		submenu_ctx.close = true
		restart_cronopic()
		appman.launch()
	end

	if buttons.start and menu_ctx.open==false then
		submenu_ctx.close = true
		local vbuff = screen.toimage()
		if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end

			SubSystem2()

		os.delay(15)
		if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
	end

	shortcuts()

end

function launch_Daedalus64(obj)

	local vbuff = screen.buffertoimage()

	local limit_roms = 1
	while true do
		buttons.read()
		if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end

		local x,y = 687,75

		draw.fillrect(687,65,250,(limit_roms * 45), color.new(0x2f,0x2f,0x2f,0xff))
		draw.framerect(687,65,250,(limit_roms * 45), color.black, color.shine,6)

		draw.offsetgradrect(x+5,y-5,240,38,theme.style.SELCOLOR,theme.style.BARCOLOR,0x0,0x0,21)
		screen.print(x+(250/2),(limit_roms * 45)+33, "DAEDALUS", 1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)--x+70
            
		screen.flip()

		if buttons.accept then
			game.launchp("DEDALOX64",obj.path)
		end

		if buttons.cancel then break end

	end

end

function launch_Retrovita(gameid,core,obj)

	local vbuff = screen.buffertoimage()

	local limit_roms = 8
	if #core > limit_roms then limit_roms = 8 else limit_roms = #core end
	local scroll_tmp = newScroll(core,limit_roms)

	while true do
		buttons.read()
		if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end

		local x,y = 687,75

		draw.fillrect(687,65,250,(limit_roms * 45)+45, color.new(0x2f,0x2f,0x2f,0xff))
		draw.framerect(687,65,250,(limit_roms * 45)+45, color.black, color.shine,6)

		for i=scroll_tmp.ini, scroll_tmp.lim do

			if i == scroll_tmp.sel then draw.offsetgradrect(x+5,y-5,240,38,theme.style.SELCOLOR,theme.style.BARCOLOR,0x0,0x0,21) end

			screen.print(x+(250/2),y, core[i].name, 1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)--x+80,y+16
			y+=45
		end
		screen.print(x+(250/2),75+(limit_roms * 45)+13, "RETROARCH", 1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)--x+70
            
		screen.flip()

		if scroll_tmp.maxim > 0 then

			if buttons.left or buttons.right then xscroll = 10 end

			if buttons.up or buttons.analogly < -60 then
				scroll_tmp:up()
			end
			if buttons.down or buttons.analogly > 60 then
				scroll_tmp:down()
			end

			if buttons.accept then
				game.launchp(gameid,core[scroll_tmp.sel].self,obj.path)
			end
			if buttons.cancel then
				os.delay(250) break
			end
		end
	end
end

nes = {
	{ self = "app0:nestopia_libretro.self", name = "Nestopia" },
	{ self = "app0:fceumm_libretro.self",   name = "Fceumm"   },
	{ self = "app0:quicknes_libretro.self", name = "QuickNes" },
}

snes = {

	{ self = "app0:mednafen_supafaust_libretro.self",      name = "Mednafen Supafaust"      },
	{ self = "app0:snes9x2002_libretro.self",      name = "Snes9x 2002"      },
	{ self = "app0:snes9x2005_libretro.self",      name = "Snes9x 2005"      },
	{ self = "app0:snes9x2005_plus_libretro.self", name = "Snes9x 2005 Plus" },
	{ self = "app0:snes9x2010_libretro.self",      name = "Snes9x 2010"      },
}

gbc = {
	{ self = "app0:gambatte_libretro.self", name = "Gambatte" },
	{ self = "app0:gearboy_libretro.self",  name = "Gearboy"  },
	{ self = "app0:tgbdual_libretro.self",  name = "TGB Dual" },
	{ self = "app0:mgba_libretro.self",     name = "mGBA" },
}

gba = {
	{ self = "app0:gpsp_libretro.self",     name = "gpSP"     },
	{ self = "app0:vba_next_libretro.self", name = "VBA Next" },
	{ self = "app0:vbam_libretro.self",     name = "VBA-M" },
}

psx = {
	{ self = "app0:pcsx_rearmed_libretro.self", name = "PCSX" },
}

sega = {
	{ self = "app0:genesis_plus_gx_libretro.self", name = "Genesis GX Plus" },
	{ self = "app0:genesis_plus_gx_wide_libretro.self", name = "Genesis GX Wide" },
	{ self = "app0:picodrive_libretro.self", name = "Picodrive" },
}

function handle_files(cnt)

	local extension = cnt.ext

	if (extension == "nes" or extension == "fds") and game.exists("RETROVITA") then
		launch_Retrovita("RETROVITA",nes,cnt)
	elseif (extension == "sfc" or extension == "smc" or extension == "fig") and game.exists("RETROVITA") then
		launch_Retrovita("RETROVITA",snes,cnt)
	elseif (extension == "gb" or extension == "gbc") and game.exists("RETROVITA") then
		launch_Retrovita("RETROVITA",gbc,cnt)
	elseif extension == "gba" and game.exists("RETROVITA") then
		launch_Retrovita("RETROVITA",gba,cnt)
	elseif (extension == "v64" or extension == "z64" or extension == "n64" or extension == "rom") and game.exists("DEDALOX64") then
		launch_Daedalus64(cnt)
	elseif extension == "png" or extension == "jpg" or extension == "jpeg" or extension == "bmp" or extension == "gif" then
		visorimg(cnt.path)
	elseif extension == "vpk" then
		buttons.homepopup(0)
			show_msg_vpk(cnt)
			if vpkdel then explorer.refresh(true) end
		buttons.homepopup(1)
	elseif extension == "zip" or extension == "rar" then
		show_scan(cnt)
	elseif extension == "mp3" or extension == "wav" or extension == "ogg" then
		MusicPlayer(cnt)
	elseif extension == "txt" or extension == "lua" or extension == "ini" or extension == "sfo" or extension == "xml" or extension == "inf" or extension == "cfg" or extension == "lpl" then
		visortxt(cnt,true)
	elseif extension == "mp4" then
		VideoPlayer(cnt)
	end
	if extension == "pbp" or extension == "iso" or extension == "cso" or extension == "bin" then
		show_msg_pbp(cnt)
	end
	if (extension == "md" or extension == "bin") and game.exists("RETROVITA") then
		--launch_Retrovita("RETROVITA",sega,cnt)
	end



end

---------------------------------- SubMenu Contextual 1 ---------------------------------------------------

__ACTION_WAIT_NOTHING = 0
__ACTION_WAIT_PASTE = 1
__ACTION_WAIT_EXTRACT = 2

local src_path_callback = function ()
   if #explorer.list > 0 then
      local ext = explorer.list[scroll.list.sel].ext or ""
      if menu_ctx.scroll.sel != 3 or (menu_ctx.scroll.sel == 3 and (ext:lower()=="7z" or ext:lower()=="zip" or ext:lower()=="rar" or ext:lower()=="vpk")) then
         if not multi or #multi < 1 then
            table.insert(multi, explorer.list[scroll.list.sel].path)
         end
         explorer.action = menu_ctx.scroll.sel
 
         if menu_ctx.scroll.sel != 3 then menu_ctx.wait_action = __ACTION_WAIT_PASTE else menu_ctx.wait_action = __ACTION_WAIT_EXTRACT end
         menu_ctx.wakefunct()
    	 menu_ctx.close = true
         action = true
      end
   end
end

local paste_callback = function ()
    explorer.dst = Root[Dev]
 
    if explorer.action == 1 then                        --Paste from Copy
        if #multi>0 then
            buttons.homepopup(0)
            reboot=false
            for i=1,#multi do
                files.copy(multi[i],explorer.dst)
            end
            buttons.homepopup(1)
            reboot=true
        end
 
    elseif explorer.action == 2 then                     --Paste from Move
        if #multi>0 then
			reboot=false
			local _dst = explorer.dst:sub(1,3)
			for i=1,#multi do
				if multi[i]:sub(1,3) == _dst then
					files.move(multi[i],explorer.dst)
				else
					buttons.homepopup(0)
					if files.copy(multi[i],explorer.dst)==1 then files.delete(multi[i]) end
					buttons.homepopup(1)
				end
			end
			reboot=true
		end

    elseif explorer.action == 3 then                     --Extract
        if #multi>0 then
            reboot=false
			message_wait(STRINGS_START_EXTRACTION)
			os.delay(1500)
			local res = 0
            for i=1,#multi do
				buttons.homepopup(0)
				if string.lower(files.ext(multi[i])) == "7z" then
					if files.extract(multi[i],explorer.dst) == 1 then os.message(STRINGS_SUCCESSFUL) else os.message(STRINGS_INSTALL_ERROR) end
				else
					if os.message(multi[i]+"\n"+STRINGS_PASS ,1)== 1 then
						local pass = osk.init(STRINGS_OS_PASS , "" , 50, __OSK_TYPE_LATIN, __OSK_MODE_PASSW)
						if pass then
							if files.extract(multi[i],explorer.dst,pass) == 1 then os.message(STRINGS_SUCCESSFUL) else os.message(STRINGS_INSTALL_ERROR) end
						end
					else
						if files.extract(multi[i],explorer.dst) == 1 then os.message(STRINGS_SUCCESSFUL) else os.message(STRINGS_INSTALL_ERROR) end
					end
				end
				buttons.homepopup(1)
            end
            reboot=true
        end
    end
 
--clean
    menu_ctx.wakefunct()
    menu_ctx.close = true
    action = false
    explorer.refresh(true)
    explorer.action = 0
	menu_ctx.wait_action = __ACTION_WAIT_NOTHING
    explorer.dst = ""
    multi, multi_delete = {},{}
end
 
local delete_callback = function () -- TODO: add move to -1 pos of the deleted element in list
	local vbuff = screen.toimage()
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
	local pos_menu = menu_ctx.scroll.sel

    if #explorer.list > 0 then
		local del=false
        if explorer.list[scroll.list.sel].multi then
            if #multi_delete>0 then
			
				local strgcat = ""
				for i=1,#multi_delete do
					strgcat += multi_delete[i].."\n"
				end
			
                if os.dialog(STRINGS_DELETE_QUESTION.."\n\n"..#multi_delete.." "..STRINGS_FILES_FOLDERS.."(s): ".."\n\n"..strgcat, STRINGS_SUBMENU_DELETE, __DIALOG_MODE_OK_CANCEL) == true then
					del=true
                    reboot=false
                        for i=1,#multi_delete do files.delete(multi_delete[i]) end
                    reboot=true
                end
            end
        else
			if os.dialog(STRINGS_DELETE_QUESTION.."\n\n"..explorer.list[scroll.list.sel].path, STRINGS_SUBMENU_DELETE, __DIALOG_MODE_OK_CANCEL) == true then
				del=true
                reboot=false
                    files.delete(explorer.list[scroll.list.sel].path)
                reboot=true
            end
        end
		if del then
--clean
			menu_ctx.wakefunct()
			menu_ctx.close = true
			action = false
			explorer.refresh(true)
			explorer.action = 0
			menu_ctx.wait_action = __ACTION_WAIT_NOTHING
			explorer.dst = ""
			multi, multi_delete = {},{}
		end
	end

	menu_ctx.scroll.sel = pos_menu
	os.delay(15)
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
end

local rename_callback = function ()
    if #explorer.list > 0 then
        local new_name = osk.init(STRINGS_SUBMENU_RENAME, files.nopath(explorer.list[scroll.list.sel].path), 256, __OSK_TYPE_DEFAULT, __OSK_MODE_TEXT)
        if new_name then
            local fullpath = files.nofile(explorer.list[scroll.list.sel].path)
            files.rename(explorer.list[scroll.list.sel].path, new_name)
            --explorer.list[scroll.list.sel].path = fullpath+new_name
            --explorer.list[scroll.list.sel].name = new_name
            --explorer.list[scroll.list.sel].ext = files.ext(new_name)
--clean
            menu_ctx.wakefunct()
            menu_ctx.close = true
            action = false
            explorer.action = 0
			multi, multi_delete = {},{}
			explorer.list = files.listsort(Root[Dev])
        end
    end
end

local newfile_callback = function () -- Added suport multi-new-folder
    local i=1
    while files.exists(Root[Dev].."/"..string.format("%s%03d",STRINGS_NEW_FILE,i)) do
        i+=1
    end
    local name_folder = osk.init(STRINGS_CREAT_FILE, string.format("%s%03d",STRINGS_NEW_FILE,i), 256, __OSK_TYPE_DEFAULT, __OSK_MODE_TEXT)
    if name_folder then
        local dest = Root[Dev].."/"..name_folder
        if Root[Dev]:sub(#Root[Dev]) == "/" then dest = Root[Dev]..name_folder end
        files.new(dest)
--clean
        menu_ctx.wakefunct()
        menu_ctx.close = true
        action = false
        explorer.refresh(true)
        explorer.action = 0
		menu_ctx.wait_action = __ACTION_WAIT_NOTHING
		explorer.dst = ""
        multi, multi_delete = {},{}
    end
end
 
local makedir_callback = function () -- Added suport multi-new-folder
    local i=1
    while files.exists(Root[Dev].."/"..string.format("%s%03d",STRINGS_NEW_FOLDER,i)) do
        i+=1
    end
    local name_folder = osk.init(STRINGS_CREAT_FOLDER, string.format("%s%03d",STRINGS_NEW_FOLDER,i), 256, __OSK_TYPE_DEFAULT, __OSK_MODE_TEXT)
    if name_folder then
        local dest = Root[Dev].."/"..name_folder
        if Root[Dev]:sub(#Root[Dev]) == "/" then dest = Root[Dev]..name_folder end
        files.mkdir(dest)
--clean
        menu_ctx.wakefunct()
        menu_ctx.close = true
        action = false
        explorer.refresh(true)
        explorer.action = 0
		menu_ctx.wait_action = __ACTION_WAIT_NOTHING
		explorer.dst = ""
        multi, multi_delete = {},{}
    end
end
 
local sizedir_callback = function ()
	local vbuff = screen.toimage()
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
	local pos_menu = menu_ctx.scroll.sel
	local sizedir=0

	if #explorer.list > 0 then
		if explorer.list[scroll.list.sel].multi then
			if #multi>0 then
				sizedir=0
				message_wait()
				for i=1,#multi do
					sizedir += files.size(multi[i])
				end--for
				os.message(STRINGS_CALLBACKS_SIZE_ALL.." "..files.sizeformat(sizedir or 0))
				--os.dialog2(STRINGS_CALLBACKS_SIZE_ALL.." "..files.sizeformat(sizedir or 0))
			end
		else
			if not explorer.list[scroll.list.sel].size then                -- Its Dir
				message_wait()
				--os.dialog2(explorer.list[scroll.list.sel].name+"\n"+STRINGS_SIZE_IS+files.sizeformat(files.size(explorer.list[scroll.list.sel].path) or 0))
				os.message(explorer.list[scroll.list.sel].name+"\n"+STRINGS_SIZE_IS+files.sizeformat(files.size(explorer.list[scroll.list.sel].path) or 0))
			else
				--os.dialog2(explorer.list[scroll.list.sel].name+"\n"+STRINGS_SIZE_IS+explorer.list[scroll.list.sel].size)
				os.message(explorer.list[scroll.list.sel].name+"\n"+STRINGS_SIZE_IS+explorer.list[scroll.list.sel].size)
			end
		end
    end
	sizedir=0
	menu_ctx.scroll.sel = pos_menu
	os.delay(15)
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
end

local installgame_callback = function ()
	local vbuff = screen.toimage()
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
    if #explorer.list > 0 then
        if explorer.list[scroll.list.sel].ext == "vpk" then
            buttons.homepopup(0)
                show_msg_vpk(explorer.list[scroll.list.sel])
            buttons.homepopup(1)
            return
        end
 
        if not files.exists(string.format("%s/eboot.bin",explorer.list[scroll.list.sel].path)) and
            not files.exists(string.format("%s/sce_sys/param.sfo",explorer.list[scroll.list.sel].path)) then return end

		local x,y = (960-420)/2,(544-420)/2
        local resp=0

		local tmp_vpk  = {}

        local info = game.info(string.format("%s/sce_sys/param.sfo",explorer.list[scroll.list.sel].path))
        tmp_vpk.img = image.load(string.format("%s/sce_sys/icon0.png",explorer.list[scroll.list.sel].path))
 
        local res,xscr = false,290
        local Xa = "O: "
        local Oa = "X: "
        if accept_x == 1 then Xa,Oa = "X: ","O: " end
        while true do
            buttons.read()
			if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
 
            draw.fillrect(x,y,420,420, color.new(0x2f,0x2f,0x2f,0xff))
            draw.framerect(x,y,420,420, color.black, color.shine,6)
   
            if info then
                if screen.textwidth(tostring(info.TITLE) or "UNK") > 380 then
                    xscr = screen.print(xscr, y+12, tostring(info.TITLE) or "UNK",1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__SLEFT,380)
                else
                    screen.print(960/2,y+12,tostring(info.TITLE),1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
                end
                if info.CATEGORY == "gp" then
                    screen.print(960/2,y+35,"UPDATE: "..tostring(info.APP_VER) or "",1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
                else
                    screen.print(960/2,y+35,tostring(info.APP_VER) or "",1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
                end
                screen.print(960/2,y+55,tostring(info.TITLE_ID),1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
            end
			if tmp_vpk.img then
				tmp_vpk.img:scale(150)
				tmp_vpk.img:setfilter(__IMG_FILTER_LINEAR, __IMG_FILTER_LINEAR)
				tmp_vpk.img:center()
				tmp_vpk.img:blit(960/2,544/2)
            end
 
            screen.print(960/2,y+325,STRINGS_SUBMENU_INSTALL_GAME +" ?",1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
            screen.print(960/2,y+395,Xa..STRINGS_CONFIRM.." | "..Oa..STRINGS_SUBMENU_CANCEL,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
            screen.flip()
 
            if buttons.accept or buttons.cancel then
                if buttons.accept then res = true end
                break
            end
        end

        if res == false then
			os.delay(15)
			if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
			return
		end
 
        buttons.homepopup(0)
        reboot=false
            local result = game.installdir(explorer.list[scroll.list.sel].path)
        buttons.homepopup(1)
        reboot=true
 
		bufftmp = nil
		if result ==1 then

			--Restore Save from "ux0:data/ONEMenu/Saves
			if info.INSTALL_DIR_SAVEDATA and files.exists("ux0:data/ONEMenu/SAVES/"..info.INSTALL_DIR_SAVEDATA) then
				--game.umount()
					--game.mount("ux0:user/00/savedata/"..info.INSTALL_DIR_SAVEDATA)
					local info_time = files.info("ux0:data/ONEMenu/SAVES/"..info.INSTALL_DIR_SAVEDATA)
					if os.message(STRINGS_APP_RESTORE_SAVE.."\n"..info_time.mtime or "", 1) == 1 then
						files.copy("ux0:data/ONEMenu/SAVES/"..info.INSTALL_DIR_SAVEDATA, "ux0:user/00/savedata/")
						--personalize_savedata("ux0:user/00/savedata/"..scan_vpk.sfo.INSTALL_DIR_SAVEDATA.."/sce_sys/param.sfo")
					end
				--game.umount()
			elseif files.exists("ux0:data/ONEMenu/SAVES/"..info.TITLE_ID) then
				--game.umount()
					--game.mount("ux0:user/00/savedata/"..info.TITLE_ID)
					local info_time = files.info("ux0:data/ONEMenu/SAVES/"..info.TITLE_ID)
					if os.message(STRINGS_APP_RESTORE_SAVE.."\n"..info_time.mtime or "", 1) == 1 then
						files.copy("ux0:data/ONEMenu/SAVES/"..info.TITLE_ID, "ux0:user/00/savedata/")
						--personalize_savedata("ux0:user/00/savedata/"..scan_vpk.sfo.TITLE_ID.."/sce_sys/param.sfo")
					end
				--game.umount()
			end

			if os.message(STRINGS_LAUNCH_GAME+"\n"+info.TITLE_ID+" ?",1) == 1 then
				if game.exists(info.TITLE_ID) then
					if info.CATEGORY == "ME" then game.open(info.TITLE_ID) else game.launch(info.TITLE_ID) end
				end
			end

			fillappmanlist(tmp_vpk, info)
			--appman.len +=1
			infodevices()

		else
			os.message(STRINGS_INSTALL_ERROR)
		end

--clean
        menu_ctx.wakefunct()
        menu_ctx.close = true
        action = false
        explorer.refresh(true)
        explorer.action = 0
        multi, multi_delete = {},{}
    end
	os.delay(15)
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
end


function customthemes_install(path,id)

	local path_tmp = path

	local install_in = __THEMES_UX0
	local title = string.format(STRINGS_SUBMENU_INSTALLCTHEME)
	local w,h = screen.textwidth(title,1) + 120,170
	local x,y = 480 - (w/2), 272 - (h/2)

	local uma0_in = false
	if files.exists("uma0:") then
		local device_uma0 = os.devinfo("uma0:")
		if device_uma0 then uma0_in = true end
	end
	local imc0_in = false
	if files.exists("imc0:") then
		local device_imc0 = os.devinfo("imc0:")
		if device_imc0 then imc0_in = true end
	end

	while true do
		buttons.read()
		power.tick()
		if theme.data["list"] then theme.data["list"]:blit(0,0) end 

		draw.fillrect(x, y, w, h, theme.style.BARCOLOR)
		draw.rect(x,y,w,h,color.white)
			screen.print(480,y+12, title,1,color.white,color.black, __ACENTER)
			screen.print(480,y+40,SYMBOL_CROSS.."  -  ".."UX0:", 1,color.white,color.black, __ACENTER)
			screen.print(480,y+65,SYMBOL_SQUARE.."  -  ".."UR0:", 1,color.white,color.black, __ACENTER)
			screen.print(480,y+90,SYMBOL_TRIANGLE.."  -  ".."UMA0:", 1,color.white,color.black, __ACENTER)
			screen.print(480,y+115,"L".."  -  ".."IMC0:", 1,color.white,color.black, __ACENTER)
			screen.print(480,y+145,SYMBOL_CIRCLE.." "..STRINGS_SUBMENU_CANCEL, 1,color.white,color.black, __ACENTER)
		screen.flip()

		if buttons.accept or buttons.triangle or buttons.square or buttons.cancel or buttons.l then
			if buttons.accept then install_in = __THEMES_UX0
			elseif buttons.square then install_in = __THEMES_UR0
			elseif buttons.triangle then
				if uma0_in then	install_in = __THEMES_UMA0 else os.message(STRINGS_THEMES_NO_PARTITION) return false end
			elseif buttons.l then
				if imc0_in then	install_in = __THEMES_IMC0 else os.message(STRINGS_THEMES_NO_PARTITION) return false end
			else return false end
			break
		end

	end--while
	buttons.read()

	if install_in == __THEMES_UX0 and Root2[Dev] != "ux0:" then
		if files.copy(path,"ux0:/data/customtheme/")==1 then files.delete(path) end
		path_tmp = "ux0:/data/customtheme/"..id
	end
	if install_in == __THEMES_UR0 and Root2[Dev] != "ur0:" then
		if files.copy(path,"ur0:/data/customtheme/")==1 then files.delete(path) end
		path_tmp = "ur0:/data/customtheme/"..id
	end
	if install_in == __THEMES_UMA0 and Root2[Dev] != "uma0:" then
		if files.copy(path,"uma0:/data/customtheme/")==1 then files.delete(path) end
		path_tmp = "uma0:/data/customtheme/"..id
	end
	if install_in == __THEMES_IMC0 and Root2[Dev] != "imc0:" then
		if files.copy(path,"imc0:/data/customtheme/")==1 then files.delete(path) end
		path_tmp = "imc0:/data/customtheme/"..id
	end

	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
		message_wait(STRINGS_SUBMENU_INSTALLCTHEME)
	os.delay(150)
	
	buttons.homepopup(0)
		reboot=false
			local result = themes.install(path_tmp, install_in)
	buttons.homepopup(1)
		reboot=true
 
	--os.message(STRINGS_SUBMENU_INSTALLCTHEME.."\n"..STRINGS_RESULT..result)
	if result == 1 then
		if os.message(STRINGS_THEMES_SETTINGS,1)==1 then
			os.delay(150)
			os.uri("settings_dlg:custom_themes")
		end
	end
	return
end

local installtheme_callback = function ()
    if #explorer.list > 0 then

		bufftmp = screen.toimage()
		local x,y = (960-420)/2,(544-420)/2

		if not files.exists(string.format("%s/theme.xml",explorer.list[scroll.list.sel].path)) then return end

		local info = themes.info(string.format("%s/theme.xml",explorer.list[scroll.list.sel].path))
		local prev = nil
		if info and info.package then prev = image.load(explorer.list[scroll.list.sel].path.."/"..info.package)	end

		local Xa = "O: "
		local Oa = "X: "
		if accept_x == 1 then Xa,Oa = "X: ","O: " end

	    while true do
			buttons.read()
			if bufftmp then bufftmp:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end

			draw.fillrect(x,y,420,420,color.new(0x2f,0x2f,0x2f,0xff))
			draw.framerect(x,y,420,420,color.black, color.shine,6)

			if prev then
				-- prev:scale(150)
				prev:setfilter(__IMG_FILTER_LINEAR, __IMG_FILTER_LINEAR)
				prev:center()
				prev:blit(960/2,544/2)
			end

			screen.print(960/2,y+15,STRINGS_SUBMENU_INSTALLCTHEME,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
			if info and info.title then
				screen.print(960/2,y+340,info.title,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
			end
			if info and info.author then
				screen.print(960/2,y+360,info.author,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
			end
			screen.print(960/2,y+395,Xa..STRINGS_CONFIRM.." | "..Oa..STRINGS_SUBMENU_CANCEL,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)

			screen.flip()

			if buttons.accept then
				buttons.homepopup(0)
					--This!!!
					customthemes_install(explorer.list[scroll.list.sel].path,explorer.list[scroll.list.sel].name)
				buttons.homepopup(1)
				
				--clean
				menu_ctx.wakefunct()
				menu_ctx.close = true
				action = false
				explorer.refresh(true)
				explorer.action = 0
				multi, multi_delete = {},{}
				break
			end
			if buttons.cancel then break end

		end--while

		os.delay(15)
		if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
	end
end

local filesexport_callback = function ()

	local _path = explorer.list[scroll.list.sel].path
	local no_paths = {
		"ux0:app", "ux0:/app", "ux0:patch", "ux0:/patch",
		"ur0:app", "ur0:/app", "ur0:patch", "ur0:/patch",
		"uma0:app", "uma0:/app", "uma0:patch", "uma0:/patch",
	}

	for i=1,#no_paths do
		local x1,x2 = string.find(_path:lower(), no_paths[i], 1, true)
		if x1 then return false	 end
	end

	--local vbuff = screen.toimage()
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
	local pos_menu = menu_ctx.scroll.sel

    local result, ext = 0,""
	if #explorer.list > 0 then
		if not explorer.list[scroll.list.sel].size then                -- Its Dir

			local cont_multimedia,cont_img,cont_mp3,cont_mp4 = 0,0,0,0

			if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
			message_wait()

			local tmp = files.listfiles(explorer.list[scroll.list.sel].path)
			if tmp and #tmp > 0 then

				for i=1,#tmp do
					ext = tmp[i].ext:lower() or ""
					if ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "bmp" or ext == "gif" or ext == "mp3" or ext == "mp4" then
						cont_multimedia+=1
						reboot=false
							if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
							message_wait(tmp[i].name)
								musicfile = tmp[i].name
							result = files.export(tmp[i].path,"OneMenu Export")
								musicfile = ""
						reboot=true

						if result == 1 then
							if ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "bmp" or ext == "gif" then cont_img+=1
								elseif ext == "mp3" then cont_mp3+=1
									else cont_mp4+=1 end
						else
							os.message(STRINGS_EXPORT_FAIL.."\n"..tmp[i].name.."\n"..STRINGS_EXPORT_REBOOT,0)
						end
					end
				end--for

			end

			if cont_multimedia > 0 then
				os.message(STRINGS_EXPORT_MP3..cont_mp3.."\n"..STRINGS_EXPORT_MP4..cont_mp4.."\n"..STRINGS_EXPORT_IMG..cont_img.."\n"..STRINGS_EXPORT_OPEN)
			else
				os.message(STRINGS_EXPORT_NO_FILES)
			end

		else
			ext = explorer.list[scroll.list.sel].ext:lower() or ""
			if ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "bmp" or ext == "gif" or ext == "mp3" or ext == "mp4" then

				if ext == "mp3" and not files.exists("music0:") then
					os.message(STRINGS_EXPORT_REBOOT,0) return
				end

				reboot=false
					if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
					message_wait()
						musicfile = explorer.list[scroll.list.sel].name
					result = files.export(explorer.list[scroll.list.sel].path,"OneMenu Export")
						musicfile = ""
				reboot=true

				if result == 1 then
					if os.message(STRINGS_EXPORT_OPEN_APP,1)==1 then
						os.delay(150)
						if ext == "mp3" then os.uri("music:browse?category=ALL")
						elseif ext == "mp4" then os.uri("video:browse?category=ALL")
						else os.uri("photo:browse?category=ALL") end
					end
				else
					os.message(STRINGS_EXPORT_FAIL.."\n"..explorer.list[scroll.list.sel].name.."\n"..STRINGS_EXPORT_REBOOT,0)
				end
			end
		end
	end

	if result == 1 then
--clean
		menu_ctx.wakefunct()
		menu_ctx.close = true
		if ext == "mp4" then
			action = false
			explorer.refresh(true)
			multi, multi_delete = {},{}
			explorer.action = 0
		end

    end

	menu_ctx.scroll.sel = pos_menu
	os.delay(15)
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
end

--Parse MF
local parseMF_callback = function (link)
	local onNetGetFileOld = onNetGetFile
	onNetGetFile = nil
	if http.download(link,'tmp').success then
		onNetGetFile = onNetGetFileOld
		local tmp = mf.getDirectLink('tmp')
		if tmp.link and tmp.name then
			download_checking(tmp.link,tmp.name)
		end

	end
end

function download_checking(url,name)

	local down,ext = false,files.ext(name)

	if string.len(ext) >= 3 then

		local _type = nil
		if ext:lower() == "mp4" then _type = os.VIDEO
		elseif ext:lower() == "mp3" then _type,down = os.AUDIO,true
			message_wait(STRINGS_SUBMENU_QR_ACTIVE)
			os.delay(1500)
		elseif ext:lower() == "jpg" or ext:lower() == "png" then _type = os.IMAGE
		end

		if _type != nil then
			local icon = "ux0:data/ONEMENU/avatar.png"
			if files.exists(icon) then
				os.downloader(url:gsub("https","http"),_type,name,icon)
			else
				os.downloader(url:gsub("https","http"),_type,name)
			end

			message_wait(STRINGS_WAIT_MGE)
			os.delay(1500)

			--Chequeo si Cap en Descarga :D
			local folders = files.listdirs("ux0:bgdl/t/")
			if folders and #folders > 0 then
				for i=1,#folders do
					if files.exists(folders[i].path.."/"..name) then
						message_wait(STRINGS_SUBMENU_QR_ACTIVE)
						os.delay(1500)
						down = true
						i=#folders+1
					end
				end
			end
		end
	end

	--Descarga 1er plano
	if not down then
		buttons.homepopup(0)
			local resd = false

			if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
			message_wait(STRINGS_SUBMENU_QR_START_DL)
			os.delay(750)

			__NAME_DOWNLOAD = name
			resd = http.download(url, "ux0:download/"..name).success

			if not resd or CancelDownload then
				files.delete("ux0:download/"..name)
				if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
				if CancelDownload then
					message_wait(STRINGS_SUBMENU_QR_CANCEL_DL)
				else
					message_wait(STRINGS_SUBMENU_QR_DL_FAILED)
				end
				os.delay(1000)
				CancelDownload = false
				return false
			end
		buttons.homepopup(1)
		os.message(STRINGS_DOWNLOAD_SUCCESS.." ux0:downloads\n\n")
		explorer.refresh(true)
		return true
	end

end

__NAME_DOWNLOAD = ""
local qr_callback = function ()

	__NAME_DOWNLOAD = ""
	--files.delete("ux0:download/")
	if not wlan.isconnected() then wlan.connect() end

	local vbuff = screen.toimage()
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end

	local pos_menu = menu_ctx.scroll.sel
	menu_ctx.wakefunct()

	url = cam.scanqr(STRINGS_SUBMENU_QR_SCAN,theme.style.TXTBKGCOLOR)

	local url_backup,pflag = "",false
	if url then

		url_backup = url

		if string.find(url:lower(), "mediafire", 1, true) then
			parseMF_callback(url)
			pflag = true
		end

		local res,filename = "",false
		if not pflag then

			res,filename = http.getfile(url_backup,"ux0:download/")

			if not res then
				filename = osk.init(STRINGS_SUBMENU_QR_DOWNLOAD, STRINGS_SUBMENU_QR_FILENAME)
				if filename then
					__NAME_DOWNLOAD = filename
					tmp = filename
				else tmp = "file"
					__NAME_DOWNLOAD = "file"
				end

				http.download(url_backup,"ux0:download/"..filename)
			end
			if filename then tmp = filename else tmp = "file" end

			if files.exists("ux0:download/"..tmp) then
				os.message(STRINGS_DOWNLOAD_SUCCESS.." ux0:download\n\n"..tmp)
				explorer.refresh(true)
			else
				files.delete("ux0:download/"..tmp)
				os.message(STRINGS_DOWNLOAD_FAILED.." ux0:download\n\n"..tmp)
			end
		end
	end
	--files.delete("ux0:downloads/tmp")

--clean
	__NAME_DOWNLOAD = ""
	action = false
	explorer.action = 0
	multi={}
	menu_ctx.scroll.sel = pos_menu
	os.delay(15)
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
	os.delay(50)
end

local cancel_callback = function ()
	menu_ctx.wait_action = __ACTION_WAIT_NOTHING
	menu_ctx.wakefunct()
--clean
	menu_ctx.close = true
	action = false
	explorer.refresh(false)
	explorer.action = 0
	multi, multi_delete = {},{}
end

---------------------------------- SubMenu Contextual 2 ---------------------------------------------------
local usb_callback = function ()
	local vbuff = screen.toimage()
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
	local pos_menu = menu_ctx.scroll.sel
	usbMassStorage()
	buttons.read()

	--clean
		action = false
		explorer.refresh(true)
		multi, multi_delete = {},{}
		explorer.action = 0

	menu_ctx.wakefunct2()
	menu_ctx.scroll.sel = pos_menu

	os.delay(150)
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
end

local ftp_callback = function ()
	local vbuff = screen.toimage()
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
	buttons.homepopup(0)
    local pos_menu = menu_ctx.scroll.sel
    if startftp() then
--clean
		action = false
		explorer.refresh(true)
		multi, multi_delete = {},{}
		explorer.action = 0
    end
	buttons.homepopup(1)
	menu_ctx.wakefunct2()
    menu_ctx.scroll.sel = pos_menu
	os.delay(15)
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
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

local makezip_callback = function ()
	if #explorer.list > 0 then
	
		local name = osk.init(STRINGS_FILENAME, STRINGS_FILENAME, 128, __OSK_TYPE_DEFAULT, __OSK_MODE_TEXT)
        if name then
			name = name .. ".zip"
		end
		if not name or name == "" then return end

		local pass = nil
		if os.message("\n"..STRINGS_PASS,1)==1 then
			pass = osk.init(STRINGS_OS_PASS , "" , 50, __OSK_TYPE_LATIN, __OSK_MODE_TEXT)
            if pass == "" then pass = false end
		end

		local res = 2
        if explorer.list[scroll.list.sel].multi then
            if #multi_delete>0 then
				reboot=false
					if pass then
						res = files.makezip(Root[Dev].."/"..name, multi_delete,pass)
					else
						res = files.makezip(Root[Dev].."/"..name, multi_delete)
					end
				reboot=true
					if res then os.message(STRINGS_SUCCESSFUL) else os.message(STRINGS_INSTALL_ERROR) end
            end
        else
			reboot=false
				if pass then
					res = files.makezip(Root[Dev].."/"..name, explorer.list[scroll.list.sel].path, pass)
				else
					res = files.makezip(Root[Dev].."/"..name, explorer.list[scroll.list.sel].path)
				end
			reboot=true
				if res then os.message(STRINGS_SUCCESSFUL) else os.message(STRINGS_INSTALL_ERROR) end
        end
--clean
		menu_ctx.wakefunct()
		menu_ctx.close = true
		action = false
		explorer.refresh(true)
		explorer.action = 0
		multi, multi_delete = {},{}
		--explorer.list = files.listsort(Root[Dev])
    end
end

menu_ctx = { -- Creamos un objeto menu contextual
    h = 544,				-- Height of menu
    w = 190,				-- Width of menu--170
    x = -190,				-- X origin of menu--160
    y = 0,					-- Y origin of menu
    open = false,			-- Is open the menu?
    close = true,
    speed = 10,				-- Speed of Effect Open/Close.
    ctrl = "triangle",		-- The button handle Open/Close menu.
    scroll = newScroll(),	-- Scroll of menu options.
	wait_action = 0,
}

function menu_ctx.wakefunct()
    menu_ctx.options = { 	-- Handle Option Text and Option Function
		{ text = STRINGS_SUBMENU_DELETE,        funct = delete_callback },
		{ text = STRINGS_SUBMENU_RENAME,        funct = rename_callback },
		{ text = STRINGS_SUBMENU_SIZE,          funct = sizedir_callback },

		{ text = STRINGS_NEW_FILE,       		funct = newfile_callback },
		{ text = STRINGS_SUBMENU_MAKEDIR,       funct = makedir_callback },
		{ text = STRINGS_SUBMENU_MAKEZIP,		funct = makezip_callback },

		{ text = STRINGS_SUBMENU_INSTALL_GAME, 	funct = installgame_callback },
		{ text = STRINGS_SUBMENU_INSTALLCTHEME,	funct = installtheme_callback },
        { text = STRINGS_SUBMENU_EXPORT,        funct = filesexport_callback },
		{ text = STRINGS_SUBMENU_QR,            funct = qr_callback },

		{ text = STRINGS_SUBMENU_CANCEL,        funct = cancel_callback },

    }
    if menu_ctx.wait_action==__ACTION_WAIT_PASTE then
        table.insert(menu_ctx.options, 1, { text = STRINGS_SUBMENU_PASTE,       funct = paste_callback })
    elseif menu_ctx.wait_action==__ACTION_WAIT_EXTRACT then
        table.insert(menu_ctx.options, 1, { text = STRINGS_SUBMENU_EXTRACT_TO,  funct = paste_callback })
    else
        table.insert(menu_ctx.options, 1, { text = STRINGS_SUBMENU_COPY,        funct =  src_path_callback })
        table.insert(menu_ctx.options, 2, { text = STRINGS_SUBMENU_MOVE,        funct = src_path_callback })
        table.insert(menu_ctx.options, 3, { text = STRINGS_SUBMENU_EXTRACT,     funct = src_path_callback })
    end
    menu_ctx.scroll = newScroll(menu_ctx.options, #menu_ctx.options)
end

menu_ctx.wakefunct()

function menu_ctx.run()

    if buttons[menu_ctx.ctrl] then menu_ctx.close = not menu_ctx.close end
	if buttons[menu_ctx.ctrl] then menu_ctx.wakefunct()	end
    menu_ctx.draw()
	menu_ctx.buttons()
end

local x_print = 5
function menu_ctx.draw()

    if not menu_ctx.close and menu_ctx.x < 0 then
        menu_ctx.x += menu_ctx.speed
    elseif menu_ctx.close and menu_ctx.x > -menu_ctx.w then
        menu_ctx.x -= menu_ctx.speed
    end

	if menu_ctx.x > -menu_ctx.w then
		draw.fillrect(menu_ctx.x, menu_ctx.y, menu_ctx.w, menu_ctx.h, theme.style.BARCOLOR)
	end

    if menu_ctx.x >= 0 then

        menu_ctx.open = true
        local h = menu_ctx.y + 75 -- Punto de origen de las opciones
        for i=menu_ctx.scroll.ini,menu_ctx.scroll.lim do

			screen.clip(0,0,menu_ctx.w-5, menu_ctx.h)
			if i==menu_ctx.scroll.sel then

				draw.fillrect(0,h-4,menu_ctx.w,25,theme.style.SELCOLOR)

				if screen.textwidth(menu_ctx.options[i].text) > menu_ctx.w-10 then
					x_print = screen.print(x_print, h, menu_ctx.options[i].text, 1, color.green, color.blue, __SLEFT,menu_ctx.w-10)
				else
					screen.print(5, h, menu_ctx.options[i].text, 1, color.green, color.blue, __ALEFT)
					x_print = 5
				end

			else
				screen.print(5, h, menu_ctx.options[i].text, 1, theme.style.TXTCOLOR, color.blue, __ALEFT)
			end
			screen.clip()

			if (i == 3 or i == 6 or i == 9 or i == 11) then
				h += 35
			else
				h += 26
			end
        end
    else
        menu_ctx.open = false
    end
end

function menu_ctx.buttons()
	if not menu_ctx.open then return end

	if buttons.up or buttons.analogly < -60 then menu_ctx.scroll:up() end
	if buttons.down or buttons.analogly > 60 then menu_ctx.scroll:down() end

	if buttons.cancel then -- Run function of cancel option.
		menu_ctx.close = not menu_ctx.close
	end

	if buttons.accept then menu_ctx.options[menu_ctx.scroll.sel].funct() end

end
