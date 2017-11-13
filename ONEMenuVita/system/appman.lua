--[[ 
   ONEMenu
   Application, themes and files manager.
   
   Licensed by Creative Commons Attribution-ShareAlike 4.0
   http://creativecommons.org/licenses/by-sa/4.0/
   
   Designed By Gdljjrod & DevDavisNunez.
   Collaborators: BaltazaR4 & Wzjk.
]]

function splash(pics,delay,vel)
	pics:center()
	for i = 0, 255, vel do
		pics:blit(__DISPLAYW/2,__DISPLAYH/2,i)
		screen.flip()
	end
	os.delay(delay)
	for i = 255, 0, -vel do
		pics:blit(__DISPLAYW/2,__DISPLAYH/2,i)
		screen.flip()
	end
end

default_icon = theme.data["icodef"]
label = {
	{ img = theme.data["psvita"] },
	{ img = theme.data["psm"] },
	{ img = theme.data["psp"]},
	{ img = theme.data["ps1"] },
	{ img = theme.data["adrbb"]},
}

cat,limit,movx=1,7,0
elev = 0

appman = {}
for i=1,5 do table.insert(appman, { list={}, scroll, slide = { img = nil, x=0 , acel=7, w= 0 } } ) end
appman.len = 0

function appman.refresh()
	if appman.len == 0 then
		os.cpu(444)

		local wstrength = wlan.strength()
		if wstrength then
			if wstrength > 55 and not avatar then getavatar(__AVATAR) end
		end

		local list = game.list(__GAME_LIST_ALL)
		table.sort(list, function (a,b) return string.lower(a.title)<string.lower(b.title) end)

		local i = #list
		while i > 0 do
			if not files.exists(list[i].path) or (list[i].id == "1MENUVITA") then
				table.remove(list,i)
			end
			i -= 1
		end

		--id, type, version, dev, path, title
		appman.len = #list
		for i=1,appman.len do
			list[i].flag = 1					--ux0

			if list[i].dev == "ur0" then
				list[i].flag = 0
			elseif list[i].dev == "uma0" then
				list[i].flag = 2
			end

			list[i].size = nil
			list[i].sizef = nil
			list[i].clon = false
			list[i].basegame = false

			local img = nil
			--gd,gp PSVITA:1	mb PSM:2	EG PSP:3	ME PSX:4	AdrenalineBubbles:5
			local index=1
			if list[i].type == "EG" or list[i].type == "ME" then
				index=4

				img = game.geticon0(string.format("%s/pboot.pbp",list[i].path))--pboot
				if not img then
					img = image.load(string.format("ur0:appmeta/%s/livearea/contents/startup.png",list[i].id))
					if not img then	img = game.geticon0(string.format("%s/eboot.pbp",list[i].path)) end--icon0 normal
				end

				--Clon
				list[i].basegame = true
				if list[i].type == "EG" then
					index=3
					local sceid = game.sceid(string.format("%s/__sce_ebootpbp",list[i].path))
					if sceid and sceid != "---" then
						if sceid != list[i].id then
							list[i].clon = true
						end
					end
				end

			elseif list[i].type == "mb" then--PSM
				index=2
				img = image.load(string.format("%s/pic0.png","ur0:appmeta/"..list[i].id))
			else
				if files.exists(list[i].path.."/data/boot.inf") or list[i].id == "PSPEMUCFW" then index = 5 end
				game.mount(list[i].id)
					img = image.load(string.format("%s/sce_sys/icon0.png",list[i].path))
				game.umount()
			end
			if not img then img = image.copy(theme.data["icodef"]) end

			list[i].img = img
			if list[i].img then
				--only PSP/PSM
				if list[i].type == "EG" or index==2 then list[i].img:resize(120,100) else list[i].img:resize(120,120) end
				list[i].img:setfilter(__LINEAR, __LINEAR)
			end

			table.insert(appman[index].list,list[i])

			if theme.data["back"] then theme.data["back"]:blit(0,0) end
			if not explorer.list then
				screen.print(10,15,list[i].id)
				screen.flip()
			end

		end--for
		os.cpu(333)
	end

	for i=1,#appman do
		appman[i].scroll = newScroll(appman[i].list,limit)
		appman[i].slide.img = label[i].img
		if appman[i].slide.img then
			appman[i].slide.w = appman[i].slide.img:getw()
		end
	end

	infodevices()

end

