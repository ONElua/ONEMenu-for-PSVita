--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

game.close()

--Obtener iconos en modo hilo
dofile("init.lua")

-- Inicializar variables y funciones comunes
dofile("system/utils.lua")

dofile("git/shared.lua")
if __UPDATE == 1 then
	local wstrength = wlan.strength()
	if wstrength then
		if wstrength > 55 then dofile("git/updater.lua") end
	end
end

-- Load Theme Application
dofile("system/themes.lua")

-- swipeLib, by RoberGalarga @ Team ONElua
dofile("system/swipeLib.lua")

--Modulos para el Administrador Burbujas Apps
dofile("system/appmanager/appman.lua")
dofile("system/appmanager/menu.lua")
dofile("system/appmanager/system.lua")

--Modulos para el Explorador de Archivos
dofile("system/explorer/commons.lua")     -- Load Functions Commons
dofile("system/explorer/explorer.lua")    -- Load Explorer File
dofile("system/explorer/callbacks.lua")   -- Load Callbacks
dofile("system/explorer/favorites.lua")   -- Secction Favorites
dofile("system/explorer/refresh.lua")     -- Secction Refresh LiveaArea
dofile("system/explorer/customthemes.lua")-- Secction livearea Customthemes

appman.launch()                           -- Main Cycle :D
