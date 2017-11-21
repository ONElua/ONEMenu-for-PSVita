--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

--Functions Commons

--===============================   vpk      ==========================================================================
function show_scan(infovpk)
	bufftmp = screen.buffertoimage()
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
		bufftmp:blit(0,0)

		draw.fillrect(x,y,420,420,color.new(0x2f,0x2f,0x2f,0xff))--color.shine)
		draw.framerect(x,y,420,420,color.black, color.shine,6)

		screen.print(960/2,y+35,infovpk.name,1,color.black,color.blue,__ACENTER)
		screen.print(960/2,y+85,strings.total_sizevpk..tostring(realsize),1,color.black,color.blue,__ACENTER)
		screen.print(960/2,y+115,strings.count..tostring(vpk.len),1,color.black,color.blue,__ACENTER)
		screen.flip()

		if buttons[accept] or buttons[cancel] then
			break
		end

	end
end

function show_msg_vpk(obj_vpk)
	bufftmp = screen.buffertoimage()
	local x,y = (960-420)/2,(544-420)/2

	reboot=false
		local scan_vpk = files.scan(obj_vpk.path,1)
		if not scan_vpk then return end
		if not #scan_vpk or #scan_vpk<=0 then return end
	reboot=true

	local bin_pos,icon_pos,sfo_pos=-1,-1,-1
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
	local realsize = files.sizeformat(scan_vpk.realsize or 0)

	while true do
		buttons.read()
		bufftmp:blit(0,0)

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
			tmp_vpk.img:setfilter(__ALINEAR, __ALINEAR)
			tmp_vpk.img:scale(150)
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

	if res == false then return end

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

		if os.message(strings.launchpbp+"\n"+scan_vpk.sfo.TITLE+" ?",1) == 1 then
			if game.exists(scan_vpk.sfo.TITLE_ID) then game.launch(scan_vpk.sfo.TITLE_ID) end
		end

		tmp_vpk.path = string.format("ux0:app/%s",scan_vpk.sfo.TITLE_ID)
		tmp_vpk.flag = 1
		tmp_vpk.color = color.green
		tmp_vpk.dev = "ux0"

		--Size
		if scan_vpk.realsize then
			tmp_vpk.size = scan_vpk.realsize
		else
			tmp_vpk.size = files.size(tmp_vpk.path)
		end
		tmp_vpk.sizef = files.sizeformat(tmp_vpk.size or 0)

		tmp_vpk.clon = false
		tmp_vpk.basegame = false

		if not tmp_vpk.img then tmp_vpk.img = image.copy(theme.data["icodef"]) end
		if tmp_vpk.img then
			tmp_vpk.img:reset()
			tmp_vpk.img:resize(120,120)
			tmp_vpk.img:setfilter(__LINEAR, __LINEAR)
		end

		--id, type, version, dev, path, title
		tmp_vpk.id = scan_vpk.sfo.TITLE_ID
		tmp_vpk.type = scan_vpk.sfo.CATEGORY
		tmp_vpk.version = scan_vpk.sfo.APP_VER or "00.00"
		tmp_vpk.title = scan_vpk.sfo.TITLE or scan_vpk.sfo.TITLE_ID

		--Update appman[x].list
		if files.exists(tmp_vpk.path.."/data/boot.inf") or tmp_vpk.id == "PSPEMUCFW" then index = 5 else index = 1 end

		--Search game in appman[index].list
		local search = 0
		for i=1,appman[index].scroll.maxim do
			if tmp_vpk.id == appman[index].list[i].id then search = i break end
		end

		if search == 0 then
			table.insert(appman[index].list, tmp_vpk)
			table.sort(appman[index].list ,function (a,b) return string.lower(a.id)<string.lower(b.id) end)
			appman[index].scroll:set(appman[index].list,limit)
			plugman.load()
		else
			--update
			appman[index].list[search].flag = 1
			appman[index].list[search].color = color.green
			appman[index].list[search].dev = "ux0"
			appman[index].list[search].img = tmp_vpk.img
			--appman[index].list[search].img:resize(120,120)

			--size
			appman[index].list[search].size = tmp_vpk.size
			appman[index].list[search].sizef = tmp_vpk.sizef

			appman[index].list[search].type = tmp_vpk.type
			appman[index].list[search].version = tmp_vpk.version
			appman[index].list[search].title = tmp_vpk.title

		end

		appman.len +=1
		infodevices()

	else
		os.message(strings.errorinstall)
	end

	bufftmp:blit(0,0)
	buttons.read()--flush xD
	--return res