reboot = true
function appman.ctrls()

	if submenu_ctx.open then return end
	if not submenu_ctx.close then return end

	if (buttons.right or buttons.held.r or buttons.analoglx > 60) and submenu_ctx.x == -submenu_ctx.w then
		if appman[cat].scroll:down_menu() then
			if (buttons.right and theme.data["slide"]) then theme.data["slide"]:stop() theme.data["slide"]:play() end
			elev=0
		end
	end

	if (buttons.left or buttons.held.l or buttons.analoglx < -60) and submenu_ctx.x == -submenu_ctx.w then
		if appman[cat].scroll:up_menu() then
			if (buttons.left and theme.data["slide"]) then theme.data["slide"]:stop() theme.data["slide"]:play() end
			elev=0
		end
	end

	if (buttons.up or buttons.down) and submenu_ctx.x == -submenu_ctx.w then

		if buttons.up then
			cat-=1
			if cat < 1 then cat = #appman end
			while #appman[cat].list < 1 do
				cat-=1
				if cat < 1 then cat = #appman end
			end
		end

		if theme.data["jump"] then
			theme.data["jump"]:stop() theme.data["jump"]:play()
		end

		if buttons.down then
			cat+=1
			if cat > #appman then cat = 1 end
			while #appman[cat].list < 1 do
				cat+=1
				if cat > #appman then cat = 1 end
			end
		end

		elev=0
	end

	--tmp0.CATEGORY: ISO/CSO UG, PSN EG, HBs MG, PS1 ME
	if buttons[accept] then
		if __ID != appman[cat].list[focus_index].id then
			if appman[cat].list[focus_index].type == "EG" or appman[cat].list[focus_index].type == "ME" then
				gameboot = game.getpic1(string.format("%s/eboot.pbp",appman[cat].list[focus_index].path))
				if not gameboot then gameboot = game.getpic0(string.format("%s/eboot.pbp",appman[cat].list[focus_index].path)) end
			else
				gameboot = game.bg0(appman[cat].list[focus_index].path)
			end
			if gameboot then
				screen.flip()
				splash(gameboot,10,3)
			end
			if appman[cat].list[focus_index].type == "ME" then game.open(appman[cat].list[focus_index].id)
			else game.launch(appman[cat].list[focus_index].id) end
		else os.restart() end
	end

end

