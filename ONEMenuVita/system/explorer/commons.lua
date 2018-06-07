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
local partitions = {"ux0:", "ur0:", "uma0:", "imc0:", "ud0:", "gro0:", "grw0:" }
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

__TITTLEAPP, __IDAPP = "",""
vpkdel,_print,game_move = false,true,false			--for callbacks

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
	if (buttons.held.l and buttons.held.r and buttons.up) and reboot then os.restart() end
	if (buttons.held.l and buttons.held.r and buttons.down) and reboot then power.restart() end
	if (buttons.held.l and buttons.held.r and buttons.square) and reboot then power.shutdown() end
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
		screen.print(960/2,y+85,strings.total_sizevpk..tostring(realsize),1,color.white,color.blue,__ACENTER)
		screen.print(960/2,y+115,strings.count..tostring(vpk.len),1,color.white,color.blue,__ACENTER)
		screen.flip()

		if buttons[accept] or buttons[cancel] then
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

	--id, type, version, dev, path, title
	objin.id = info_sfo.TITLE_ID
	objin.type = info_sfo.CATEGORY
	objin.version = info_sfo.APP_VER or "00.00"
	objin.dev = "ux0"
	objin.path = string.format("ux0:app/%s",info_sfo.TITLE_ID)
	objin.title = info_sfo.TITLE or info_sfo.TITLE_ID

	local index = 1
	if files.exists(objin.path.."/data/boot.inf") or objin.id == "PSPEMUCFW" then index = 5
	else
		if info_sfo.CONTENT_ID and info_sfo.CONTENT_ID:len() > 9 then index = 1 else index = 2 end
		objin.region = regions[info_sfo.CONTENT_ID[1]] or 5
	end
	objin.Nregion = name_region[objin.region] or ""

	--Search game in appman[index].list
	local search = 0
	for i=1,appman[index].scroll.maxim do
		if objin.id == appman[index].list[i].id then search = i break end
	end

	--No Exist!!!
	if search == 0 then
		if __FAV == 0 then
			objin.fav = false
			table.insert(appman[index].list, objin)

			if index == 1 and appman[index].sort == 3 then
				table.sort(appman[index].list, tableSortReg)
			else
				if appman[index].sort == 0 then
					if appman[index].asc == 1 then
						table.sort(appman[index].list ,function (a,b) return string.lower(a.id)<string.lower(b.id) end)
					else
						table.sort(appman[index].list ,function (a,b) return string.lower(a.id)>string.lower(b.id) end)
					end
				else
					if appman[index].asc == 1 then
						table.sort(appman[index].list ,function (a,b) return string.lower(a.title)<string.lower(b.title) end)
					else
						table.sort(appman[index].list ,function (a,b) return string.lower(a.title)>string.lower(b.title) end)
					end
				end
			end

			appman[index].scroll:set(appman[index].list,limit)
		end
	else
		--Update
		appman[index].list[search].img = objin.img	--Icon New ??...Maybe
		appman[index].list[search].type = objin.type
		appman[index].list[search].version = objin.version
		appman[index].list[search].title = objin.title
	end

end

