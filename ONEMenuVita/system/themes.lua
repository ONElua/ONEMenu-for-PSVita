--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

__THEME = "default"
__SLIDES = 100
__PIC1 = 0
__USERFNT = false

theme = { -- Module theme :P
	data = {}, -- Handle of imgs xD
	style = {}, -- Handle of colors xD
}

-- Local Values :D
local root_themes = "ux0:data/ONEMENU/themes/" -- Path of themes folder...

flag_themes = false
function theme.load()

	if flag_themes then
		theme.data = {}
		theme.style = {}
		collectgarbage("collect")
	end
	local id = ini.read(__PATHINI,"theme","id","default") -- Get the id of theme pack xD
	__THEME = id
	__SLIDES = tonumber(ini.read(__PATHINI,"slides","pos",100))
	__BACKG = ini.read(__PATHINI,"backg","img","")
	__PIC1 = tonumber(ini.read(__PATHINI,"pics","show","0"))
	__FNT = tonumber(ini.read(__PATHINI,"font","type","2"))

	local path = root_themes..id.."/"
	if not files.exists(path) then
		path = "system/theme/default/"
	end
	-- Removed callbacks, and rename searchvpk to generic list
	local elements = {
		{name="menu"},
		{name="list"},
		{name="themesmanager"},
		{name="ftp"},
		{name="music"},
		{name="cover"},
		{name="icons",sprite=true, w=16,h=16}, 		-- 112x16
		{name="buttons1",sprite=true, w=20,h=20}, 	-- 120*20
		{name="buttons2",sprite=true, w=30,h=20}, 	-- 120*20
		--new
		{name="wifi",sprite=true, w=22,h=22},
		{name="psvita"},
		{name="psm"},
		{name="psp"},
		{name="ps1"},
		{name="adrbb"},
		{name="icodef"},

		--{name="jump", sound=true}, 
--		{name="slide", sound=true}, 
	}
	-- Load Resources :D
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
	
	for i=1,#elements do
		if files.exists(string.format("%s%s.png",path,elements[i].name)) or files.exists(string.format("%s%s.ogg",path,elements[i].name)) then
			if elements[i].sound then
				theme.data[elements[i].name] = sound.load(string.format("%s%s.ogg",path,elements[i].name))--,1)
			elseif elements[i].sprite then
				theme.data[elements[i].name] = image.load(string.format("%s%s.png",path,elements[i].name),elements[i].w,elements[i].h)
			else
				theme.data[elements[i].name] = image.load(string.format("%s%s.png",path,elements[i].name))
			end
		else
			if elements[i].sound then
				theme.data[elements[i].name] = sound.load(string.format("%s%s.ogg","system/theme/default/",elements[i].name))--,1)
			elseif elements[i].sprite then
				theme.data[elements[i].name] = image.load(string.format("%s%s.png","system/theme/default/",elements[i].name),elements[i].w,elements[i].h)
			else
				theme.data[elements[i].name] = image.load(string.format("%s%s.png","system/theme/default/",elements[i].name))
			end
		end
	end

	theme.style = {
		TXTCOLOR		= 0xFFFFFFFF,
		TXTBKGCOLOR		= 0x64000000,
		BARCOLOR        = 0x64330066,
		TITLECOLOR      = 0xFF9999FF,
		PATHCOLOR       = 0xA09999FF,
		DATETIMECOLOR   = 0xFF7300E6,
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
					default[tmpk] = tonumber(v) --No hace falta limpiar el valor, se limpia solo creo xD
				end
		end
	end
end

parseTheme(path.."theme.ini",theme.style)

-- TODO: move this to correct script :P
	isopened = { png = theme.style.IMAGECOLOR, jpg = theme.style.IMAGECOLOR, gif = theme.style.IMAGECOLOR, bmp = theme.style.IMAGECOLOR,
		mp3 = theme.style.MUSICCOLOR, ogg = theme.style.MUSICCOLOR, wav = theme.style.MUSICCOLOR,
		iso = theme.style.BINCOLOR, pbp = theme.style.BINCOLOR, cso = theme.style.BINCOLOR, dax = theme.style.BINCOLOR, bin = theme.style.BINCOLOR, suprx = theme.style.BINCOLOR, skprx = theme.style.BINCOLOR,
		zip = theme.style.ARCHIVECOLOR, rar = theme.style.ARCHIVECOLOR, vpk = theme.style.ARCHIVECOLOR, gz = theme.style.ARCHIVECOLOR,
		sfo = theme.style.SFOCOLOR,
	}

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

	flag_themes = true
end
	
theme.load()

-- TODO: add option to reload a default theme :P
--	 Add scroll xD :P

function reload_theme()
	write_config()

	local vbuff = screen.toimage()
	local titlew = string.format(strings.wait)
	local w,h = screen.textwidth(titlew,1) + 30,70
	local x,y = 480 - (w/2), 272 - (h/2)

	if vbuff then vbuff:blit(0,0) elseif theme.data["themesmanager"] then theme.data["themesmanager"]:blit(0,0) end
	draw.fillrect(x,y,w,h,theme.style.BARCOLOR)
	draw.rect(x,y,w,h,color.white)
		screen.print(480,y+13, strings.wait,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
	screen.flip()

	theme.load()
end

function theme.manager()

	local thlist = files.listdirs(root_themes)
	if not thlist then os.message(strings.notthemesmenu.."\n\nux0:data/ONEMENU/themes/") return end

	local list = {}
	for i=1,#thlist do

		local title = ini.read(thlist[i].path.."/theme.ini","TITLE","Unknow")
		local author = ini.read(thlist[i].path.."/theme.ini","AUTHOR","Unknow")
		local preview = image.load(thlist[i].path.."/preview.png")
		if preview then preview:resize(252,151) end

		table.insert(list,{id=thlist[i].name,title = title, author = author, preview = preview})
	end

	local theme_list = newScroll(list,15)
	if theme_list.maxim <= 0 then os.message(strings.notthemesmenu.."\n\nux0:data/ONEMENU/themes/") return end
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

		if theme.data["themesmanager"] then theme.data["themesmanager"]:blit(0,0) end

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

		if __THEME != "default" then
			if theme.data["buttons2"] then
				theme.data["buttons2"]:blitsprite(960-30,515,1)--start
			end
			screen.print(960-40,520,strings.reload,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ARIGHT)
		end
	
		screen.flip()

		if buttons[cancel] then break end
	end
end