function appman.launch()

	cat=1
	appman.refresh()
	plugman.load() -- Reload plugs, because can change any in ftp, explorer

	buttons.interval(10,10)
	while true do
		buttons.read()

		if theme.data["back"] then theme.data["back"]:blit(0,0) end

		if appman.len > 0 then
			main_draw()
			submenu_ctx.run()
		else
			screen.print(10,30,strings.empty,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
		end

		screen.flip()
		
		if appman.len > 0 then
			appman.ctrls()
		end

		if buttons.select and not submenu_ctx.open then
			show_explorer_list()
		end

		if (buttons.held.l and buttons.held.r and buttons.up) and reboot then os.restart() end
		if (buttons.held.l and buttons.held.r and buttons.down) and reboot then power.restart() end

		if buttons.start and not submenu_ctx.open then
			system.run()
		end

	end
end

-----------------------------------------Submenu-----------------------------------------------------------------------

local manual_callback = function ()

	local pathmanual = ""
	if appman[cat].list[focus_index].type == "EG" or appman[cat].list[focus_index].type == "ME" then	--manual PSP/PS1
		pathmanual = string.format("%s/document.dat",appman[cat].list[focus_index].path)
	else
		pathmanual = string.format("%s/sce_sys/manual/",appman[cat].list[focus_index].path)
	end

	if files.exists(pathmanual) then
		local size_manual = files.size(pathmanual)
		reboot=false
			files.delete(pathmanual)
		reboot=true

		--update size
		appman[cat].list[focus_index].size = files.size(appman[cat].list[focus_index].path)
		appman[cat].list[focus_index].sizef = files.sizeformat(appman[cat].list[focus_index].size or 0)

		infodevices()

		os.message(files.sizeformat(size_manual).." "..strings.free)
	else
		os.message(strings.notfindmanual)
	end

end

local uninstall_callback = function ()

	if appman[cat].list[focus_index].clon then
		if os.message(strings.delclon+appman[cat].list[focus_index].id+" ?",1) == 1 then
			buttons.homepopup(0)
			reboot=false
				files.delete("ur0:appmeta/"+appman[cat].list[focus_index].id)
				files.delete("ux0:pspemu/PSP/GAME/"+appman[cat].list[focus_index].id)
			os.delay(1500)
			_print=false
			os.updatedb()
			os.message(strings.restartupdb)
			os.delay(3500)
			buttons.homepopup(1)
			power.restart()
		end
	else
		if appman[cat].list[focus_index].flag == 1 and __ID != appman[cat].list[focus_index].id then
			if os.message(strings.appremove + appman[cat].list[focus_index].id + "?",1) == 1 then
				if theme.data["back"] then theme.data["back"]:blit(0,0) end
				message_wait()
				buttons.homepopup(0)
				reboot=false

				local result_rmv = game.delete(appman[cat].list[focus_index].id)
				buttons.homepopup(1)
				reboot=true
				if result_rmv == 1 then

					if theme.data["back"] then theme.data["back"]:blit(0,0) end

					table.remove(appman[cat].list, appman[cat].scroll.sel)
					appman[cat].scroll.maxim=#appman[cat].list
						
					if #appman[cat].list < 1 then
						while #appman[cat].list < 1 do
							cat += 1
							if cat > #appman then cat = 1 end
						end
					else

						if appman[cat].scroll.sel==appman[cat].scroll.lim then
							if appman[cat].scroll.ini != 1 then appman[cat].scroll.ini-=1 end
							appman[cat].scroll.sel-=1
							appman[cat].scroll.lim=appman[cat].scroll.sel
						elseif appman[cat].scroll.lim>#appman[cat].list then
							appman[cat].scroll.lim-=1
						end
					end
					appman.len -= 1
					infodevices()
				end
				submenu_ctx.close = true
			end
		end
	end

end
	
local switch_callback = function ()

	if cat != 1 and cat != 5 then return end

	local mov = 1
	local loc1,loc2,v1,v2 = "ur0","uma0",1,1
	if appman[cat].list[focus_index].flag == 0 then
		loc1,loc2,v1,v2 = "ux0","uma0",2,5
	elseif appman[cat].list[focus_index].flag == 1 then
		loc1,loc2,v1,v2 = "ur0","uma0",1,3
	elseif appman[cat].list[focus_index].flag == 2 then
		loc1,loc2,v1,v2 = "ux0","ur0",4,6
	end

	buttons.read()
	local vbuff = screen.toimage()
	local options = {
			{ text = loc1 },
			{ text = loc2 },
			{ text = strings.cancel }
		}
	local scroll_op = newScroll(options, #options)
	while true do
		buttons.read()
		if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end

		screen.print(350,60,strings.partitions,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ARIGHT)

		local titlew = string.format(strings.switchapp)
		local w = screen.textwidth(titlew,1) + 10
		draw.line(220,50,220,submenu_ctx.y + 98, color.green)

		local y = 80
		for i=scroll_op.ini,scroll_op.lim do
			if i == scroll_op.sel then cccolor = color.green else cccolor = color.white end
			screen.print(350,y, options[i].text,1.0,cccolor,theme.style.TXTBKGCOLOR,__ARIGHT)
			y+=20
		end

		screen.flip()

		if buttons.up then scroll_op:up() elseif buttons.down then scroll_op:down() end

		if buttons[accept] then
			if scroll_op.sel == 1 then mov = v1
			elseif scroll_op.sel == 2 then mov = v2
			else return end
			break
		end

		if buttons[cancel] then return end

	end--while

	buttons.read()--fflush
	buttons.homepopup(0)
		reboot=false
		 	--//1		ux0-ur0
			--//2		ur0-ux0
			--//3		ux0-uma0
			--//4		uma0-ux0
			--//5		ur0-uma0
			--//6		uma0-ur0
			--flag =0 ur0	flag =1 ux0		flag =2 uma0
			game_move=true
				total_size,folders,filess = files.size(appman[cat].list[focus_index].path)
				files_move,cont = folders+filess,0
				local result = game.move(appman[cat].list[focus_index].id, mov, total_size)
				total_size = 0
				files_move,cont = folders+filess,0
			game_move=false

		buttons.homepopup(1)
		reboot=true
		buttons.read()--fflush

		if result ==1 then

			if __ID == appman[cat].list[focus_index].id then
				os.message(strings.restart)
				power.restart()
			end

			if mov == 1 or mov == 6 then
				appman[cat].list[focus_index].flag = 0
				appman[cat].list[focus_index].path = "ur0:app/"..appman[cat].list[focus_index].id
				appman[cat].list[focus_index].dev = "ur0"
			elseif mov == 2 or mov == 4 then
				appman[cat].list[focus_index].flag = 1
				appman[cat].list[focus_index].path = "ux0:app/"..appman[cat].list[focus_index].id
				appman[cat].list[focus_index].dev = "ux0"
			elseif mov == 3 or mov == 5 then
				appman[cat].list[focus_index].flag = 2
				appman[cat].list[focus_index].path = "uma0:app/"..appman[cat].list[focus_index].id
				appman[cat].list[focus_index].dev = "uma0"
			end

		elseif result ==-4 then os.message(strings.nomemory) end

	infodevices()

end

local slides_callback = function ()

	if __SLIDES == 100 then __SLIDES = 415 else __SLIDES = 100 end

	submenu_ctx.wakefunct()
	write_config()

	submenu_ctx.close = true

end

local pic1_callback = function ()

	local pos_menu = submenu_ctx.scroll.sel

	if __PIC1 == 1 then
		__PIC1,showpic = 0,strings.no
	else
		__PIC1,showpic = 1,strings.yes
	end

	submenu_ctx.wakefunct()
	write_config()

	submenu_ctx.scroll.sel = pos_menu
end

submenu_ctx = {
	h = 450,				-- Height of menu
	w = 355,				-- Width of menu
	x = -160,				-- X origin of menu
	y = 50,					-- Y origin of menu
	open = false,			-- Is open the menu?
	close = true,
	speed = 15,				-- Speed of Effect Open/Close.
	ctrl = "triangle",		-- The button handle Open/Close menu.
	scroll = newScroll(),	-- Scroll of menu options.
}

function submenu_ctx.wakefunct()

	if __SLIDES == 100 then var = strings.up else var = strings.down end
	if __PIC1 == 1 then showpic = strings.yes else showpic = strings.no end

	submenu_ctx.options = { -- Handle Option Text and Option Function
		{ text = strings.pressremove,	state = true, funct = uninstall_callback },
		{ text = strings.removemanual,	state = true, funct = manual_callback },
		{ text = strings.switchapp, 	state = true, funct = switch_callback },
		{ text = strings.slides..var,	state = true, funct = slides_callback },
		{ text = strings.pic1..showpic,	state = true, funct = pic1_callback },
	}
	submenu_ctx.scroll = newScroll(submenu_ctx.options, #submenu_ctx.options)
end

submenu_ctx.wakefunct()

function submenu_ctx.run()
	if buttons[submenu_ctx.ctrl] then submenu_ctx.close = not submenu_ctx.close
		if theme.data["jump"] then
			theme.data["jump"]:stop() theme.data["jump"]:play()
		end
	end -- Open/Close Menu
	if submenu_ctx.close then submenu_ctx.wakefunct() end
	submenu_ctx.draw()
	submenu_ctx.buttons()
end

SIZES_PORT_I = channel.new("SIZES_PORT_I")
SIZES_PORT_O = channel.new("SIZES_PORT_O")
THID_SIZE = thread.new("system/thread_size.lua")

function submenu_ctx.draw()

	--gd,gp PSVITA:1	mb PSM:2	EG PSP:3	ME PSX:4	AdrenalineBubbles:5
	if not submenu_ctx.close and not pic1 then

		if __PIC1 == 1 then
			if cat == 3 or cat == 4 then
				pic1 = image.load(string.format("ur0:appmeta/%s/livearea/contents/bg0.png",appman[cat].list[focus_index].id))
			else
				pic1 = game.bg0(appman[cat].list[focus_index].path)
				if not pic1 then
					pic1 = image.load(string.format("%s/pic0.png","ur0:appmeta/"..appman[cat].list[focus_index].id))
				end
			end
		end

	end

	if not submenu_ctx.close and submenu_ctx.x < 0 then
		submenu_ctx.x += submenu_ctx.speed
	elseif submenu_ctx.close and submenu_ctx.x > -submenu_ctx.w then
		submenu_ctx.x -= submenu_ctx.speed
	end

	if submenu_ctx.x > -submenu_ctx.w then
		if not appman[cat].list[focus_index].pullsize then
			appman[cat].list[focus_index].pullsize = true
			SIZES_PORT_O:push({cat = cat, focus = focus_index, path = appman[cat].list[focus_index].path}) -- Enviamos peticion
		end
		if SIZES_PORT_I:available() > 0 then -- De tal manera que si se quedo un previo, lo pueda setear..
			local entry = SIZES_PORT_I:pop() -- Recibimos peticiones..
			if appman[entry.cat].list[entry.focus] and appman[entry.cat].list[entry.focus].path == entry.path then -- Por si lo borran o cambio etc..
				appman[entry.cat].list[entry.focus].size = entry.size
				appman[entry.cat].list[entry.focus].sizef = entry.sizef
			end
		end
		draw.fillrect(submenu_ctx.x, submenu_ctx.y, submenu_ctx.w, submenu_ctx.h, theme.style.BARCOLOR)
	end

	if submenu_ctx.x >= 0 then
		submenu_ctx.open = true
		local h = submenu_ctx.y + 30 -- Punto de origen de las opciones
		for i=submenu_ctx.scroll.ini,submenu_ctx.scroll.lim do
			if i==submenu_ctx.scroll.sel then cc=color.green else cc=color.white end
			if i==submenu_ctx.scroll.sel then 
				if (i!=3) then draw.fillrect(5,h-2,330,23,theme.style.SELCOLOR)
				else draw.fillrect(5,h-2,215,23,theme.style.SELCOLOR) end
			end
			if submenu_ctx.options[i].state then
				screen.print(12, h, submenu_ctx.options[i].text, 1, cc,theme.style.TXTBKGCOLOR, __ALEFT)--cc,color.blue
				h += 25
			end
		end

		--Textos informativos en el submenu
		h += 25
		screen.print(10,h, strings.version..": "..appman[cat].list[focus_index].version or "", 1.0, theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
		h += 20
		screen.print(10,h, strings.size_ind..": "..(appman[cat].list[focus_index].sizef or strings.getsize), 1.0, theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT )
		h += 20

		if appman[cat].list[focus_index].clon then
			screen.print(15,h,strings.clon,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
			h+=20
		end

		if plugman.list[appman[cat].list[focus_index].id] then
			screen.print(10,h, strings.plugins..": ", 1.0, theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
			h += 20
			for i=1, #plugman.list[appman[cat].list[focus_index].id] do
				local ccc = color.green
				if not files.exists(plugman.list[appman[cat].list[focus_index].id][i].path) then ccc=color.red end
				screen.print(10,h,plugman.list[appman[cat].list[focus_index].id][i].name or "",1.0,ccc,color.gray,__ALEFT)
				h += 20
			end
		end

		h = 480
		draw.fillrect(10,h, 330, 15, color.gray)
		draw.fillrect(10,h, math.map(infoux0.used, 0,infoux0.max, 0, 330 ), 15, color.shine:a(80))
		draw.rect(10,h,330,15,color.white:a(200))
		h-=20
		screen.print(10,h,"(ux0) "..infoux0.maxf.."/"..infoux0.freef,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
		h-=20

		if files.exists("ur0:") then
			draw.fillrect(10,h, 330, 15, color.gray)
			draw.fillrect(10,h, math.map(infour0.used, 0,infour0.max, 0, 330 ), 15, color.shine:a(80))
			draw.rect(10,h,330,15,color.white:a(200))
			h-=20
			screen.print(10,h,"(ur0) "..infour0.maxf.."/"..infour0.freef,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
			h-=20
		end
		if files.exists("uma0:") then
			draw.fillrect(10,h, 330, 15, color.gray)
			draw.fillrect(10,h, math.map(infouma0.used, 0,infouma0.max, 0, 330 ), 15, color.shine:a(80))
			draw.rect(10,h,330,15,color.white:a(200))
			h-=20
			screen.print(10,h,"(uma0) "..infouma0.maxf.."/"..infouma0.freef,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
		end

		--Textos informativos en el submenu

	else
		submenu_ctx.open = false
	end
end

function submenu_ctx.buttons()
	if not submenu_ctx.open then return end

	if buttons.up or buttons.analogly < -60 then submenu_ctx.scroll:up() end
	if buttons.down or buttons.analogly > 60 then submenu_ctx.scroll:down() end

	if buttons[accept] and submenu_ctx.options[submenu_ctx.scroll.sel].funct then
		submenu_ctx.options[submenu_ctx.scroll.sel].funct()
	end

	if buttons[cancel] then -- Run function of cancel option.
		submenu_ctx.close = not submenu_ctx.close
	end
end
