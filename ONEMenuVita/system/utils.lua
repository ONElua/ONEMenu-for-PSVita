--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

-- Create a folder work
files.mkdir("ux0:data/ONEMENU/themes/")
files.mkdir("ux0:data/ONEMENU/lang/")

--Constants
__PATHINI		= "ux0:data/ONEMENU/config.ini"
__PATH_FAVS		= "ux0:data/ONEMENU/favs.txt"
__PATHTHEMES	= "ux0:data/ONEMENU/themes/"
__PROFILE		= "ur0:user/00/np/myprofile.dat"
__LANG			= os.language()
__ID			= os.titleid()

SYMBOL_CROSS	= string.char(0xe2)..string.char(0x95)..string.char(0xb3)
SYMBOL_SQUARE	= string.char(0xe2)..string.char(0x96)..string.char(0xa1)
SYMBOL_TRIANGLE	= string.char(0xe2)..string.char(0x96)..string.char(0xb3)
SYMBOL_CIRCLE	= string.char(0xe2)..string.char(0x97)..string.char(0x8b)

--Primero checamos traducciones
__STRINGS		= 149								--135v1,137v1.01,145vbeta,146v2.01,147v2.05
if not files.exists("ux0:data/ONEMENU/lang/english_us.txt") then files.copy("system/lang/english_us.txt","ux0:data/ONEMENU/lang/")
else
	dofile("ux0:data/ONEMENU/lang/english_us.txt")
	local cont_strings = 0
	for key,value in pairs(strings) do cont_strings += 1 end
	if cont_strings < __STRINGS then files.copy("system/lang/english_us.txt","ux0:data/ONEMENU/lang/") end
end

if files.exists("ux0:data/ONEMENU/lang/"..__LANG..".txt") then
	dofile("ux0:data/ONEMENU/lang/"..__LANG..".txt")
	local cont_strings = 0
	for key,value in pairs(strings) do cont_strings += 1 end
	if cont_strings < __STRINGS then dofile("system/lang/english_us.txt") end
else
	if files.exists("system/lang/"..__LANG..".txt") then dofile("system/lang/"..__LANG..".txt")
	else dofile("system/lang/english_us.txt") end
end

--Conseguir avatar (Requerido Wifi solo la 1era vez)
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
			avatar = image.loadfromdata(databin,__PNG)
			if avatar then
				avatar:resize(35,35)
				image.save(avatar, "ux0:data/ONEMENU/avatar.png")
			end
		end
		databin = nil
	end
end
if files.exists("ux0:data/ONEMENU/avatar.png") then
	avatar = image.load("ux0:data/ONEMENU/avatar.png")
	if avatar then avatar:resize(35,35) end
else
	local wstrength = wlan.strength()
	if wstrength then
		if wstrength > 55 then getavatar(__PROFILE) end
	end
end

--Globals
infoux0, infour0, infouma0 = {},{},{}
function infodevices()
	infoux0 = os.devinfo("ux0:")
	if files.exists("ur0:") then
		infour0 = os.devinfo("ur0:")
	end
	if files.exists("uma0:") then
		infouma0 = os.devinfo("uma0:")
	end

	infoux0.maxf = files.sizeformat(infoux0.max or 0)
	infour0.maxf = files.sizeformat(infour0.max or 0)
	infouma0.maxf = files.sizeformat(infouma0.max or 0)

	infoux0.freef = files.sizeformat(infoux0.free or 0)
	infour0.freef = files.sizeformat(infour0.free or 0)
	infouma0.freef = files.sizeformat(infouma0.free or 0)

	infoux0.usedf = files.sizeformat(infoux0.used or 0)
	infour0.usedf = files.sizeformat(infour0.used or 0)
	infouma0.usedf = files.sizeformat(infouma0.used or 0)

end

apps = {}
function write_favs(pathini)
    local file = io.open(pathini, "w+")
	file:write("apps = {\n")

	for i=1,#apps do
		if i==#apps then
			file:write(string.format('"%s"\n', tostring(apps[i])))
		else
			file:write(string.format('"%s",\n', tostring(apps[i])))
		end
	end
	file:write("}")
	file:close()
end

--Checamos lista de Favoritos
if files.exists(__PATH_FAVS) then dofile(__PATH_FAVS) else
write_favs(__PATH_FAVS) end

--[[
	## Library Scroll ##
	Designed By DevDavis (Davis Nuñez) 2011 - 2016.
	Based on library of Robert Galarga.
	Create a obj scroll, this is very usefull for list show
	]]
function newScroll(a,b,c)
	local obj = {ini=1,sel=1,lim=1,maxim=1,minim = 1}

	function obj:set(tab,mxn,modemintomin) -- Set a obj scroll
		obj.ini,obj.sel,obj.lim,obj.maxim,obj.minim = 1,1,1,1,1
		--os.message(tostring(type(tab)))
		if(type(tab)=="number")then
			if tab > mxn then obj.lim=mxn else obj.lim=tab end
			obj.maxim = tab
		else
			if #tab > mxn then obj.lim=mxn else obj.lim=#tab end
			obj.maxim = #tab
		end
		if modemintomin then obj.minim = obj.lim end
	end

	function obj:max(mx)
		obj.maxim = #mx
	end

	function obj:up()
		if obj.sel>obj.ini then obj.sel=obj.sel-1 return true
		elseif obj.ini-1>=obj.minim then
			obj.ini,obj.sel,obj.lim=obj.ini-1,obj.sel-1,obj.lim-1
			return true
		end
	end

	function obj:down()
		if obj.sel<obj.lim then obj.sel=obj.sel+1 return true
		elseif obj.lim+1<=obj.maxim then
			obj.ini,obj.sel,obj.lim=obj.ini+1,obj.sel+1,obj.lim+1
			return true
		end
	end

	function obj:up_menu()
		if obj.sel>obj.ini then
			obj.sel-=1

			if obj.sel==1 then 
				if obj.lim-obj.ini>=limit then obj.lim-=1 end
			else obj.ini-=1
				if obj.lim-obj.ini>=limit+1 then obj.lim-=1 end
			end
			return true
		end
	end

	function obj:down_menu()
		if obj.sel<obj.lim then
			obj.sel+=1

			if obj.sel-1==1 then
				if obj.lim+1<=obj.maxim then obj.lim+=1 end
			else obj.ini+=1
				if obj.lim+1<=obj.maxim then obj.lim+=1 end
			end
			return true
		end
	end

	if a and b then
		obj:set(a,b,c)
	end

	return obj

end

function write_config()
	ini.write(__PATHINI,"theme","id",__THEME)
	ini.write(__PATHINI,"backg","img",__BACKG) 
	ini.write(__PATHINI,"slides","pos",__SLIDES)
	ini.write(__PATHINI,"pics","show",__PIC1)
	ini.write(__PATHINI,"font","type",__FNT)
	ini.write(__PATHINI,"favs","scan",__FAV)
end

function message_wait()
	local titlew = string.format(strings.wait)
	local w,h = screen.textwidth(titlew,1) + 30,70
	local x,y = 480 - (w/2), 272 - (h/2)

	draw.fillrect(x,y,w,h,theme.style.BARCOLOR)
	draw.rect(x,y,w,h,color.white)
		screen.print(480,y+13, strings.wait,1,color.white,color.black,__ACENTER)
	screen.flip()
end

function splash_efect(pics,delay,vel)
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
