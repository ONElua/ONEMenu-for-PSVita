--[[ 
   ONEMenu
   Application, themes and files manager.
   
   Licensed by Creative Commons Attribution-ShareAlike 4.0
   http://creativecommons.org/licenses/by-sa/4.0/
   
   Designed By Gdljjrod & DevDavisNunez.
   Collaborators: BaltazaR4 & Wzjk.
]]

function isTouched(x,y,sx,sy)
    for i=1,touch.front.count do
		if math.minmax(touch.front[i].x,x,x+sx)==touch.front[i].x and math.minmax(touch.front[i].y,y,y+sy)==touch.front[i].y then
			return true
		end
	end
	return false
end

categories = {
	{ img = theme.data["psvita"] },	--cat 1
	{ img = theme.data["hbvita"] },	--cat 2
	{ img = theme.data["psm"] },	--cat 3
	{ img = theme.data["retro"]},	--cat 4
	{ img = theme.data["adrbb"]},	--cat 5
	{ img = theme.data["fav"] },	--cat 6
}

cat,limit,movx=0,7,0
elev = 0

appman = {}
for i=1,#categories do table.insert(appman, { list={}, scroll, slide = { img = nil, x=0 , acel=7, w= 0 } } ) end
appman.len = 0

function fillappman(obj)
	
	local index=1

	if obj.type == "mb" then
		if __FAV == 1 then index = 6 else index = 3 end
		obj.resize = true
		obj.path_img = "ur0:appmeta/"..obj.id.."/pic0.png"
	elseif obj.type == "EG" or obj.type == "ME" then
		if __FAV == 1 then index = 6 else index = 4 end
		obj.resize = true
		obj.path_img = "ur0:appmeta/"..obj.id.."/livearea/contents/startup.png"
	else

		if files.exists(obj.path.."/data/boot.inf") or obj.id == "PSPEMUCFW" then
			if __FAV == 1 then index = 6 else index = 5 end
		else
			local sfo = game.info(obj.path.."/sce_sys/param.sfo")
			if sfo and sfo.CONTENT_ID then
				if sfo.CONTENT_ID:len() > 9 then
					if __FAV == 1 then index = 6 else index = 1 end
				else
					if __FAV == 1 then index = 6 else index = 2 end
				end
			else
				if __FAV == 1 then index = 6 else index = 2 end
			end
		end

		obj.path_img = "ur0:appmeta/"..obj.id.."/icon0.png"

	end

	obj.img = image.copy(theme.data["icodef"])
	if __FAV == 1 then
		obj.img:resize(120,120)
	else
		if obj.resize then obj.img:resize(120,100) else obj.img:resize(120,120) end
	end

	appman.len += 1
	table.insert(appman[index].list,obj)

end

function appman.refresh()

	--Solo se escanea en cada inicio de 1menu
	if appman.len == 0 then

		local gpu = os.gpuclock()
		os.cpu(444)
		os.gpuclock(166)

		--id, type, version, dev, path, title
		local list = game.list(__GAME_LIST_ALL)
		table.sort(list, function (a,b) return string.lower(a.id)<string.lower(b.id) end)

		for i=1,#list do

			if files.exists(list[i].path) then
				list[i].fav = false
				for j=1,#apps do
					if list[i].id == apps[j] then list[i].fav = true end
				end

					if __FAV == 1 and #apps>0 then
						if list[i].fav then	fillappman(list[i])	end--Scan only Favs
					else
						__FAV=0
						fillappman(list[i])
					end
			end

		end

		if __FAV == 1 then cat = 6
		else
			local tmp=1
			while tmp<5 do
				if #appman[tmp].list > 0 then cat=tmp break end
				tmp+=1
			end
			if cat == 0 then appman.len = 0 end
		end

		os.cpu(333)
		os.gpuclock(gpu)
	end

	--Sorteamos contenido
	if __FAV == 0 then
		if #appman[3].list > 0 then--PSM
			table.sort(appman[3].list, function (a,b) return string.lower(a.title)<string.lower(b.title) end)
		end

		if #appman[5].list > 0 then--PSP(X)
			table.sort(appman[5].list, function (a,b) return string.lower(a.title)<string.lower(b.title) end)
		end
	else
		if #appman[6].list > 0 then
			table.sort(appman[6].list, function (a,b) return string.lower(a.type)<string.lower(b.type) end)
			table.sort(appman[6].list, function (a,b) return string.lower(a.id)<string.lower(b.id) end)
		end
	end

	--Asignamos limites y las img para nuestras categorias
	for i=1,#appman do
		appman[i].scroll = newScroll(appman[i].list,limit)
		appman[i].slide.img = categories[i].img
		if appman[i].slide.img then
			appman[i].slide.w = appman[i].slide.img:getw()
		end
	end

	theme.data["splash"] = nil

	infodevices()