end

--tmp0.CATEGORY: ISO/CSO UG, PSN EG, HBs MG, PS1 ME
function show_msg_pbp(handle)
	local bufftmp = screen.buffertoimage()
	local x,y = (960-420)/2,(544-420)/2

	local icon0 = game.geticon0(handle.path)
	local sfo = game.info(handle.path)

	local launch=false
	if (sfo.CATEGORY == "EG" or sfo.CATEGORY == "ME") then
		if sfo.DISC_ID and game.exists(sfo.DISC_ID) then
			launch=true
		end
	end

	local name=handle.name:lower()
	--Maybe work with PS1
	local res,xscr = false,290
	while true do
		buttons.read()
		bufftmp:blit(0,0)

		draw.fillrect(x,y,420,420,color.new(0x2f,0x2f,0x2f,0xff))--color.shine
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
			icon0:setfilter(__ALINEAR, __ALINEAR)
			icon0:scale(150)
			icon0:center()
			icon0:blit(960/2,544/2)
		end

		screen.flip()

		if buttons[cancel] then break end
		if buttons[accept] and launch then game.launch(sfo.DISC_ID) end 

	end

	bufftmp:blit(0,0)
	buttons.read()--flush xD
	return res
	
end

-- ## Music Player ##
function MusicPlayer(handle)
	local isMp3 = ((files.ext(handle.path) or "") == "mp3")
	local id3 = nil

	if isMp3 then id3 = sound.getid3(handle.path)	end 

	local snd = sound.load(handle.path)
	if snd then
		snd:play(1)
		while true do
			if theme.data["music"] then theme.data["music"]:blit(0,0) end
			buttons.read()

			screen.print(10,10,tostring(handle.name),1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)

			if id3 and id3.cover then
				if id3.cover:getw() > 350 or id3.cover:geth() > 350 then
					id3.cover:scale( math.floor( (350*100)/math.max(id3.cover:getw(), id3.cover:geth()) ) )
				end
				id3.cover:center()
				id3.cover:blit(175+35,175+100)
			else
				if theme.data["cover"] then
					theme.data["cover"]:center()
					theme.data["cover"]:blit(175+35,175+100)
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

				local perc = snd:porcent() 
				if perc then
					draw.fillrect(425,145,((perc*350)/100),10,color.green)
				end
				draw.rect(425,145,350,10,color.white)

				if id3 and id3.title then
					screen.print(425,175, id3.title,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
				end
				if id3 and id3.artist then
					screen.print(425,195, id3.artist,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
				end
			end
			
			screen.flip()

			power.tick(__SUSPEND) -- reset a power timers only for block suspend..

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
		snd = nil
		collectgarbage("collect")
		os.delay(150)
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

		local changeimg = false
		while true do
			if theme.data["back"] then theme.data["back"]:blit(0,0)	end
			buttons.read()
	
			tmp:blit(__DISPLAYW/2,__DISPLAYH/2)

			if show_bar_upper then
				draw.fillrect(0,0,__DISPLAYW,bar,theme.style.BARCOLOR)

				screen.print(10,5,infoimg.name,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
				screen.print(940,3,"w: "..infoimg.w,0.8,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ARIGHT)
				screen.print(940,24,"h: "..infoimg.h,0.8,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ARIGHT)
				if (infoimg.w>500 and infoimg.h>300) then
					screen.print(10,30,strings.background,0.7,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
				end
			end

			screen.flip()

			if buttons.square then show_bar_upper = not show_bar_upper end
			if buttons[cancel] or buttons[accept] then break end
			if buttons.triangle then
				if (infoimg.w>500 and infoimg.h>300) then
					theme.data["back"] = nil
					theme.data["back"] = tmp
					if theme.data["back"] then
						__BACKG = path
						write_config()
						changeimg = true
						os.message(strings.themesdone,0)
					end
				end
			end

		end

		tmp = nil
		barblit=false
		if changeimg then
			theme.data["back"]:reset()
			theme.data["back"]:resize(__DISPLAYW, __DISPLAYH)
		end
	else
		os.message(strings.imgerror)
	end
end

-- ## File-Viewer ## --
function visortxt(handle)
	local cont = nil
	if handle.ext == "sfo" then cont = files.readlinesSFO(handle.path)
	else cont = files.readlines(handle.path) end

	if cont == nil then return end

	local srcn = newScroll(cont,16)
	while true do
		buttons.read()
		if theme.data["list"] then theme.data["list"]:blit(0,0) end

		if buttons[cancel] then
			break
		end

		if buttons.up or buttons.analogly < -60 then srcn:up() elseif buttons.down or buttons.analogly > 60 then srcn:down() end

		screen.print(10,15,(handle.name or handle.path))
		local y = 70
		for i=srcn.ini,srcn.lim do
			if i == srcn.sel then draw.fillrect(10,y,__DISPLAYW-50,20,theme.style.SELCOLOR) end
			screen.print(15,y,cont[i],1,color.white)
			y+=26
		end
		screen.flip()
	end
	buttons.read()
end

function startftp()
	local init = false
	if not wlan.isconnected() then wlan.connect() end
	if wlan.isconnected() then init=ftp.init() end

	if not init then return false end

	while ftp.state() do
		reboot=false
		power.tick(1)
		buttons.read()
		if theme.data["ftp"] then theme.data["ftp"]:blit(0,0) end
		screen.print(960/2,300,strings.textftp,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
		screen.print(327,333,"FTP://"+tostring(wlan.getip())..":1337",1,theme.style.FTPCOLOR,color.black)
		screen.print(960/2,375,strings.closeftp,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
		screen.flip()

		if buttons.start then
			if theme.data["ftp"] then theme.data["ftp"]:blit(0,0) end
			screen.print(960/2,300,strings.textftp,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
			screen.print(327,333,"FTP://"+tostring(wlan.getip())..":1337",1,theme.style.FTPCOLOR,color.black)
			screen.print(960/2,375,strings.loseftp,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
			screen.flip()
			ftp.term()
			os.delay(100)
		end
	end
	reboot=true
	return true
end

function usbMassStorage()

	if not usb then os.requireusb() end

	while usb.actived() != 1 do
		buttons.read()
		power.tick(1)

		if theme.data["list"] then theme.data["list"]:blit(0,0) end 

		local titlew = string.format(strings.connectusb)
		local w,h = screen.textwidth(titlew,1) + 30,70
		local x,y = 480 - (w/2), 272 - (h/2)

		draw.fillrect(x, y, w, h, theme.style.BARCOLOR)
		draw.rect(x, y, w, h,color.white)
			screen.print(480,y+13, strings.connectusb,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
			screen.print(480,y+40, textXO..strings.cancelusb,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
		screen.flip()

		if buttons[cancel] then
			return false
		end
	end

	buttons.read()--fflush

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
		power.tick(1)
		if theme.data["list"] then theme.data["list"]:blit(0,0) end 

		draw.fillrect(x, y, w, h, color.new(0x2f,0x2f,0x2f,0xff))
			screen.print(480, y+10, title,1,color.white,color.black, __ACENTER)
			screen.print(480,y+40,SYMBOL_CROSS.." "..strings.sd2vita, 1,color.white,color.black, __ACENTER)
			screen.print(480,y+65,SYMBOL_SQUARE.." "..strings.memcard, 1,color.white,color.black, __ACENTER)
			screen.print(480,y+85,SYMBOL_TRIANGLE.." "..strings.gamecard, 1,color.white,color.black, __ACENTER)
			screen.print(480,y+110,SYMBOL_CIRCLE.." "..strings.cancel, 1,color.white,color.black, __ACENTER)
		screen.flip()

		if buttons.cross or buttons.square or buttons.triangle or buttons.circle then
			if buttons.cross then mode_usb = 2
			elseif buttons.square then mode_usb = 0
			elseif buttons.triangle then mode_usb = 1
			else return end
			break
		end
	end--while

	local conexion = usb.start(mode_usb)
	if conexion == -1 then os.message(strings.usbfail,0) return end

	local titlew = string.format(strings.usbconnection)
	local w,h = screen.textwidth(titlew,1) + 30,70
	local x,y = 480 - (w/2), 272 - (h/2)
	while not buttons[cancel] do
		buttons.read()
		power.tick(1)
		if theme.data["list"] then theme.data["list"]:blit(0,0) end 

		draw.fillrect(x,y,w,h,theme.style.BARCOLOR)
		draw.rect(x,y,w,h,color.white)
			screen.print(480,y+13, strings.usbconnection,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
			screen.print(480,y+40, textXO..strings.cancelusb,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
		screen.flip()
	end

	buttons.read()--fflush
	usb.stop()

	explorer.refresh(true)
	explorer.action = 0
	multi={}
end
