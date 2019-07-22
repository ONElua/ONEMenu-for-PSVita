--[[ 
	ONEMenu
	Application, themes and files manager.

	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

__PATH_LANG = "ux0:data/ONEMENU/lang/"
__LANG      = os.language()

langs = {	JAPANESE = 		"00",
			ENGLISH_US = 	"01",
			FRENCH = 		"02",
			SPANISH = 		"03",
			GERMAN = 		"04",
			ITALIAN = 		"05",
			DUTCH = 		"06",
			PORTUGUESE = 	"07",
			RUSSIAN = 		"08",
			KOREAN = 		"09",
			CHINESE_T = 	"10",
			CHINESE_S = 	"11",
			FINNISH = 		"12",
			SWEDISH = 		"13",
			DANISH = 		"14",
			NORWEGIAN = 	"15",
			POLISH = 		"16",
			PORTUGUESE_BR = "17",
			ENGLISH_GB = 	"18",
			TURKISH = 		"19",
};
 

-- Creamos carpeta de trabajo para los idiomas
files.mkdir(__PATH_LANG)

-- Loading language file
dofile("system/lang/english_us.txt")
if not files.exists(__PATH_LANG.."english_us.txt") then files.copy("system/lang/english_us.txt",__PATH_LANG) end
if files.exists(__PATH_LANG..__LANG..".txt") then dofile(__PATH_LANG..__LANG..".txt") end

color.loadpalette()

__UPDATE = tonumber(ini.read(__PATH_INI,"update","update","1"))
_update = STRINGS_APP_NO
if __UPDATE == 1 then _update = STRINGS_APP_YES end

dofile("git/shared.lua")
if __UPDATE == 1 then
    local wstrength = wlan.strength()
    if wstrength then
        if wstrength > 55 then dofile("git/updater.lua") end
    end
end

SYMBOL_SQUARE	= string.char(0xe2)..string.char(0x96)..string.char(0xa1)
SYMBOL_TRIANGLE	= string.char(0xe2)..string.char(0x96)..string.char(0xb3)

function buttons_reasign()
	textXO = "O: "
	accept_x = 1
	SYMBOL_CROSS	= string.char(0xe2)..string.char(0x95)..string.char(0xb3)
	SYMBOL_CIRCLE	= string.char(0xe2)..string.char(0x97)..string.char(0x8b)
	if buttons.assign()==0 then
		textXO = "X: "
		accept_x = 0
		SYMBOL_CROSS	= string.char(0xe2)..string.char(0x97)..string.char(0x8b)
		SYMBOL_CIRCLE	= string.char(0xe2)..string.char(0x95)..string.char(0xb3)
	end
end

buttons_reasign()

if os.getreg("/CONFIG/DATE/", "time_format" , 1) == 1 then _time = "%R" else _time = "%r" end

--Get avatar
function getavatar(path)

	f = io.open(path)
	if f then
		local profile,tmp = "",""
		f:seek ("cur", 0x38)
		tmp = f:read(1)
		profile = tmp
		while tmp != "0x00" do
			tmp = f:read(1)
			if tmp then
				profile = profile..tmp
			else
				break
			end
		end
		f:close()

		local databin = nil
		databin = http.get(profile)
		if databin then
			avatar = image.loadfromdata(databin,__IMAGE_TYPE_PNG)
			if avatar then
				avatar:resize(35,35)
				image.save(avatar, "ux0:data/ONEMENU/avatar.png")
			end
		end
		databin = nil
	end
end

--Load avatar
if files.exists("ux0:data/ONEMENU/avatar.png") then
	avatar = image.load("ux0:data/ONEMENU/avatar.png")
	if avatar then avatar:resize(35,35) end
else
	local wstrength = wlan.strength()
	if wstrength then
		if wstrength > 55 then getavatar("ur0:user/00/np/myprofile.dat") end
	end
end

--Globals
function infodevices()

	if files.exists("ux0:") then
		infoux0 = os.devinfo("ux0:")
		if infoux0 then
			infoux0.maxf = files.sizeformat(infoux0.max or 0)
			infoux0.freef = files.sizeformat(infoux0.free or 0)
			infoux0.usedf = files.sizeformat(infoux0.used or 0)
		end
	end

	if files.exists("ur0:") then
		infour0 = os.devinfo("ur0:")
		if infour0 then
			infour0.maxf = files.sizeformat(infour0.max or 0)
			infour0.freef = files.sizeformat(infour0.free or 0)
			infour0.usedf = files.sizeformat(infour0.used or 0)
		end
	end

	if files.exists("uma0:") then
		infouma0 = os.devinfo("uma0:")
		if infouma0 then
			infouma0.maxf = files.sizeformat(infouma0.max or 0)
			infouma0.freef = files.sizeformat(infouma0.free or 0)
			infouma0.usedf = files.sizeformat(infouma0.used or 0)
		end
	end

end
infodevices()

function write_config()
	ini.write(__PATH_INI,"theme","id",__THEME)
	ini.write(__PATH_INI,"update","update",__UPDATE)
	ini.write(__PATH_INI,"backg","img",__BACKG) 
	ini.write(__PATH_INI,"slides","pos",__SLIDES)
	ini.write(__PATH_INI,"pics","show",__PIC1)
--sort for categories
	for i=1,#appman do
		if i==1 then
			ini.write(__PATH_INI,"sort","sort",appman[i].sort)
			ini.write(__PATH_INI,"sort","asc",appman[i].asc)
		else
			ini.write(__PATH_INI,"sort","sort"..i,appman[i].sort)
			ini.write(__PATH_INI,"sort","asc"..i,appman[i].asc)
		end
	end
--sort for sys apps
	ini.write(__PATH_INI,"sys","sort",system.sort)
end

function message_wait(message)
	local mge = (message or STRINGS_WAIT_MGE)
	local titlew = string.format(mge)
	local w,h = screen.textwidth(titlew,1) + 30,70
	local x,y = 480 - (w/2), 272 - (h/2)

	draw.fillrect(x,y,w,h,theme.style.BARCOLOR)
	draw.rect(x,y,w,h,color.white)
		screen.print(480,y+13, titlew,1,color.white,color.black,__ACENTER)
	screen.flip()
end

function isTouched(x,y,sx,sy)
	if math.minmax(touch.front[1].x,x,x+sx)==touch.front[1].x and math.minmax(touch.front[1].y,y,y+sy)==touch.front[1].y then
		return true
	end
	return false
end
