--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

theme = {
	data = {},	-- Handle of imgs
	style = {},	-- Handle of colors
}

enable_favs=""
local themesimg = nil
function theme.load()

	if theme.data["back"] then
		theme.data = {}
		theme.style = {}
		collectgarbage("collect")
	end

	-- Get the id of theme pack
	__THEME = ini.read(__PATHINI,"theme","id","default")
	__BACKG = ini.read(__PATHINI,"backg","img","")
	__SLIDES = tonumber(ini.read(__PATHINI,"slides","pos",100))
	__PIC1 = tonumber(ini.read(__PATHINI,"pics","show","1"))
	__FNT = tonumber(ini.read(__PATHINI,"font","type","2"))
	__FAV = tonumber(ini.read(__PATHINI,"favs","scan","0"))


	if __FAV == 1 and #apps>0 then
		enable_favs = strings.yes
	else
		__FAV=0
		enable_favs = strings.no
	end

	local elements = {
		{name="list"},
		{name="icons",sprite=true, w=16,h=16}, 		-- 112x16
		{name="buttons1",sprite=true, w=20,h=20}, 	-- 120*20
		{name="buttons2",sprite=true, w=30,h=20}, 	-- 120*20
		{name="wifi",sprite=true, w=22,h=22},		-- 132*22

		{name="psvita"},
		{name="hbvita"},
		{name="psm"},
		{name="retro"},
		{name="adrbb"},

		{name="icodef"},

		--splash solo se carga una vez...
		{name="splash"},

		{name="jump", sound=true},
		{name="slide", sound=true},
	}
	--table.insert(elements, {name = "algo"})

	local path = __PATHTHEMES..__THEME.."/"
	if not files.exists(path) then path = "system/theme/default/" end

	--Primero checamos si tienen una img de fondo para el back
	theme.data["back"] = image.load(__BACKG)
	if theme.data["back"] then 
		if (image.getrealw(theme.data["back"]) < __DISPLAYW or image.getrealh(theme.data["back"]) < __DISPLAYH) or
			(image.getrealw(theme.data["back"]) > __DISPLAYW or image.getrealh(theme.data["back"]) > __DISPLAYH) then
			theme.data["back"]:resize(__DISPLAYW, __DISPLAYH)
		end
	else
		if files.exists(path.."back.png") then theme.data["back"] = image.load(path.."back.png")
		else theme.data["back"] = image.load("system/theme/default/back.png") end
	end

	-- Load Resources
	local path_img = "system/theme/default/"
	local path_snd = "system/theme/default/"
	for i=1,#elements do
		if files.exists(string.format("%s%s.png",path,elements[i].name)) or files.exists(string.format("%s%s.ogg",path,elements[i].name)) then
			path_img = path else path_img = "system/theme/default/" end

		if elements[i].sound then
			theme.data[elements[i].name] = sound.load(string.format("%s%s.ogg",path_img,elements[i].name))--,1)
		elseif elements[i].sprite then
			theme.data[elements[i].name] = image.load(string.format("%s%s.png",path_img,elements[i].name),elements[i].w,elements[i].h)
		else
			theme.data[elements[i].name] = image.load(string.format("%s%s.png",path_img,elements[i].name))
		end
	end

	--Colores por defecto = tema por default
	theme.style = {
		TXTCOLOR		= 0xFFFFFFFF,
		TXTBKGCOLOR		= 0x64000000,
		BARCOLOR        = 0x64330066,
		TITLECOLOR      = 0xFF9999FF,
		PATHCOLOR       = 0xA09999FF,
		DATETIMECOLOR   = 0xFF7300E6,
		COUNTCOLOR		= 0XFF0000FF,
		CBACKSBARCOLOR	= 0xC8FFFFFF,
		SELCOLOR        = 0x64530689,
		SFOCOLOR        = 0XFFFF07FF,
		BINCOLOR        = 0XFF0041C3,
		MUSICCOLOR      = 0xFFFFFF00,
		IMAGECOLOR      = 0xFF00FF00,
		ARCHIVECOLOR    = 0xFFFF00CC,
		MARKEDCOLOR     = 0x2AFF00FF,
		FTPCOLOR		= 0xFFFF66FF,
		PERCENTCOLOR	= 0x6426004D,
		BATTERYCOLOR	= 0x6453CE43,
		LOWBATTERYCOLOR	= 0xFF0000B3,
		GRADRECTCOLOR	= 0x64330066,
		GRADSHADOWCOLOR = 0xC8FFFFFF,
	}

	function parseTheme(filename,default)
		for line in io.lines(filename) do
			if not line:find("#") and not (line:len()==0) then --ignorar líneas con # o en blanco
				local k,v = line:match("(.+)=(.+)")
					if tonumber(v) then --filtrar valores no numéricos
						local tmpk=""
							for i=1,k:len() do if string.byte(k:sub(i,i))>47 then tmpk=tmpk..k:sub(i,i) end end --limpieza de index!
						default[tmpk] = tonumber(v) --No hace falta limpiar el valor, se limpia solo
					end
			end
		end
	end

	parseTheme(path.."theme.ini",theme.style)

	fnt, __USERFNT = nil,false
	if files.exists(string.format("%s%s",path,"font.ttf")) then
		fnt = font.load(string.format("%s%s",path,"font.ttf"))
	elseif files.exists(string.format("%s%s",path,"font.pgf")) then
		fnt = font.load(string.format("%s%s",path,"font.pgf"))
	elseif files.exists(string.format("%s%s",path,"font.pvf")) then
		fnt = font.load(string.format("%s%s",path,"font.pvf"))
	end

	if fnt then	font.setdefault(fnt)
		__USERFNT = true
	else font.setdefault(__FNT) end

