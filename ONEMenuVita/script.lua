--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

game.close()
color.loadpalette()

dofile("system/utils.lua") 									-- Extra funtions
dofile("system/themes.lua")									-- Load Theme Application

local wstrength = wlan.strength()
if wstrength then dofile("git/updater.lua") end

dofile("system/explorer/commons.lua")						-- Load Functions Commons
dofile("system/explorer/explorer.lua")						-- Load Explorer File
dofile("system/explorer/callbacks.lua")						-- Load Callbacks
dofile("system/plugman.lua")								-- Load PluginsManager in WIP
dofile("system/appman.lua")									-- Load AppManager
dofile("system/menu.lua")
dofile("system/scan.lua")									-- Load Search vpks 
dofile("system/customtheme.lua")							-- Load Manager of livearea themes...
dofile("system/advanced.lua")								-- Load Advanced Options
dofile("system/system.lua")									-- System Apps 

appman.launch()												-- Main Cycle :D