function show_msg_vpk(obj_vpk)
	bufftmp = screen.toimage()
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

	if bin_pos == -1 or sfo_pos == -1 then return end

	local ccc = color.green
	if dang then ccc=color.red
	elseif unsafe == 1 then ccc=color.yellow end

	local res,xscr = false,290
	local version = ""
	if scan_vpk.sfo.APP_VER then version = "v"..scan_vpk.sfo.APP_VER end
	if scan_vpk.sfo.TITLE then scan_vpk.sfo.TITLE = scan_vpk.sfo.TITLE:gsub("\n"," ") end
	local realsize = files.sizeformat(scan_vpk.realsize or 0)

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
		screen.print(960/2,y+85,strings.total_sizevpk..tostring(realsize),1,color.black,color.blue,__ACENTER)

		if tmp_vpk.img then
			tmp_vpk.img:scale(150)
			tmp_vpk.img:setfilter(__IMG_FILTER_LINEAR, __IMG_FILTER_LINEAR)
			tmp_vpk.img:center()
			tmp_vpk.img:blit(960/2,544/2)
		end

		screen.print(960/2,y+315,strings.installvpk +" ?",1,color.black,color.blue,__ACENTER)
		if dang then
			screen.print(960/2,y+340,strings.alertdang,1,color.black,color.blue,__ACENTER)
			screen.print(960/2,y+365,dangname,0.8,color.black,color.blue,__ACENTER)
		elseif unsafe == 1 then 
			screen.print(960/2,y+340,strings.alertunsafe,1,color.black,color.blue,__ACENTER)
		end

		if accept_x == 1 then
			screen.print(960/2,y+395,string.format("%s "..strings.confirm.." | %s "..strings.cancel,SYMBOL_CROSS, SYMBOL_CIRCLE),1,color.black,color.blue,__ACENTER)
		else
			screen.print(960/2,y+395,string.format("%s "..strings.confirm.." | %s "..strings.cancel,SYMBOL_CIRCLE, SYMBOL_CROSS),1,color.black,color.blue,__ACENTER)
		end
		screen.flip()

		if buttons[accept] or buttons[cancel] then
			if buttons[accept] then res = true end
			break
		end

	end
	os.delay(15)
	if bufftmp then bufftmp:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
	if res == false then return	end

	--Install
	reboot=false
		local result = game.install(obj_vpk.path, scan_vpk.realsize,false)
	reboot=true

	if result == 1 then
		reboot=false
			if os.message(strings.delete+"\n\n"+obj_vpk.path+" ? ",1)==1 then
				files.delete(obj_vpk.path)
				vpkdel=true
			end
		reboot=true

		--Restore Save from "ux0:data/ONEMenu/Saves
		if files.exists("ux0:data/ONEMenu/SAVES/"..scan_vpk.sfo.TITLE_ID) then
			local info = files.info("ux0:data/ONEMenu/SAVES/"..scan_vpk.sfo.TITLE_ID)
			if os.message(strings.restoresave.."\n\n"..info.mtime or "", 1) == 1 then
				files.copy("ux0:data/ONEMenu/SAVES/"..scan_vpk.sfo.TITLE_ID, "ux0:user/00/savedata/")
			end
		end

		if os.message(strings.launchpbp.."\n\n"..scan_vpk.sfo.TITLE+" ?",1) == 1 then
			if game.exists(scan_vpk.sfo.TITLE_ID) then
				if scan_vpk.sfo.CATEGORY == "ME" then game.open(scan_vpk.sfo.TITLE_ID) else game.launch(scan_vpk.sfo.TITLE_ID) end
			end
		end

		fillappmanlist(tmp_vpk, scan_vpk.sfo)
		appman.len +=1
		infodevices()

	else
		os.message(strings.errorinstall)
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

	local name=handle.name:lower()
	--Maybe work with PS1
	local res,xscr = false,290
	while true do
		buttons.read()
		if bufftmp then bufftmp:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end

		draw.fillrect(x,y,420,420,color.new(0x2f,0x2f,0x2f,0xff))
		draw.rect(x,y,420,420,color.white)

		if sfo then
			if launch then
				screen.print(960/2,y+15,strings.launchpbp,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
	
				if accept_x == 1 then
					screen.print(960/2,y+400,string.format("%s "..strings.confirm.." | %s "..strings.cancel,SYMBOL_CROSS, SYMBOL_CIRCLE),1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
				else
					screen.print(960/2,y+400,string.format("%s "..strings.confirm.." | %s "..strings.cancel,SYMBOL_CIRCLE, SYMBOL_CROSS),1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
				end
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

		if buttons[cancel] then break end

		if buttons[accept] and launch then
			if sfo.CATEGORY == "ME" then game.open(sfo.DISC_ID)
			else game.launch(sfo.DISC_ID) end
		end 

	end

	os.delay(15)
	if bufftmp then bufftmp:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
	return res
	
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
			if musicimg then musicimg:blit(0,0)	elseif theme.data["list"] then theme.data["list"]:blit(0,0) end

			if screen.textwidth(handle.name) > 860 then	xscr2 = screen.print(xscr2,10,handle.name,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__SLEFT,860) else
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
				screen.print(425,90,strings.playing,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
			else
				screen.print(425,90,strings.paused,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
			end

			if isMp3 then -- Solo los mp3 tienen tiempos :P

				local str = strings.time..tostring(snd:time()).." / " 
				if id3 then
					str += id3.time or strings.id3 
				else
					str += strings.id3
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
			screen.print(30,520,strings.display,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)

			screen.flip()

			power.tick(__POWER_TICK_SUSPEND) -- reset a power timers only for block suspend..

			if buttons[accept] then
				--[[if snd:endstream() then
					snd:play()
				else]]
				snd:pause() -- pause/resume
				--end
			end

			if buttons[cancel] or snd:endstream() then break end
			if buttons.triangle then power.display(0) end -- Lock or Down the screen.
		end

		snd:stop()
		snd,coverimg,musicimg = nil,nil,nil
		collectgarbage("collect")
		os.delay(250)
	else
		os.message(strings.sounderror)
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
			if theme.data["back"] then theme.data["back"]:blit(0,0) end
			buttons.read()
	
			tmp:blit(__DISPLAYW/2,__DISPLAYH/2)

			if show_bar_upper then
				draw.fillrect(0,0,__DISPLAYW,bar,theme.style.BARCOLOR)

				screen.print(10,5,infoimg.name,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
				screen.print(940,3,"w: "..infoimg.w,0.8,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ARIGHT)
				screen.print(940,24,"h: "..infoimg.h,0.8,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ARIGHT)
				if (infoimg.w>800 and infoimg.h>500) then
					screen.print(10,30,strings.background,0.7,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
				end
			end

			screen.flip()

			if buttons.r or buttons.l then
				if buttons.r then angle+=90 elseif buttons.l then angle-=90 end
				 if angle > 360 then angle = 90 end
				 if angle < 0 then angle = 270 end
				tmp:rotate(angle)
			end
			
			if buttons.square then show_bar_upper = not show_bar_upper end

			if buttons[cancel] or buttons[accept] then break end

			if buttons.triangle then
				if (infoimg.w>800 and infoimg.h>500) then
					theme.data["back"] = tmp
					__BACKG = path
					write_config()
					changeimg = true
					os.message(strings.themesdone,0)
				end
			end

		end

		barblit=false
		if changeimg then
			theme.data["back"]:reset()
			theme.data["back"]:resize(__DISPLAYW, __DISPLAYH)
		end
	else
		os.message(strings.imgerror)
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
			if cont_lines > 9999 then os.message(strings.toolarge) return nil end

			if line:byte(#line) == 13 then line = line:sub(1,#line-1) end --Remove CR == 13
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

	if #texteditorInfo.list > 9999 then os.message(strings.toolarge) return false end

	local texteditorOrdinal_x = 10
	if __FNT == 3 then texteditorOrdinal_x = 15 end

	local texteditorOrdinalWidth = texteditorOrdinal_x + screen.textwidth("0000") + texteditorOrdinal_x
	local texteditorDefaultText_x = texteditorOrdinalWidth
	local texteditorText_x = texteditorDefaultText_x
	local texteditorTextDefaultWidth = 960 - texteditorOrdinalWidth - 15
	local texteditorTextWidth = texteditorTextDefaultWidth
	local textHadChange, hold, changes, limit = false,false,{},16

	local editorimg = image.load(__PATH_THEMES..__THEME.."/editor.png") or image.load("system/theme/default/editor.png")

	buttons.analogtodpad(60)
	buttons.interval(16,5)
	while true do
		buttons.read()
		if editorimg then editorimg:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end

		if screen.textwidth(handle.path) > 860 then	xscr2 = screen.print(xscr2,10,handle.path,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__SLEFT,860) else
			screen.print(10,10,handle.path,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
		end

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

				screen.print(texteditorOrdinal_x, list_y, string.format("%04d", i), 1, color.white, color.black, __ALEFT)--0xFF666666

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
				screen.print(480, 425, strings.simplestitle, 1, color.white, color.black, __ACENTER)
				screen.print(480, 450, strings.simpletitle, 1, color.white, color.black, __ACENTER)
			end

		end--if list > 0 the

		if flag_edit and handle.ext != "sfo" then
			local text_line = string.format(strings.insertline)
			local tempx = screen.textwidth(text_line,1) + 60

			if theme.data["buttons1"] then theme.data["buttons1"]:blitsprite(5,518,1) end--triangle
			screen.print(25,520,text_line,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)

			if theme.data["buttons1"] then theme.data["buttons1"]:blitsprite(tempx,518,1) end
			screen.print(tempx+20,520,strings.deleteline,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
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
				if texteditorDefaultText_x	- texteditorText_x + texteditorTextDefaultWidth < texteditorTextWidth then texteditorText_x -= 10 end
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

		if buttons[cancel] then
			local _flag = false
			if textHadChange then
				if os.message(strings.savechanges,1) == 1 then

					if handle.ext == "sfo" then
						-- To save changes if wish!
						for k,v in pairs(changes) do

							if __EDITB then
								if v.field == "STITLE" then game.setsfo(handle.path, "STITLE_"..langs[os.language()], __STITLE)
								elseif v.field == "TITLE" then game.setsfo(handle.path, "TITLE_"..langs[os.language()], __TITLE) end
								game.setsfo(handle.path, k, tostring(v.string))
							else
								if v.number then
									game.setsfo(handle.path, k, v.number)
								elseif v.string then
									game.setsfo(handle.path, k, tostring(v.string))
								end
							end

						end
						_flag = true
					else
						write_txt(handle.path, texteditorInfo.list)
					end

					--Update file (info)
					local info = files.info(handle.path)
					if info then
						if handle.size then	handle.size = files.sizeformat(info.size or 0) end
						if handle.mtime then handle.mtime = info.mtime end
					end
					infodevices()
				end
			end
			if _flag then return true else return false end
			break
		end

		if buttons[accept] and flag_edit then
			if handle.ext == "sfo" and not sfo_empty then
				local numeric = false
				if texteditorInfo.list[texteditorInfo.focus]:find("= 0x",1) then numeric = true end

				field,value=texteditorInfo.list[texteditorInfo.focus]:match("(.+) = (.+)")

				if field then
					local name_field = field:upper()

					if __EDITB then
						local newStr = nil
						if numeric then
							if value then value=tonumber(value:gsub("0x", ""),16) end			--Hex-Dec
							newStr = osk.init(field, value, 10, __OSK_TYPE_NUMBER, __OSK_MODE_TEXT)
						else
							newStr = osk.init(field, value, 512, __OSK_TYPE_DEFAULT, __OSK_MODE_TEXT)
						end

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
								if numeric then
									texteditorInfo.list[texteditorInfo.focus] = string.format("%s = 0x%X", field, tonumber(newStr))
									changes[field].number = tonumber(newStr)
										
								else
									changes[field].string = ""
									texteditorInfo.list[texteditorInfo.focus] = string.format("%s = %s", field, newStr)
									changes[field].string = newStr
								end
							end
						end--newStr
					else

						if name_field == "APP_VER" or name_field == "VERSION" or
							name_field == "PSP2_DISP_VER" or name_field == "TITLE_ID" then os.message(strings.nimplemented)--Nothing.. ITs bug :(
						else
							local newStr = nil
							if numeric then
								if value then value=tonumber(value:gsub("0x", ""),16) end			--Hex-Dec
								newStr = osk.init(field, value, 10, __OSK_TYPE_NUMBER, __OSK_MODE_TEXT)
							else
								newStr = osk.init(field, value, 512, __OSK_TYPE_DEFAULT, __OSK_MODE_TEXT)
							end

							if newStr then
								if value != newStr then
									textHadChange = true
									changes[texteditorInfo.focus] = {}
									if not changes[field] then changes[field] = {} end

									--Update line & set changes to late save!
									if numeric then
										texteditorInfo.list[texteditorInfo.focus] = string.format("%s = 0x%X", field, tonumber(newStr))
										changes[field].number = tonumber(newStr)
									else
										changes[field].string = ""
										texteditorInfo.list[texteditorInfo.focus] = string.format("%s = %s", field, newStr)
										changes[field].string = newStr
									end
								end
							end
						end

					end--__EDITB

				end--field

			else
				local editStr = texteditorInfo.list[texteditorInfo.focus]
				local newStr = osk.init(strings.editline, editStr, 512, __OSK_TYPE_DEFAULT, __OSK_MODE_TEXT)
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
	buttons.read()
	buttons.analogtodpad()
	buttons.interval(16,5)
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
		screen.print(960/2,300,strings.textftp,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
		screen.print(327,333,"FTP://"+tostring(wlan.getip())..":1337",1,theme.style.FTPCOLOR,color.black)
		screen.print(960/2,375,strings.closeftp,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
		screen.flip()

		if buttons.start then
			if ftpimg then ftpimg:blit(0,0) end
			screen.print(960/2,300,strings.textftp,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
			screen.print(327,333,"FTP://"+tostring(wlan.getip())..":1337",1,theme.style.FTPCOLOR,color.black)
			screen.print(960/2,375,strings.loseftp,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
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
		power.tick()

		if theme.data["list"] then theme.data["list"]:blit(0,0) end 

		local titlew = string.format(strings.connectusb)
		local w,h = screen.textwidth(titlew,1) + 30,70
		local x,y = 480 - (w/2), 272 - (h/2)

		draw.fillrect(x, y, w, h, theme.style.BARCOLOR)
		draw.rect(x, y, w, h,color.white)
			screen.print(480,y+13, titlew,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
			screen.print(480,y+40, textXO..strings.cancelusb,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
		screen.flip()

		if buttons[cancel] then return false end
	end

	--[[
		// 0:	USBDEVICE_MODE_MEMORY_CARD
		// 1:	USBDEVICE_MODE_GAME_CARD
		// 2:	USBDEVICE_MODE_SD2VITA
		// 3:	USBDEVICE_MODE_PSVSD
		"ux0:","ur0:","uma0:","gro0:","grw0:"
	]]
	local mode_usb = -1
	local title = string.format(strings.usbmode)
	local w,h = screen.textwidth(title,1) + 120,145
	local x,y = 480 - (w/2), 272 - (h/2)

	while true do
		buttons.read()
		power.tick()
		if theme.data["list"] then theme.data["list"]:blit(0,0) end 

		draw.fillrect(x, y, w, h, theme.style.BARCOLOR)
		draw.rect(x,y,w,h,color.white)
			screen.print(480, y+10, title,1,color.white,color.black, __ACENTER)
			screen.print(480,y+40,SYMBOL_CROSS.." "..strings.sd2vita, 1,color.white,color.black, __ACENTER)
			screen.print(480,y+65,SYMBOL_SQUARE.." "..strings.memcard, 1,color.white,color.black, __ACENTER)
			screen.print(480,y+90,SYMBOL_TRIANGLE.." "..strings.gamecard, 1,color.white,color.black, __ACENTER)
			screen.print(480,y+115,SYMBOL_CIRCLE.." "..strings.cancel, 1,color.white,color.black, __ACENTER)
		screen.flip()

		if buttons[accept] or buttons.square or buttons.triangle or buttons[cancel] then
			if buttons[accept] then mode_usb = 2
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
		os.message(strings.usbfail,0)
		return false
	end

	local titlew = string.format(strings.usbconnection)
	local w,h = screen.textwidth(titlew,1) + 30,70
	local x,y = 480 - (w/2), 272 - (h/2)
	while not buttons[cancel] do
		buttons.read()
		power.tick()
		if theme.data["list"] then theme.data["list"]:blit(0,0) end 

		draw.fillrect(x,y,w,h,theme.style.BARCOLOR)
		draw.rect(x,y,w,h,color.white)
			screen.print(480,y+13, strings.usbconnection,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
			screen.print(480,y+40, textXO..strings.cancelusb,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
		screen.flip()
	end

	usb.stop()
	buttons.read()
	buttons.homepopup(1)

	explorer.refresh(true)
	explorer.action = 0
	multi={}
	return true
end
