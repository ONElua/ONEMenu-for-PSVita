--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By DevDavisNunez.
]]

__PATH_THEMES = "ux0:data/ONEMENU/tmp/"

files.mkdir(__PATH_THEMES)

THEME_PORT_O = channel.new("THEME_PORT_I")
THEME_PORT_I = channel.new("THEME_PORT_O")

while true do
	if THEME_PORT_I:available() > 0 then
		local entry = THEME_PORT_I:pop()
		local icon = nil;
		while true do
			if (not files.exists(__PATH_THEMES..entry.id..".png") and http.download("https://raw.githubusercontent.com/ONElua/ONEMenu-for-PSVita/master/Themes/"..entry.id..".png", __PATH_THEMES..entry.id..".png")) or (files.exists(__PATH_THEMES..entry.id..".png")) then
				icon = image.load(__PATH_THEMES..entry.id..".png")
				THEME_PORT_O:push({icon = icon, id = entry.id})
				icon:lost()
				icon = nil
				break;
			end
			os.delay(5)
		end
	end
	os.delay(5)
end

