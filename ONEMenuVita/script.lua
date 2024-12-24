--[[ 
    ONEMenu
    Application, themes and files manager.
    
    Licensed by Creative Commons Attribution-ShareAlike 4.0
    http://creativecommons.org/licenses/by-sa/4.0/
    
    Designed By Gdljjrod & DevDavisNunez.
    Collaborators: BaltazaR4 & Wzjk.
]]

--Obtener iconos en modo hilo
dofile("init.lua")

-- Inicializar variables y funciones comunes
dofile("system/utils.lua")

dofile("git/shared.lua")
if __UPDATE == 1 then
	dofile("git/updater.lua")
end

day = tonumber(os.date("%d"))
month = tonumber(os.date("%m"))
snow = false
if (month == 12 and (day >= 20 and day <= 25)) then snow = true end
dofile("addons/stars.lua")

dofile("system/scroll.lua")

-- Load Theme Application
dofile("system/themes.lua")

-- swipeLib, by RoberGalarga (RG) @ Team ONElua
dofile("system/swipeLib.lua")

--Modulos para el Administrador Burbujas Apps
dofile("system/appmanager/appsystem.lua")
dofile("system/appmanager/appman.lua")
dofile("system/appmanager/menu.lua")
dofile("system/appmanager/system.lua")

--Modulos para el Explorador de Archivos
dofile("system/explorer/commons.lua")     -- Commons
dofile("system/explorer/explorer.lua")    -- Explorer File
dofile("system/explorer/callbacks.lua")   -- Callbacks
dofile("system/explorer/refresh.lua")     -- Refresh LiveaArea
dofile("system/explorer/customthemes.lua")-- Livearea Customthemes
dofile("system/explorer/system.lua")
dofile("system/mf.lua")

appman.launch()                           -- Main Cycle :D
