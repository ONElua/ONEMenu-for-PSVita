--[[ 
    ONEMenu
    Application, themes and files manager.
    
    Licensed by Creative Commons Attribution-ShareAlike 4.0
    http://creativecommons.org/licenses/by-sa/4.0/
    
    Designed By Gdljjrod & DevDavisNunez.
    Collaborators: BaltazaR4 & Wzjk.
]]

--Functions Commons
Dev = 1
partitions = {"ux0:", "ur0:", "uma0:", "imc0:", "xmc0:", "ud0:", "gro0:", "grw0:", }--"photo0:", }--"music0:", "video0:", "savedata0:" }
Root,Root2 ={},{}

function Refresh_Partitions()
    Root,Root2 ={},{}
	for i=1,#partitions do
		if files.exists(partitions[i]) then
			local device_info = os.devinfo(partitions[i])
			if device_info then
				table.insert(Root,partitions[i])
				table.insert(Root2,partitions[i])
			end
		end
	end
end
Refresh_Partitions()

__TITTLEAPP, __IDAPP = "",""
vpkdel,_print,game_move = false,true,false            --for callbacks

function check_root()
    for i=1,#Root do
        if (Root[Dev]==partitions[i] or Root[Dev]==partitions[i].."/") then return true end
    end
    return false
end

function files.listsort(path)
    local tmp1 = files.listdirs(path)

    if tmp1 then
        table.sort(tmp1,function(a,b) return string.lower(a.name)<string.lower(b.name) end)
    else
        tmp1 = {}
    end

    local tmp2 = files.listfiles(path)

    if tmp2 then
        table.sort(tmp2,function(a,b) return string.lower(a.name)<string.lower(b.name) end)
        for s,t in pairs(tmp2) do
            t.sizenum = t.size
            t.size = files.sizeformat(t.size)
            table.insert(tmp1,t)-- esto es por que son subtablas, realmente no puedo hacer un cont con tmp2
        end
    end

    return tmp1

end

function shortcuts()
    if (buttons.held.l and buttons.held.r and buttons.left) and reboot then os.restart() end
    if (buttons.held.l and buttons.held.r and buttons.up) and reboot then power.restart() end
    if (buttons.held.l and buttons.held.r and buttons.right) and reboot then power.shutdown() end
end

--===============================   vpk      ==========================================================================
function show_scan(infovpk)
    bufftmp = screen.toimage()
    local x,y = (960-420)/2,(544-420)/2

    newpath,vpk=nil,nil
    local vpk = {scan = {}, len = 0 }

    reboot=false
    vpk.scan = files.scan(infovpk.path,1)

    if not vpk.scan then return end
    if not #vpk.scan or #vpk.scan<=0 then return end

    vpk.len = #vpk.scan
    reboot=true

    local realsize = files.sizeformat(vpk.scan.realsize or 0)
    while true do
        buttons.read()
        if bufftmp then bufftmp:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end

        draw.fillrect(x,y,420,420,color.new(0x2f,0x2f,0x2f,0xff))
        draw.framerect(x,y,420,420,color.black, color.shine,6)

        screen.print(960/2,y+35,infovpk.name,1,color.white,color.blue,__ACENTER)
        screen.print(960/2,y+85,STRINGS_VPK_TOTAL_SIZE..tostring(realsize),1,color.white,color.blue,__ACENTER)
        screen.print(960/2,y+115,STRINGS_COUNT..tostring(vpk.len),1,color.white,color.blue,__ACENTER)
        screen.flip()

        if buttons.accept or buttons.cancel then
            break
        end

    end
    os.delay(15)
    if bufftmp then bufftmp:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
end

function fillappmanlist(objin, info_sfo)

    if not objin.img then objin.img = theme.data["icodef"] end
    if objin.img then
        objin.img:reset()
        objin.img:resize(120,120)
        objin.img:setfilter(__IMG_FILTER_LINEAR, __IMG_FILTER_LINEAR)
    end

    --id, type, version, dev, path, title, sdk
    objin.id = info_sfo.TITLE_ID
    objin.type = info_sfo.CATEGORY
    objin.version = info_sfo.APP_VER or "00.00"
    objin.dev = "ux0"
    objin.path = string.format("ux0:app/%s",info_sfo.TITLE_ID)
    objin.title = info_sfo.TITLE or info_sfo.TITLE_ID
    objin.save = info_sfo.INSTALL_DIR_SAVEDATA or info_sfo.TITLE_ID
	objin.sdk = tonumber(info_sfo.PSP2_SYSTEM_VER or 0)
	objin.path_pic = "ur0:appmeta/"..info_sfo.TITLE_ID.."/pic0.png"

    local index = 1
    if objin.id == "PSPEMUCFW" then index = 3--index = 5 
    else

        if info_sfo.CONTENT_ID and info_sfo.CONTENT_ID:len() > 9  then
            index = 1
            objin.region = regions[info_sfo.CONTENT_ID[1]] or 5
        else

            --checking magic
            local fp = io.open(objin.path.."/data/boot.bin","r")
            if fp then
                local magic = str2int(fp:read(4))
                fp:close()
                if magic == 0x00424241 then index = 3 else index = 2 end
            else
                index = 2
            end
        end
    end
    objin.Nregion = name_region[objin.region] or ""

    --Search game in appman[index].list
    local search = 0
    for i=1,appman[index].scroll.maxim do
        if objin.id == appman[index].list[i].id then search = i break end
    end

    --No Exist!!!
	if search == 0 then
		table.insert(appman[index].list, objin)
		SortGeneric(appman[index].list, appman[index].sort, appman[index].asc)
		appman[index].scroll:set(appman[index].list,limit)
    else
        --Update
        appman[index].list[search].img = objin.img    --Icon New ??...Maybe
        appman[index].list[search].type = objin.type
        appman[index].list[search].version = objin.version
        appman[index].list[search].title = objin.title
		appman[index].list[search].sdk = objin.sdk
    end

