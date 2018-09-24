--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

SIZES_PORT_O = channel.new("SIZES_PORT_I")
SIZES_PORT_I = channel.new("SIZES_PORT_O")

while true do
	if SIZES_PORT_I:available() > 0 then
		local entry = SIZES_PORT_I:pop()
		--( {cat = cat, focus = focus_index, path = appman[cat].list[focus_index].path, id = appman[cat].list[focus_index].id } )
		entry.size, entry.folders, entry.filess = files.size(entry.path)
		entry.sizef = files.sizeformat(entry.size or 0)
		entry.sizef_patch = files.sizeformat(files.size("ux0:patch/"..entry.id or 0))
		entry.sizef_repatch = files.sizeformat(files.size("ux0:repatch/"..entry.id or 0))
		entry.sizef_addcont = files.sizeformat(files.size("ux0:addcont/"..entry.id or 0))
		entry.sizef_readdcont = files.sizeformat(files.size("ux0:readdcont/"..entry.id or 0))
		SIZES_PORT_O:push(entry)
	end
	os.delay(16) -- ONE frame
end
