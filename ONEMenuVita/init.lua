--Creamos nuestra carpeta principal de Trabajo
files.mkdir("ux0:data/ONEMENU/")

__PATH_FAVS   = "ux0:data/ONEMENU/favs.txt"
__PATH_INI    = "ux0:data/ONEMENU/config.ini"
__PATH_THEMES = "ux0:data/ONEMENU/themes/"

__FAV   = tonumber(ini.read(__PATH_INI,"favs","scan","0"))
__THEME = ini.read(__PATH_INI,"theme","id","default")
files.mkdir(__PATH_THEMES)

__ID        = os.titleid()

---------------------Buscamos icono por defecto y splash----------------------
local splash,iconDef = nil,nil
splash = image.load(__PATH_THEMES..__THEME.."/splash.png") or image.load("system/theme/default/splash.png")

--Show Splash
if splash then splash:blit(0,0) end
screen.flip()

iconDef = image.load(__PATH_THEMES..__THEME.."/icodef.png") or image.load("system/theme/default/icodef.png")
------------------------Checamos la lista de Favoritos------------------------
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
	file:write("}\n")
	file:close()
end

if files.exists(__PATH_FAVS) then dofile(__PATH_FAVS) else
write_favs(__PATH_FAVS) end
------------------------Checamos la lista de Favoritos------------------------

------------------Busqueda y peticion de Iconos en modo hilo------------------
__CATEGORIES = 5
appman = {}
for i=1,__CATEGORIES do table.insert(appman, { list={}, scroll, sort = 0, slide = { img = nil, x=0 , acel=7, w= 0 } } ) end
cat, appman.len = 0,0

IMAGE_PORT_I = channel.new("IMAGE_PORT_I")
IMAGE_PORT_O = channel.new("IMAGE_PORT_O")
THID_IMAGE = thread.new("system/appmanager/thread_img.lua")

static_void = {}
for i=1,__CATEGORIES do static_void[i] = {x=1} end

function fillappman(obj)

	if obj.id == __ID then return end

	local index=1

	if obj.type == "mb" then
		index = 3
		obj.resize = true
		obj.path_img = "ur0:appmeta/"..obj.id.."/pic0.png"
	elseif obj.type == "EG" or obj.type == "ME" then
		index = 4
		obj.resize = true
		obj.path_img = "ur0:appmeta/"..obj.id.."/livearea/contents/startup.png"
	else

		if files.exists(obj.path.."/data/boot.inf") or obj.id == "PSPEMUCFW" then
			index = 5
		else
			local sfo = game.info(obj.path.."/sce_sys/param.sfo")
			if sfo and sfo.CONTENT_ID then
				if sfo.CONTENT_ID:len() > 9 then index = 1 else	index = 2 end
			else
				index = 2
			end

		end

		obj.path_img = "ur0:appmeta/"..obj.id.."/icon0.png"

	end

	obj.img = iconDef
	if __FAV == 1 then
		obj.img:resize(120,120)
	else
		if obj.resize then obj.img:resize(120,100) else obj.img:resize(120,120) end
	end
	obj.img:setfilter(__IMG_FILTER_LINEAR, __IMG_FILTER_LINEAR)

	appman.len += 1

	table.insert(appman[index].list,obj)

end

function Scanning()

	-- Init with Max CPU/GPU
	__CPU = os.cpu()
	os.cpu(444)
	__GPU = os.gpuclock()
	os.gpuclock(166)

	--id, type, version, dev, path, title
	local list = game.list(__GAME_LIST_ALL)
	local sort_vita = tonumber(ini.read(__PATH_INI,"sort","sort","0"))
	if sort_vita == 1 then
		table.sort(list, function (a,b) return string.lower(a.title)<string.lower(b.title) end)
	else
		table.sort(list, function (a,b) return string.lower(a.id)<string.lower(b.id) end)
	end

	for i=1,#list do

		if files.exists(list[i].path) then
			if list[i].title then list[i].title = list[i].title:gsub("\n"," ") end
			list[i].fav = false
			for j=1,#apps do
				if list[i].id == apps[j] then list[i].fav = true end
			end

			if __FAV == 1 then
				if list[i].fav then fillappman(list[i]) end--Scan only Favs
			else
				fillappman(list[i])
			end
		end

	end
	
	local y,x = 1,1
	while y <= __CATEGORIES do
		if cat == 0 and appman[y].list[x] then cat = y end
		while appman[y].list[x] do
			-- Push request of icon! :D
			local obj = appman[y].list[x]
			static_void[y][x] = obj
			IMAGE_PORT_O:push( { x = x, y = y, fav = __FAV, path = obj.path_img, resize = obj.resize } )
			x += 1
		end
		y += 1
		x = 1
	end

	if cat <= 0 then appman.len = 0 end

end
------------------Busqueda y peticion de Iconos en modo hilo------------------

Scanning()
