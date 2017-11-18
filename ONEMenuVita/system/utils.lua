--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

-- Create a folder work
files.mkdir("ux0:data/onemenu/themes/")
files.mkdir("ux0:data/onemenu/lang/")

if os.getreg("/CONFIG/DATE/", "time_format" , 1) == 1 then _time = "%R" else _time = "%r" end
	 
__LANG = os.language()
if not files.exists("ux0:data/onemenu/lang/english_us.txt") then files.copy("system/lang/english_us.txt","ux0:data/onemenu/lang/") end

--135v1,137v1.01
if files.exists("ux0:data/onemenu/lang/"..__LANG..".txt") then
	dofile("ux0:data/onemenu/lang/"..__LANG..".txt")
	local cont = 0
	for key,value in pairs(strings) do cont += 1 end
	if cont < 137 then dofile("system/lang/english_us.txt") end
else
	if files.exists("system/lang/"..__LANG..".txt") then dofile("system/lang/"..__LANG..".txt") 
	else dofile("system/lang/english_us.txt") end
end

__PATHINI = "ux0:data/onemenu/config.ini"
if not files.exists(__PATHINI) then
	ini.write(__PATHINI,"theme","id","default")
	ini.write(__PATHINI,"slides","pos","100")
end

-- Create a globals
SYMBOL_CROSS	= string.char(0xe2)..string.char(0x95)..string.char(0xb3)
SYMBOL_SQUARE	= string.char(0xe2)..string.char(0x96)..string.char(0xa1)
SYMBOL_TRIANGLE	= string.char(0xe2)..string.char(0x96)..string.char(0xb3)
SYMBOL_CIRCLE	= string.char(0xe2)..string.char(0x97)..string.char(0x8b)

__AVATAR = "ur0:user/00/np/myprofile.dat"
avatar = nil

__ID = os.titleid()
vpkdel,_print,game_move = false,true,false

Dev = 1
partitions = {"ux0:","ur0:","uma0:","gro0:","grw0:", "imc0:", }
Root,Root2 ={},{}

local i=1
while files.exists(partitions[i]) do
	table.insert(Root,partitions[i])
	table.insert(Root2,partitions[i])
	i+=1
end
infosize = os.devinfo(Root[Dev])

accept,cancel = "cross","circle"
textXO = "O: "
accept_x = 1
if buttons.assign()==0 then
	accept,cancel = "circle","cross"
	textXO = "X: "
	accept_x = 0
end

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

function files.readlinesSFO(path)
	local sfo = game.info(path)
	if not sfo then return nil end
	local data = {}
	for k,v in pairs(sfo) do
		table.insert(data,tostring(k).." = "..tostring(v))
	end
	return data
end

function files.readlines(path,index) -- Lee una table o string si se especifica linea
	if files.exists(path) then
		local contenido = {}
		for linea in io.lines(path) do
			table.insert(contenido,linea)
		end

		if index == nil then return contenido
		else return contenido[index] end
	end
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
			if avatar then avatar:resize(35,35) end
		end
		databin = nil
	end
end