end
	
function reload_theme()

	write_config()

	local vbuff = screen.toimage()
	local titlew = string.format(strings.wait)
	local w,h = screen.textwidth(titlew,1) + 30,70
	local x,y = 480 - (w/2), 272 - (h/2)

	if vbuff then vbuff:blit(0,0) end
	draw.fillrect(x,y,w,h,theme.style.BARCOLOR)
	draw.rect(x,y,w,h,color.white)
		screen.print(480,y+13,titlew,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
	screen.flip()

	theme.load()

	local manager_path = __PATHTHEMES..__THEME.."/themesmanager.png"
	if not files.exists(manager_path) then manager_path = "system/theme/default/themesmanager.png" end

	themesimg = image.load(manager_path)

end

function theme.manager()

	local thlist = files.listdirs(__PATHTHEMES)
	if not thlist then os.message(strings.notthemesmenu.."\n\n"..__PATHTHEMES) return end

	local list = {}
	for i=1,#thlist do

		local title = ini.read(thlist[i].path.."/theme.ini","TITLE","Unknow")
		local author = ini.read(thlist[i].path.."/theme.ini","AUTHOR","Unknow")
		local preview = image.load(thlist[i].path.."/preview.png")
		if preview then preview:resize(252,151) end

		table.insert(list,{id=thlist[i].name,title = title, author = author, preview = preview})
	end

	local theme_list = newScroll(list,15)
	if theme_list.maxim <= 0 then os.message(strings.notthemesmenu.."\n\n"..__PATHTHEMES) return end
	
	local manager_path = __PATHTHEMES..__THEME.."/themesmanager.png"
	if not files.exists(manager_path) then manager_path = "system/theme/default/themesmanager.png" end
	themesimg = image.load(manager_path)

	while true do

		buttons.read()

		if buttons.up or buttons.analogly < -60 then theme_list:up() end
		if buttons.down or buttons.analogly > 60 then theme_list:down() end

		if buttons[accept] and list[theme_list.sel].id != __THEME then
			__THEME = list[theme_list.sel].id
			__BACKG = ""
			reload_theme()
		end

		if buttons.start and __THEME != "default" then
			__THEME = "default"
			__BACKG = ""
			reload_theme()
		end

		if themesimg then themesimg:blit(0,0) end

		--Print info
		screen.print(480,15,strings.themesappman,1,theme.style.TITLECOLOR,color.gray,__ACENTER)
		local y = 70
		for i=theme_list.ini,theme_list.lim do
			if i == theme_list.sel then

				if list[i].preview then	list[i].preview:blit(700,84) end

				screen.print(700+126,240,list[i].author or "unk",1.0,theme.style.TITLECOLOR,color.gray,__ACENTER)
				draw.fillrect(15,y-3,675,25,theme.style.SELCOLOR)
			end 
			screen.print(20,y,list[i].title,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
			y+=26
		end

		screen.print(15,520,strings.themeactual..__THEME,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ALEFT)

		if theme.data["buttons2"] then
			theme.data["buttons2"]:blitsprite(960-30,515,1)--start
		end
		screen.print(960-40,520,strings.reload,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ARIGHT)
	
		screen.flip()

		if buttons[cancel] then break end
	end
end