end

function personalize_savedata(path)
    local fd = io.open(path, "r+");
    if fd then
        fd:seek("set", 0xe4);
        fd:write(os.getreg("/CONFIG/NP", "account_id", 3, 8));
        fd:close();
        return true;
    end
    return false;
end

function show_msg_vpk(obj_vpk)
    bufftmp = screen.buffertoimage()
    local x,y = (960-420)/2,(544-420)/2

    reboot=false
        local scan_vpk = files.scan(obj_vpk.path,1)
        if not scan_vpk then return end
        if not #scan_vpk or #scan_vpk<=0 then return end
    reboot=true

    local bin_pos,icon_pos,sfo_pos = -1,-1,-1
    local unsafe=0
    local dang,dangname=false,""

    for i=1,#scan_vpk do

        if scan_vpk[i].unsafe >= 1 then
            if scan_vpk[i].unsafe == 2 then
                dang = true
                dangname = scan_vpk[i].name:lower()
            else
                unsafe = 1
            end
        end

        local name = scan_vpk[i].name:lower()
        if name == "sce_sys/icon0.png" then icon_pos = scan_vpk[i].pos
            elseif name == "sce_sys/param.sfo" then sfo_pos = scan_vpk[i].pos
                elseif name == "eboot.bin" then bin_pos = scan_vpk[i].pos
        end

    end

    --Insert update appman[xx].list
    local tmp_vpk  = {}

    if icon_pos != -1 then
        tmp_vpk.img = game.geticon0(obj_vpk.path, icon_pos)
    else tmp_vpk.img = game.geticon0(obj_vpk.path) end

    if sfo_pos != -1 then
        scan_vpk.sfo = game.info(obj_vpk.path, sfo_pos)
    else scan_vpk.sfo = game.info(obj_vpk.path) end

    if bin_pos == -1 or sfo_pos == -1 then
        os.message(STRINGS_INSTALL_NOBIN) 
        return
    end

    local ccc = color.green
    if dang then ccc=color.red
    elseif unsafe == 1 then ccc=color.yellow end

    local res,xscr = false,290
    local version = ""
    if scan_vpk.sfo.APP_VER then version = "v"..scan_vpk.sfo.APP_VER end
    if scan_vpk.sfo.TITLE then scan_vpk.sfo.TITLE = scan_vpk.sfo.TITLE:gsub("\n"," ") end
    local realsize = files.sizeformat(scan_vpk.realsize or 0)

    local Xa = "O: "
    local Oa = "X: "
    if accept_x == 1 then Xa,Oa = "X: ","O: " end
    while true do
        buttons.read()
        if bufftmp then bufftmp:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end

        draw.fillrect(x,y,420,420,ccc)
        draw.framerect(x,y,420,420,color.black, ccc,6)

        if scan_vpk.sfo then
            if screen.textwidth(tostring(scan_vpk.sfo.TITLE) or "UNK") > 380 then
                xscr = screen.print(xscr, y+12, tostring(scan_vpk.sfo.TITLE) or "UNK",1,color.black,color.blue,__SLEFT,380)
            else
                screen.print(960/2,y+12,tostring(scan_vpk.sfo.TITLE) or "UNK",1,color.black,color.blue,__ACENTER)
            end
            if scan_vpk.sfo.CATEGORY == "gp" then
                screen.print(960/2,y+35,"UPDATE: "..version,1,color.black,color.blue,__ACENTER)
            else
                screen.print(960/2,y+35,version,1,color.black,color.blue,__ACENTER)
            end
            screen.print(960/2,y+60,tostring(scan_vpk.sfo.TITLE_ID),1,color.black,color.blue,__ACENTER)
        end
        screen.print(960/2,y+85,STRINGS_VPK_TOTAL_SIZE..tostring(realsize),1,color.black,color.blue,__ACENTER)

        if tmp_vpk.img then
            tmp_vpk.img:scale(150)
            tmp_vpk.img:setfilter(__IMG_FILTER_LINEAR, __IMG_FILTER_LINEAR)
            tmp_vpk.img:center()
            tmp_vpk.img:blit(960/2,544/2)
        end

        screen.print(960/2,y+315,STRINGS_VPK_INSTALL +" ?",1,color.black,color.blue,__ACENTER)
        if dang then
            screen.print(960/2,y+340,STRINGS_VPK_ALERT_DANGEROUS,1,color.black,color.blue,__ACENTER)
            screen.print(960/2,y+365,dangname,0.8,color.black,color.blue,__ACENTER)
        elseif unsafe == 1 then 
            screen.print(960/2,y+340,STRINGS_VPK_ALERT_UNSAFE,1,color.black,color.blue,__ACENTER)
        end

        screen.print(960/2,y+395,Xa..STRINGS_CONFIRM.." | "..Oa..STRINGS_SUBMENU_CANCEL,1,color.black,color.blue,__ACENTER)
        screen.flip()

        if buttons.accept or buttons.cancel then
            if buttons.accept then res = true end
            break
        end

    end
    os.delay(15)
    if bufftmp then bufftmp:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
    if res == false then return    end

    --Install
    reboot=false
        local result = game.install(obj_vpk.path, scan_vpk.realsize,false)
    reboot=true

    if result == 1 then
        reboot=false
            if os.message(STRINGS_SUBMENU_DELETE+"\n"+obj_vpk.path+" ? ",1)==1 then
                files.delete(obj_vpk.path)
                vpkdel=true
            end
        reboot=true

        --Restore Save from "ux0:data/ONEMenu/Saves
        if scan_vpk.sfo.INSTALL_DIR_SAVEDATA and files.exists("ux0:data/ONEMenu/SAVES/"..scan_vpk.sfo.INSTALL_DIR_SAVEDATA) then
            --game.umount()
            --    game.mount("ux0:user/00/savedata/"..scan_vpk.sfo.INSTALL_DIR_SAVEDATA)
                local info = files.info("ux0:data/ONEMenu/SAVES/"..scan_vpk.sfo.INSTALL_DIR_SAVEDATA)
                if os.message(STRINGS_APP_RESTORE_SAVE.."\n"..info.mtime or "", 1) == 1 then
                    files.copy("ux0:data/ONEMenu/SAVES/"..scan_vpk.sfo.INSTALL_DIR_SAVEDATA, "ux0:user/00/savedata/")
                    --personalize_savedata("ux0:user/00/savedata/"..scan_vpk.sfo.INSTALL_DIR_SAVEDATA.."/sce_sys/param.sfo")
                end
            --game.umount()    
        elseif files.exists("ux0:data/ONEMenu/SAVES/"..scan_vpk.sfo.TITLE_ID) then
            --game.umount()
                --game.mount("ux0:user/00/savedata/"..scan_vpk.sfo.TITLE_ID)
                local info = files.info("ux0:data/ONEMenu/SAVES/"..scan_vpk.sfo.TITLE_ID)
                if os.message(STRINGS_APP_RESTORE_SAVE.."\n"..info.mtime or "", 1) == 1 then
                    files.copy("ux0:data/ONEMenu/SAVES/"..scan_vpk.sfo.TITLE_ID, "ux0:user/00/savedata/")
                    --personalize_savedata("ux0:user/00/savedata/"..scan_vpk.sfo.TITLE_ID.."/sce_sys/param.sfo")
                end
            --game.umount()
        end

        if os.message(STRINGS_LAUNCH_GAME.."\n"..scan_vpk.sfo.TITLE+" ?",1) == 1 then
            if game.exists(scan_vpk.sfo.TITLE_ID) then
                if scan_vpk.sfo.CATEGORY == "ME" then game.open(scan_vpk.sfo.TITLE_ID) else game.launch(scan_vpk.sfo.TITLE_ID) end
            end
        end

        fillappmanlist(tmp_vpk, scan_vpk.sfo)
        appman.len +=1
        infodevices()

    else
        os.message(STRINGS_INSTALL_ERROR)
    end

    os.delay(15)
    if bufftmp then bufftmp:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
    --return res