end

reboot = true
function appman.ctrls()

	if submenu_ctx.open then return end
	if not submenu_ctx.close then return end

	if (buttons.right or buttons.held.r or buttons.analoglx > 60) and submenu_ctx.x == -submenu_ctx.w then
		if appman[cat].scroll:down_menu() then elev=0 end
	end

	if (buttons.left or buttons.held.l or buttons.analoglx < -60) and submenu_ctx.x == -submenu_ctx.w then
		if appman[cat].scroll:up_menu() then elev=0 end
	end

	if (buttons.up or buttons.down) and submenu_ctx.x == -submenu_ctx.w and cat!=6 then

		local tmp_cat = cat
		if buttons.up then
			cat-=1
			if cat < 1 then cat = #appman end
			while #appman[cat].list < 1 do
				cat-=1
				if cat < 1 then cat = #appman end
			end
		end

		if buttons.down then
			cat+=1
			if cat > #appman then cat = 1 end
			while #appman[cat].list < 1 do
				cat+=1
				if cat > #appman then cat = 1 end
			end
		end

		if tmp_cat != cat then elev=0 end
	end

	--tmp0.CATEGORY: ISO/CSO UG, PSN EG, HBs MG, PS1 ME
	if buttons[accept] or isTouched(95,148,151,228) then

		local gameboot = image.load(string.format("%s/pic0.png","ur0:appmeta/"..appman[cat].list[focus_index].id))

		if not gameboot then gameboot = game.bg0(appman[cat].list[focus_index].id) end

		if gameboot then
			screen.flip()
			splash_efect(gameboot,10,3)
		end

		if appman[cat].list[focus_index].type == "ME" then game.open(appman[cat].list[focus_index].id)
		else game.launch(appman[cat].list[focus_index].id) end
	end

end

IMAGE_PORT_I = channel.new("IMAGE_PORT_I")
IMAGE_PORT_O = channel.new("IMAGE_PORT_O")
THID_IMAGE = thread.new("system/thread_img.lua")

local search_icon,cont_icons = false,0
function appman.launch()

	appman.refresh()
	buttons.interval(10,10)
	while true do

		--Este for es una belleza!!!!
	if not search_icon then
		os.cpu(444)
		for i=1, #appman do
			for j=1, #appman[i].list do

				if not appman[i].list[j].ready then
					appman[i].list[j].ready = true
					IMAGE_PORT_O:push( { i=i, j=j, fav = __FAV, path = appman[i].list[j].path_img, resize = appman[i].list[j].resize } ) -- Enviamos peticion
				end

				if IMAGE_PORT_I:available() > 0 then -- De tal manera que si se quedo un previo, lo pueda setear..
					local entry = IMAGE_PORT_I:pop() -- Recibimos peticiones..

					if appman[entry.i].list[entry.j].path_img == entry.path then -- Por si lo borran o cambio etc..
						if entry.img then
							appman[entry.i].list[entry.j].img = entry.img
						end
						cont_icons += 1
					end
				end

			end
		end
		if cont_icons == appman.len then
			os.cpu(333)
			search_icon = true
		end
	end

		buttons.read()
		touch.read()

		if theme.data["back"] then theme.data["back"]:blit(0,0) end
		if math.minmax(tonumber(os.date("%d%m")),2412,2512)== tonumber(os.date("%d%m")) then stars.render() end

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

		if buttons.start and not submenu_ctx.open then
			system.run()
		end

		shortcuts()

	end
end

-----------------------------------------Submenu-----------------------------------------------------------------------

local manual_callback = function ()

	local pathmanual = ""
	pathmanual = appman[cat].list[focus_index].path.."/sce_sys/manual/"

	if files.exists(pathmanual) then
		if os.message(strings.manual,1) == 1 then
			local size_manual = files.size(pathmanual)
			reboot=false
				files.delete(pathmanual)
			reboot=true

			--update size
			appman[cat].list[focus_index].size = files.size(appman[cat].list[focus_index].path)
			appman[cat].list[focus_index].sizef = files.sizeformat(appman[cat].list[focus_index].size or 0)

			infodevices()

			os.message(files.sizeformat(size_manual).." "..strings.free)
		end
	else
		os.message(strings.notfindmanual)
	end

end

local uninstall_callback = function ()
	if appman[cat].list[focus_index].id != __ID then
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

