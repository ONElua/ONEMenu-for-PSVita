__kernel, __user = false,false

--Creamos nuestra carpeta principal de Trabajo
files.mkdir("ux0:data/ONEMENU/")

__PATH_INI    = "ux0:data/ONEMENU/config.ini"
__PATH_THEMES = "ux0:data/ONEMENU/themes/"

__THEME = ini.read(__PATH_INI,"theme","id","default")
files.mkdir(__PATH_THEMES)

__ID        = os.titleid()

---------------------Buscamos icono por defecto y splash----------------------
local splash = nil
splash = image.load(__PATH_THEMES..__THEME.."/splash.png") or image.load("system/theme/default/splash.png")

--Show Splash
if splash then splash:blit(0,0) end
screen.flip()

iconDef = image.load(__PATH_THEMES..__THEME.."/icodef.png") or image.load("system/theme/default/icodef.png")

-- Convert 4 bytes (32 bit) string to number int...
function str2int(str)
	local b1, b2, b3, b4 = string.byte(str, 1, 4)
	return (b4 << 24) + (b3 << 16) + (b2 << 8) + b1
end

-- Convert Number (32bit) to a string 4 bytes...
function int2str(data)
	return string.char((data)&0xff)..string.char(((data)>>8)&0xff)..string.char(((data)>>16)&0xff)..string.char(((data)>>24)&0xff)
end

------------------Busqueda y peticion de Iconos en modo hilo------------------
__CATEGORIES = 5
appman,static_void,cats = {},{},{ "psvita", "hbvita", "adrbb", "retro", "psm" }
for i=1,__CATEGORIES do
	table.insert(appman, { list={}, scroll, sort = 0, slide = { img = nil, x=0 , acel=7, w= 0 }, cats = cats[i] } )
	static_void[i] = {x=1}
end
cat, appman.len = 0,0

IMAGE_PORT_I = channel.new("IMAGE_PORT_I")
IMAGE_PORT_O = channel.new("IMAGE_PORT_O")
THID_IMAGE = thread.new("system/appmanager/thread_img.lua")

--Region
regions = { A=1,E=2,J=3,U=4 }
name_region = { "(A)","(E)","(J)","(U)", "" }

function fillappman(obj)

	if obj.id == __ID then return end

	obj.save = obj.id
	obj.path_pic = "ur0:appmeta/"..obj.id.."/pic0.png"

	local index = 1
	if obj.type == "mb" or obj.type == "mba" then
		index = 5
		obj.resize = true
		obj.path_img = "ur0:appmeta/"..obj.id.."/pic0.png"
	elseif obj.type == "EG" or obj.type == "ME" then
		index = 4
		obj.resize = true
		obj.path_img = "ur0:appmeta/"..obj.id.."/livearea/contents/startup.png"
	else

		if obj.id == "PSPEMUCFW" then index = 2
		else

			if tonumber(obj.sdk) > 661 then
				local sfo = game.info(obj.path.."/sce_sys/param.sfo")

				if sfo and sfo.INSTALL_DIR_SAVEDATA then
					obj.save = sfo.INSTALL_DIR_SAVEDATA
				end

				if sfo and sfo.CONTENT_ID then

					if sfo.CONTENT_ID:len() > 9 then
						index = 1
						obj.region = regions[sfo.CONTENT_ID[1]] or 5
					end
				end
			elseif tonumber(obj.sdk) == 0 then
				obj.region = 5
				
				--checking magic
				local fp = io.open(obj.path.."/data/boot.bin","r")
				if fp then
					local magic = str2int(fp:read(4))
					fp:close()
					if magic == 0x00424241 then	index = 3 else index = 2 end
				else
					index = 2
				end

			end

		end
		obj.path_img = "ur0:appmeta/"..obj.id.."/icon0.png"

	end
	obj.Nregion = name_region[obj.region] or ""

	obj.img = iconDef
	if obj.resize then obj.img:resize(120,100) else obj.img:resize(120,120) end
	obj.img:setfilter(__IMG_FILTER_LINEAR, __IMG_FILTER_LINEAR)

	appman.len += 1

	table.insert(appman[index].list,obj)

	-- Push request of icon! :D
	local tempo = appman[index].list[ #appman[index].list ]
	static_void[index][#appman[index].list] = tempo
	IMAGE_PORT_O:push( { x = #appman[index].list, y = index, path = tempo.path_img, resize = tempo.resize or false } )

end

--Asia,Eur,Jpn,Usa,Unk	<-- Asc: 1,2,3,4,5
--Unk,Usa,Jpn,Eur,Asia	<-- Des: 5,4,3,2,1

function tableSortRegAsc(a,b)
	return (tonumber(a.region) < tonumber(b.region)) or (tonumber(a.region) == tonumber(b.region) and a.id < b.id)
end

function tableSortRegDesc(a,b)
	return (tonumber(a.region) > tonumber(b.region)) or (tonumber(a.region) == tonumber(b.region) and a.id < b.id)
end

function SortGeneric(tb,sort,asc)

	if sort == 0 then
		if asc == 1 then
			table.sort(tb, function (a,b) return string.lower(a.id)<string.lower(b.id) end)
		else
			table.sort(tb, function (a,b) return string.lower(a.id)>string.lower(b.id) end)
		end
	elseif sort == 1 then
		if asc == 1 then
			table.sort(tb, function (a,b) return string.lower(a.title)<string.lower(b.title) end)
		else
			table.sort(tb, function (a,b) return string.lower(a.title)>string.lower(b.title) end)
		end
	elseif sort == 2 then
		if asc == 1 then
			table.sort(tb, tableSortRegAsc)
		else
			table.sort(tb, tableSortRegDesc)
		end
	end

end

function SortSdkId(a,b)
	return (tonumber(a.sdk) > tonumber(b.sdk)) or (tonumber(a.sdk) == tonumber(b.sdk) and a.id < b.id)
end

function SortSdkTitle(a,b)
	return (tonumber(a.sdk) > tonumber(b.sdk)) or (tonumber(a.sdk) == tonumber(b.sdk) and a.title < b.title)
end

function Scanning()

	-- Init with Max CPU/GPU
	__CPU = os.cpu()
	os.cpu(444)
	__GPU = os.gpuclock()
	os.gpuclock(166)

	--id, type, version, dev, path, title
	local list_tmp = game.list(__GAME_LIST_ALL)
	table.sort(list_tmp,SortSdkId)

	local list = {}
	for i=1,#list_tmp do
		if files.exists(list_tmp[i].path) then
			if list_tmp[i].title then list_tmp[i].title = list_tmp[i].title:gsub("\n"," ") end
			if tonumber(list_tmp[i].sdk) > 661 or tonumber(list_tmp[i].sdk) == 0 then
				fillappman(list_tmp[i])
			else
				table.insert(list,list_tmp[i])
			end
		end
	end

	for i=1,#list do
		fillappman(list[i])
	end

	for i=1, __CATEGORIES do
		if cat == 0 and #appman[i].list > 0 then
			cat = i
			break
		end
	end

	--return CPU/GPU
	os.cpu(__CPU)
	os.gpuclock(__GPU)

end
------------------Busqueda y peticion de Iconos en modo hilo------------------

Scanning()