end

--tmp0.CATEGORY: ISO/CSO UG, PSN EG, HBs MG, PS1 ME
function show_msg_pbp(handle)
    bufftmp = screen.toimage()
    local x,y = (960-420)/2,(544-420)/2

    local icon0 = game.geticon0(handle.path)
    local sfo = game.info(handle.path)

    local launch=false
    if sfo and (sfo.CATEGORY == "EG" or sfo.CATEGORY == "ME") then
        if sfo.DISC_ID and game.exists(sfo.DISC_ID) then
            launch=true
        end
    end

	local x1,x2 = string.find(handle.path:lower(), "pspemu", 1, true)
	if x1 == nil then
		if (sfo and sfo.CATEGORY == "ME") and game.exists("RETROVITA") then
			launch_Retrovita("RETROVITA",psx,handle)
		end
	end

    local name=handle.name:lower()
    --Maybe work with PS1
    local res,xscr = false,290
    local Xa = "O: "
    local Oa = "X: "
    if accept_x == 1 then Xa,Oa = "X: ","O: " end
    while true do
        buttons.read()
        if bufftmp then bufftmp:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end

        draw.fillrect(x,y,420,420,color.new(0x2f,0x2f,0x2f,0xff))
        draw.rect(x,y,420,420,color.white)

        if sfo then
            if launch then
                screen.print(960/2,y+15,STRINGS_LAUNCH_GAME,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
                screen.print(960/2,y+400,Xa..STRINGS_CONFIRM.." | "..Oa..STRINGS_SUBMENU_CANCEL.." | "..SYMBOL_TRIANGLE..": "..STRINGS_UNPACK,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
			else
				screen.print(960/2,y+400,SYMBOL_TRIANGLE..": "..STRINGS_UNPACK,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
            end

            if screen.textwidth(tostring(sfo.TITLE) or "UNK") > 380 then
                xscr = screen.print(xscr, y+40, tostring(sfo.TITLE) or "UNK",1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__SLEFT,380)
            else
                screen.print(960/2,y+40,tostring(sfo.TITLE) or "UNK",1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
            end
            screen.print(960/2,y+60,tostring(sfo.DISC_ID) or tostring(sfo.TITLE_ID),1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
            if sfo.CATEGORY then
                screen.print(960/2,y+80,tostring(sfo.CATEGORY) or "UNK",1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
            end
        end

        if icon0 then
            icon0:scale(150)
            icon0:setfilter(__IMG_FILTER_LINEAR, __IMG_FILTER_LINEAR)
            icon0:center()
            icon0:blit(960/2,544/2)
        end

        screen.flip()

        if buttons.cancel then break end

		--Extract Resources
		if buttons.triangle then
			if handle.ext == "pbp" then
				game.unpack(handle.path,files.nofile(handle.path))
			elseif handle.ext == "iso" or handle.ext == "cso" then
				image.save(icon0,files.nofile(handle.path).."/"..sfo.DISC_ID.."_icon0.png")
				local pic1 = game.getpic1(handle.path)
				if pic1 then
					image.save(pic1,files.nofile(handle.path).."/"..sfo.DISC_ID.."_pic1.png")
				end
			end
			explorer.refresh(true)
			os.delay(15)
			break
		end

        if buttons.accept and launch then
            if sfo.CATEGORY == "ME" then game.open(sfo.DISC_ID)
            else game.launch(sfo.DISC_ID) end
        end 

    end

    os.delay(15)
    if bufftmp then bufftmp:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
    return res
    
end

-- ## Video Player ##
function VideoPlayer(obj)
	local jump = -1
	local set_per,r_mode,loop = 0,1,0
	local res = video.init(obj.path)
	if res == 1 then
		local flag = false
		local crono_mp4 = timer.new()

		swipe.disableContV=false
		swipe.set(30, 640,20,300,504)
		while video.actived() do
			buttons.read()
				touch.read()
			swipe.read()

			if video.playing() then power.tick(__POWER_TICK_ALL) end

			if touch.front[1].released or buttons.triangle or buttons.select or buttons.released.l or buttons.released.r then
				flag = true
				crono_mp4:reset()
				crono_mp4:start()
			end
			if crono_mp4:time() >= 3500 then--3.5s
				flag = false
			end

			--Stop
			if buttons.cancel then video.stop() end

			--Play/Pause/Resume
			if buttons.accept then 
				if video.playing() then video.pause() else video.play()	end
			end

			--JumptoTime en segundos
			if buttons.released.l then jump = video.jump(-15) end
			if buttons.released.r then jump = video.jump(15) end

			--Change mode screen render
			local w = video.getrealw()
			local h = video.getrealh()

			if buttons.square then--and ( w<960 or h<544 ) then
				r_mode += 1
				if r_mode > 2 then r_mode = 1 end
			end

			local x,y = 0,0
			if r_mode == 1 then -- force all screen use
				x = 0
				y = 0
				w = 960
				h = 544
			elseif r_mode == 2 then -- original centered
				x = 480 - w/2
				y = 272 - h/2
			end

			--Looping
			if buttons.select then
				loop = video.looping()
				if loop then video.looping(0) else video.looping(1) end
			end

			--Vol+ Vol-
			if swipe.up then hw.volume(hw.volume()+1) elseif swipe.down then hw.volume(hw.volume()-1) end

			video.render(x,y,w,h)

			if flag or (video.percent() > 0 and not video.playing()) then
				os.infobar(1,0,1)
				screen.print(955,32, files.nopath(obj.path), 1, color.new(255, 255, 255), color.new(64, 64, 64), __ARIGHT)
				screen.print(20,520,tostring(video.time()).." / "..tostring(video.totaltime()).."  "..tostring(video.percent()) .. " %".." Vol "..tostring(hw.volume()), 1, color.new(255, 255, 255), color.new(64, 64, 64))
				if video.looping() then
					screen.print(255,520, "∞", 1, color.green, color.new(64, 64, 64))
				end
				draw.fillrect(0,540,math.map(video.percent(), 0, 100, 0, 960),5, color.new(0,0,255))
			else
				os.infobar()
			end
			if not video.playing() then screen.print(3,520, '||' , 1, color.new(255, 255, 255), color.new(64, 64, 64)) end--STRINGS_MUSIC_PAUSED

			screen.flip()

		end--while

		os.infobar()
		video.term()
	end
	swipe.set(30,255,70,695,430)
	swipe.disableContV=true
end

-- ## Music Player ##
function MusicPlayer(handle)

    local coverimg = image.load(__PATH_THEMES..__THEME.."/cover.png") or image.load("system/theme/default/cover.png")
    local musicimg = image.load(__PATH_THEMES..__THEME.."/music.png") or image.load("system/theme/default/music.png")

    local isMp3 = ((handle.ext or "") == "mp3")
    local id3 = nil

    if isMp3 then id3 = sound.getid3(handle.path) end

    local snd = sound.load(handle.path)
    local xscr2,xscr = 10,425
    if snd then
        snd:play(1)
        while true do
            buttons.read()
            if musicimg then musicimg:blit(0,0)    elseif theme.data["list"] then theme.data["list"]:blit(0,0) end

            if screen.textwidth(handle.name) > 860 then    xscr2 = screen.print(xscr2,10,handle.name,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__SLEFT,860) else
                screen.print(10,10,handle.name,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
            end

            if id3 and id3.cover then
                if id3.cover:getw() > 350 or id3.cover:geth() > 350 then
                    id3.cover:scale( math.floor( (350*100)/math.max(id3.cover:getw(), id3.cover:geth()) ) )
                end
                id3.cover:center()
                id3.cover:blit(175+35,175+100)
            else if coverimg then
                    coverimg:center()
                    coverimg:blit(175+35,175+100)
                end
            end

            if snd:playing() then
                screen.print(425,90,STRINGS_MUSIC_PLAYING,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
            else
                screen.print(425,90,STRINGS_MUSIC_PAUSED,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
            end

            if isMp3 then -- Solo los mp3 tienen tiempos :P

                local str = STRINGS_MUSIC_TIME..tostring(snd:time()).." / " 
                if id3 then
                    str += id3.time or STRINGS_MUSIC_ID3 
                else
                    str += STRINGS_MUSIC_ID3
                end
                screen.print(425,120, str,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)

                local perc = snd:percent() 
                if perc then
                    draw.fillrect(425,145,((perc*350)/100),10,color.green)
                end
                draw.rect(425,145,350,10,color.white)

                if id3 then
                    screen.clip(425, 170, 945-425,500-170)
                        
                        if screen.textwidth(id3.title or "") > 960-425 then
                            xscr = screen.print(xscr,175,id3.title or "",1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__SLEFT,960-425)
                        else
                            screen.print(425,175, id3.title or "",1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
                        end

                        if screen.textwidth(id3.album or "") > 960-425 then
                            xscr = screen.print(xscr,200,id3.album or "",1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__SLEFT,960-425)
                        else
                            screen.print(425,200, id3.album or "",1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
                        end
                        screen.print(425,225, id3.artist or "",1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
                        screen.print(425,250, id3.genre or "",1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)

                    screen.clip()
                end
            end

            if theme.data["buttons1"] then theme.data["buttons1"]:blitsprite(5,518,1) end--triangle
            screen.print(30,520,STRINGS_MUSIC_LOCK_DISPLAY,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)

            screen.flip()

            power.tick(__POWER_TICK_ALL) -- reset a power timers only for block suspend..

            if buttons.accept then
                snd:pause() -- pause/resume
            end

            if buttons.cancel or snd:endstream() then break end
            if buttons.triangle then power.display(0) end -- Lock or Down the screen.
        end

        snd:stop()
        snd,coverimg,musicimg = nil,nil,nil
        collectgarbage("collect")
        os.delay(250)
    else
        os.message(STRINGS_MUSIC_ERROR)
    end
end

-- ## Photo-Viewer ## --
function visorimg(path)
    local tmp = image.load(path)
    if tmp then
        tmp:center()

        local infoimg = {}
        infoimg.name = files.nopath(path)
        infoimg.w,infoimg.h = image.getrealw(tmp),image.getrealh(tmp)
        local show_bar_upper = true

        bar=45
        if (infoimg.w>500 and infoimg.h>300) then bar=50 end 

        for i=0,bar,5 do
            tmp:blit(__DISPLAYW/2,__DISPLAYH/2)
            draw.fillrect(0,0,__DISPLAYW,i,theme.style.BARCOLOR)
            --screen.flip()
        end

        local changeimg,angle = false,0
        while true do
            if theme.data["list"] then theme.data["list"]:blit(0,0) end
            buttons.read()
    
            tmp:blit(__DISPLAYW/2,__DISPLAYH/2)

            if show_bar_upper then
                draw.fillrect(0,0,__DISPLAYW,bar,theme.style.BARCOLOR)

                screen.print(10,5,infoimg.name,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
                screen.print(940,3,"w: "..infoimg.w,0.8,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ARIGHT)
                screen.print(940,24,"h: "..infoimg.h,0.8,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ARIGHT)
                --if (infoimg.w>800 and infoimg.h>500) then
                    --screen.print(10,30,STRINGS_BACKGROUND_IMG,0.7,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
                --end
				screen.print(10,30,STRINGS_EXPORT_IMAGE,0.8,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
            end

            screen.flip()

			if buttons.r or buttons.l then
				if buttons.r then angle+=90 elseif buttons.l then angle-=90 end
				if angle > 360 then angle = 90 end
				if angle < 0 then angle = 270 end
				tmp:rotate(angle)
            end
            
            if buttons.square then show_bar_upper = not show_bar_upper end

            if buttons.cancel or buttons.accept then break end

            if buttons.triangle then
				if theme.data["list"] then theme.data["list"]:blit(0,0) end
				screen.flip()
                image.review(path)
				--[[
				if (infoimg.w>800 and infoimg.h>500) then
                    theme.data["back"] = tmp
                    __BACKG = path
                    write_config()
                    changeimg = true
                    os.message(STRINGS_THEMES_INSTALL_DONE,0)
                end
				]]
            end

        end

        barblit=false
		--[[
        if changeimg then
            theme.data["back"]:reset()
            theme.data["back"]:resize(__DISPLAYW, __DISPLAYH)
        end
		]]
    else
        os.message(STRINGS_ERROR_PREVIEW_IMG)
    end
    screen.clear(color.black)
end

-- ## File-Viewer ## --
function write_txt(pathini, tb)
    local file = io.open(pathini, "w+")
    for s,t in pairs(tb) do
        file:write(string.format('%s\n', tostring(t)))
    end
    file:close()
end

function files.readlinesSFO(path)
    local sfo = game.info(path)
    if not sfo then return nil end

    if sfo.TITLE then sfo.TITLE = sfo.TITLE:gsub("\n"," ") end
    if sfo.STITLE then sfo.STITLE = sfo.STITLE:gsub("\n"," ") end

    local data = {}
    for k,v in pairs(sfo) do
        if __EDITB then
            if tostring(k) == "STITLE" or tostring(k) == "TITLE" then
                table.insert(data,tostring(k).." = "..tostring(v))
            end
        else
            table.insert(data,tostring(k).." = "..tostring(v))
        end
    end
    return data
end

function files.readlines(path,index) -- Lee una table o string si se especifica linea
    if files.exists(path) then
        local contenido,cont_lines = {},0
        for line in io.lines(path) do

            cont_lines += 1
            if cont_lines > 9999 then os.message(STRINGS_EDIT_TOO_LARGE) return nil end

            if line:byte(#line) == 13 then line = line:sub(1,#line-1) end --Remove CR == 13
            line=line:gsub("    ","    ")
            table.insert(contenido,line)
            
        end

        if index == nil then return contenido
        else return contenido[index] end
    end
end

function visortxt(handle, flag_edit)

    local texteditorInfo = {
        list = {},
        focus = 1,
        top = 1,
    }

    texteditorInfo.list = {}
    if handle.ext == "sfo" then texteditorInfo.list = files.readlinesSFO(handle.path)
    else texteditorInfo.list = files.readlines(handle.path) end

    local sfo_empty = false

    if texteditorInfo.list == nil then return false end

    if #texteditorInfo.list == 0 then
        table.insert(texteditorInfo.list, "")
        if handle.ext == "sfo" then sfo_empty=true end
    end

    if handle.ext == "sfo" then table.sort(texteditorInfo.list) end

    if #texteditorInfo.list > 9999 then os.message(STRINGS_EDIT_TOO_LARGE) return false end

	local xscr2 = 10
	local texteditorOrdinal_x = 15
    local texteditorOrdinalWidth = texteditorOrdinal_x + screen.textwidth("0000") + texteditorOrdinal_x
    local texteditorDefaultText_x = texteditorOrdinalWidth
    local texteditorText_x = texteditorDefaultText_x
    local texteditorTextDefaultWidth = 960 - texteditorOrdinalWidth - texteditorOrdinal_x
    local texteditorTextWidth = texteditorTextDefaultWidth
    local textHadChange, hold, changes, limit = false,false,{},16

    local editorimg = image.load(__PATH_THEMES..__THEME.."/editor.png") or image.load("system/theme/default/editor.png")

    buttons.analogtodpad(60)
    buttons.interval(16,5)
	
	if __USERFNT then font.setdefault(fnt) else font.setdefault(__FONT_TYPE_PGF) end
    while true do
        buttons.read()
        if editorimg then editorimg:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end

        if screen.textwidth(handle.path) > 880 then
			xscr2 = screen.print(xscr2,10,handle.path,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__SLEFT,880)
		else screen.print(10,10,handle.path,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR) end

        local list_y = 70
        if texteditorInfo.list and #texteditorInfo.list > 0 then
            local listShowCount = limit

            if texteditorInfo.top > texteditorInfo.focus then
                texteditorInfo.top = texteditorInfo.focus
            elseif texteditorInfo.top < texteditorInfo.focus - (listShowCount - 1) then
                texteditorInfo.top = texteditorInfo.focus - (listShowCount - 1)
            end

            local bottom = #texteditorInfo.list
            if bottom > texteditorInfo.top + (listShowCount - 1) then
                bottom = texteditorInfo.top + (listShowCount - 1)
            end

            for i = texteditorInfo.top, bottom do

                local tmpTextWidth = screen.textwidth(texteditorInfo.list[i])
                if tmpTextWidth > texteditorTextWidth then
                    texteditorTextWidth = tmpTextWidth
                end

                if i == texteditorInfo.focus then
                    if hold then ccc=color.green:a(80) else ccc=theme.style.SELCOLOR end
                    draw.fillrect(3,list_y-3,__DISPLAYW-16,22,ccc)
                end

                screen.print(7, list_y, string.format("%04d", i), 1, color.white, color.black, __ALEFT)--0xFF666666

                screen.clip(texteditorOrdinalWidth,0,texteditorTextDefaultWidth,544)
                screen.print(texteditorText_x, list_y, texteditorInfo.list[i], 1, color.white, color.black, __ALEFT)
                screen.clip()

                list_y += 26
            end

            ---- Draw Scroll Bar
            local ybar,hbar = 70, (limit*26)-2
            draw.fillrect(950,ybar-2,8,hbar,color.shine)
            if #texteditorInfo.list > limit then -- Draw Scroll Bar
                local pos_height = math.max(hbar/#texteditorInfo.list, limit)
                --Bar Scroll
                draw.fillrect(950, ybar-2 + ((hbar-pos_height)/(#texteditorInfo.list-1))*(texteditorInfo.focus-1), 8, pos_height, color.new(0,255,0))
            end

            if __EDITB then
                screen.print(480, 425, STRINGS_STITLE_MGE, 1, color.white, color.black, __ACENTER)
                screen.print(480, 450, STRINGS_TITLE_MGE, 1, color.white, color.black, __ACENTER)
            end

        end--if list > 0 the

        if flag_edit and handle.ext != "sfo" then
            local text_line = string.format(STRINGS_EDIT_INSERT_LINE)
            local tempx = screen.textwidth(text_line,1) + 60

            if theme.data["buttons1"] then theme.data["buttons1"]:blitsprite(5,518,1) end--triangle
            screen.print(25,520,text_line,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)

            if theme.data["buttons1"] then theme.data["buttons1"]:blitsprite(tempx,518,1) end
            screen.print(tempx+20,520,STRINGS_EDIT_DELETE_LINE,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
        end

        screen.flip()

        if not hold then
            buttons.analogtodpad(60)
            buttons.interval(16,5)

            if buttons.up or buttons.analogly < -60 then
                if texteditorInfo.list and #texteditorInfo.list > 0 then
                    if texteditorInfo.focus > 1 then texteditorInfo.focus -= 1 end
                end
            end

            if buttons.down or buttons.analogly > 60 then
                if texteditorInfo.list and #texteditorInfo.list > 0 then
                    if texteditorInfo.focus < #texteditorInfo.list then texteditorInfo.focus += 1 end
                end
            end

            if buttons.left or buttons.analoglx < -60 then
                if texteditorText_x < texteditorDefaultText_x then texteditorText_x += 10 end  
            end

            if buttons.right or buttons.analoglx > 60 then
                if texteditorDefaultText_x - texteditorText_x + texteditorTextDefaultWidth < texteditorTextWidth then texteditorText_x -= 10 end
            end

            if buttons.l then
                local tmpTop = texteditorInfo.top - limit
                if tmpTop < 1 then tmpTop = 1 end
                if texteditorInfo.top ~= tmpTop then
                    texteditorInfo.focus = tmpTop + (texteditorInfo.focus - texteditorInfo.top)
                    texteditorInfo.top = tmpTop
                end
            end

            if buttons.r then
                local tmpTop = texteditorInfo.top + limit
                if tmpTop <= #texteditorInfo.list then
                    if tmpTop > #texteditorInfo.list - (limit - 1) then tmpTop = #texteditorInfo.list - (limit - 1) end
                    texteditorInfo.focus = tmpTop + (texteditorInfo.focus - texteditorInfo.top)
                    if texteditorInfo.focus > #texteditorInfo.list then texteditorInfo.focus = #texteditorInfo.list end
                    texteditorInfo.top = tmpTop
                end
            end

        else
            buttons.analogtodpad()
        end

        if buttons.cancel then

			if __USERFNT then font.setdefault(fnt) else font.setdefault(__FONT_TYPE_PVF) end

            local _flag = false
            if textHadChange then
                if os.message(STRINGS_EDIT_SAVE_CHANGES,1) == 1 then

                    if handle.ext == "sfo" then
                        -- To save changes if wish!
                        for k,v in pairs(changes) do

                            if __EDITB then
                                if v.field == "STITLE" then game.setsfo(handle.path, "STITLE_"..langs[os.language()], string.sub(__STITLE,1,51))
                                elseif v.field == "TITLE" then game.setsfo(handle.path, "TITLE_"..langs[os.language()], string.sub(__TITLE,1,127)) end
								game.setsfo(handle.path, k, tostring(v.string))
							end

                        end
                        _flag = true
                    else
                        write_txt(handle.path, texteditorInfo.list)
                    end

                    --Update file (info)
                    local info = files.info(handle.path)
                    if info then
                        if handle.size then    handle.size = files.sizeformat(info.size or 0) end
                        if handle.mtime then handle.mtime = info.mtime end
                    end
                    infodevices()
                end
            end

            if _flag then return true else return false end
            break
        end

        if buttons.accept and flag_edit then
            if handle.ext == "sfo" and not sfo_empty then
                local numeric = false
                if texteditorInfo.list[texteditorInfo.focus]:find("= 0x",1) then numeric = true end

                field,value=texteditorInfo.list[texteditorInfo.focus]:match("(.+) = (.+)")

                if field then
                    local name_field = field:upper()

                    if __EDITB then
                        local newStr = osk.init(field, value, 512)
                        if newStr then
                            if value != newStr then

                                textHadChange = true

                                if name_field == "STITLE" then __STITLE = newStr
                                    elseif name_field == "TITLE" then __TITLE = newStr
                                end

                                changes[texteditorInfo.focus] = {}
                                if not changes[field] then changes[field] = {} end

                                --Update line & set changes to late save!
                                changes[field].field = tostring(field:upper())
                                changes[field].string = ""
                                texteditorInfo.list[texteditorInfo.focus] = string.format("%s = %s", field, newStr)
                                changes[field].string = newStr
                            end
						end--newStr
					end--__EDITB

				end--field

            else
                local editStr = texteditorInfo.list[texteditorInfo.focus]
                local newStr = osk.init(STRINGS_EDIT_LINE, editStr, 512, __OSK_TYPE_DEFAULT, __OSK_MODE_TEXT)
                if newStr and newStr ~= editStr then
                    texteditorInfo.list[texteditorInfo.focus] = newStr
                    textHadChange = true
                end
            end
        end

        if buttons.released.triangle then hold = false end

        if buttons.held.triangle and handle.ext != "sfo" then
            hold = true

            if buttons.right and flag_edit then--add line
                table.insert(texteditorInfo.list, texteditorInfo.focus + 1, "")
                textHadChange = true
            end
            
            if buttons.left and flag_edit then--remove line
                table.remove(texteditorInfo.list, texteditorInfo.focus)  
                if #texteditorInfo.list < 1 then
                    table.insert(texteditorInfo.list, "")
                elseif texteditorInfo.focus > #texteditorInfo.list then
                    texteditorInfo.focus = #texteditorInfo.list
                end
                textHadChange = true
            end

        end

    end
end

function startftp()

    local init = false
    if not wlan.isconnected() then wlan.connect() end
    if wlan.isconnected() then init=ftp.init() end

    if not init then return false end

    local ftpimg = image.load(__PATH_THEMES..__THEME.."/ftp.png") or image.load("system/theme/default/ftp.png")

    while ftp.state() do
        reboot=false
        power.tick()
        buttons.read()
        if ftpimg then ftpimg:blit(0,0) end
        screen.print(960/2,300,STRINGS_FTP_TEXT,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
        screen.print(327,333,"FTP://"+tostring(wlan.getip())..":1337",1,theme.style.FTPCOLOR,color.black)
        screen.print(960/2,375,STRINGS_FTP_CLOSE,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
        screen.flip()

        if buttons.start then
            if ftpimg then ftpimg:blit(0,0) end
            screen.print(960/2,300,STRINGS_FTP_TEXT,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
            screen.print(327,333,"FTP://"+tostring(wlan.getip())..":1337",1,theme.style.FTPCOLOR,color.black)
            screen.print(960/2,375,STRINGS_FTP_LOSE,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
            screen.flip()
            ftp.term()
            os.delay(100)
        end
    end

    reboot=true
    ftpimg=nil
    os.delay(100)
    return true
end

function usbMassStorage()

    if not usb then os.requireusb() end

    while usb.actived() != 1 do
        buttons.read()
        --power.tick(__POWER_TICK_SUSPEND)
		power.tick(__POWER_TICK_ALL)

        if theme.data["list"] then theme.data["list"]:blit(0,0) end 

        local titlew = string.format(STRINGS_USB_CABLE)
        local w,h = screen.textwidth(titlew,1) + 30,70
        local x,y = 480 - (w/2), 272 - (h/2)

        draw.fillrect(x, y, w, h, theme.style.BARCOLOR)
        draw.rect(x, y, w, h,color.white)
            screen.print(480,y+13, titlew,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
            screen.print(480,y+40, textXO..STRINGS_USB_CANCEL,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
        screen.flip()

        if buttons.cancel then return false end
    end

    --[[
        // 0:    USBDEVICE_MODE_MEMORY_CARD
        // 1:    USBDEVICE_MODE_GAME_CARD
        // 2:    USBDEVICE_MODE_SD2VITA
        // 3:    USBDEVICE_MODE_PSVSD
        "ux0:","ur0:","uma0:","gro0:","grw0:"
    ]]
    local mode_usb = -1
    local title = string.format(STRINGS_USB_MODE)
    local w,h = screen.textwidth(title,1) + 120,145
    local x,y = 480 - (w/2), 272 - (h/2)

    while true do
        buttons.read()
        power.tick(__POWER_TICK_ALL)
        if theme.data["list"] then theme.data["list"]:blit(0,0) end 

        draw.fillrect(x, y, w, h, theme.style.BARCOLOR)
        draw.rect(x,y,w,h,color.white)
            screen.print(480, y+10, title,1,color.white,color.black, __ACENTER)
            screen.print(480,y+40,SYMBOL_CROSS.." "..STRINGS_USB_SD2VITA, 1,color.white,color.black, __ACENTER)
            screen.print(480,y+65,SYMBOL_SQUARE.." "..STRINGS_USB_MEMORYCARD, 1,color.white,color.black, __ACENTER)
            screen.print(480,y+90,SYMBOL_TRIANGLE.." "..STRINGS_USB_GAMECARD, 1,color.white,color.black, __ACENTER)
            screen.print(480,y+115,SYMBOL_CIRCLE.." "..STRINGS_SUBMENU_CANCEL, 1,color.white,color.black, __ACENTER)
        screen.flip()

        if buttons.accept or buttons.square or buttons.triangle or buttons.cancel then
            if buttons.accept then mode_usb = 2
            elseif buttons.square then mode_usb = 0
            elseif buttons.triangle then mode_usb = 1
            else return false end
            break
        end
    end--while
    buttons.read()

    buttons.homepopup(0)
    local conexion = usb.start(mode_usb)
    if conexion == -1 then
        buttons.homepopup(1)
        os.message(STRINGS_USB_ERROR,0)
        return false
    end

    local titlew = string.format(STRINGS_USB_CONNECTION)
    local w,h = screen.textwidth(titlew,1) + 30,70
    local x,y = 480 - (w/2), 272 - (h/2)
    while not buttons.cancel do
        buttons.read()
        power.tick(__POWER_TICK_ALL)
		--info bar
		os.infobar(1)
        if theme.data["list"] then theme.data["list"]:blit(0,0) end 

        draw.fillrect(x,y,w,h,theme.style.BARCOLOR)
        draw.rect(x,y,w,h,color.white)
            screen.print(480,y+13, STRINGS_USB_CONNECTION,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
            screen.print(480,y+40, textXO..STRINGS_USB_CANCEL,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
        screen.flip()
    end

    usb.stop()
	os.infobar()
    buttons.read()
    buttons.homepopup(1)

    explorer.refresh(true)
    explorer.action = 0
    multi={}
    return true
end