local switch_callback = function ()

	if appman[cat].list[focus_index].type == "mb" or appman[cat].list[focus_index].type == "EG" or appman[cat].list[focus_index].type == "ME" then return end

	local mov = 1
	local loc1,loc2,v1,v2 = "ur0","uma0",1,1
	if appman[cat].list[focus_index].dev == "ur0" then
		loc1,loc2,v1,v2 = "ux0","uma0",2,5
	elseif appman[cat].list[focus_index].flag == "ux0" then
		loc1,loc2,v1,v2 = "ur0","uma0",1,3
	elseif appman[cat].list[focus_index].flag == "uma0" then
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
				total_size,files_move, cont = 0,0,0
				fileant = ""
			game_move=false

		buttons.homepopup(1)
		reboot=true
		buttons.read()--fflush
		os.delay(100)

		if result ==1 then
			if mov == 1 or mov == 6 then
				appman[cat].list[focus_index].path = "ur0:app/"..appman[cat].list[focus_index].id
				appman[cat].list[focus_index].dev = "ur0"
			elseif mov == 2 or mov == 4 then
				appman[cat].list[focus_index].path = "ux0:app/"..appman[cat].list[focus_index].id
				appman[cat].list[focus_index].dev = "ux0"
			elseif mov == 3 or mov == 5 then
				appman[cat].list[focus_index].path = "uma0:app/"..appman[cat].list[focus_index].id
				appman[cat].list[focus_index].dev = "uma0"
			end
			if appman[cat].list[focus_index].id == __ID then
				os.message(strings.restart)
				power.restart()
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

local fav_callback = function ()

	appman[cat].list[focus_index].fav = not appman[cat].list[focus_index].fav
	submenu_ctx.wakefunct()

	if appman[cat].list[focus_index].fav then
		favs = strings.yes
		table.insert(apps, appman[cat].list[focus_index].id)
	else
		favs = strings.no
		for j=1,#apps do
			if appman[cat].list[focus_index].id == apps[j] then
				table.remove(apps, j)
			end
		end
	end

	write_favs(__PATH_FAVS)
	submenu_ctx.close = true
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

favs=""
function submenu_ctx.wakefunct()

	if __SLIDES == 100 then var = strings.original else var = strings.ps4 end
	if __PIC1 == 1 then showpic = strings.yes else showpic = strings.no end

	submenu_ctx.options = { -- Handle Option Text and Option Function
		{ text = strings.pressremove,	state = true, funct = uninstall_callback },
		{ text = strings.removemanual,	state = true, funct = manual_callback },
		{ text = strings.switchapp, 	state = true, funct = switch_callback },
		{ text = strings.slides..var,	state = true, funct = slides_callback },
		{ text = strings.pic1..showpic,	state = true, funct = pic1_callback },
		{ text = strings.fav..favs,		state = true, funct = fav_callback },
	}
	submenu_ctx.scroll = newScroll(submenu_ctx.options, #submenu_ctx.options)
end

submenu_ctx.wakefunct()

function submenu_ctx.run()
	if buttons[submenu_ctx.ctrl] then submenu_ctx.close = not submenu_ctx.close end -- Open/Close Menu
	if submenu_ctx.close then submenu_ctx.wakefunct() end
	submenu_ctx.draw()
	submenu_ctx.buttons()
end

SIZES_PORT_I = channel.new("SIZES_PORT_I")
SIZES_PORT_O = channel.new("SIZES_PORT_O")
THID_SIZE = thread.new("system/thread_size.lua")

function submenu_ctx.draw()

	if appman[cat].list[focus_index].fav then favs = strings.yes else favs = strings.no end

	--gd,gp PSVITA:1	hbsvita2	mb PSM:3	EG PSP & ME PSX: 4		AdrenalineBubbles:5
	if not submenu_ctx.close and not pic1 then

		if __PIC1 == 1 then
			if appman[cat].list[focus_index].type == "mb" then
				pic1 = game.bg0(appman[cat].list[focus_index].id)
				if not pic1 then
					pic1 = image.load(string.format("%s/pic0.png","ur0:appmeta/"..appman[cat].list[focus_index].id))
				end
			else
				pic1 = image.load(string.format("%s/pic0.png","ur0:appmeta/"..appman[cat].list[focus_index].id))
				if not pic1 then
					pic1 = game.bg0(appman[cat].list[focus_index].id)--id al recompilar
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
				screen.print(12, h, submenu_ctx.options[i].text, 1, cc,theme.style.TXTBKGCOLOR, __ALEFT)
				h += 25
			end
		end

		--Textos informativos en el submenu
		h += 25
		screen.print(10,h, strings.version..": "..appman[cat].list[focus_index].version or "", 1.0, theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
		h += 20
		screen.print(10,h, strings.size_ind..": "..(appman[cat].list[focus_index].sizef or strings.getsize), 1.0, theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT )
		--h += 20

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
