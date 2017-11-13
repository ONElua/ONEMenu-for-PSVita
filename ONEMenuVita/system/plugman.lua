--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

plugman = { -- Modulo Plugins Manager.
	cfg = {}, -- Have original state of file.
	list = {}, -- Handle list of plugins.
	scroll = newScroll({},10), -- Scroll of plugins.
	gameid = "", -- Gameid of select.
}


function plugman.load()

    local path = "ur0:tai/config.txt"
	plugman.cfg = {} -- Set to Zero
	plugman.list = {} -- Set to Zero

	if files.exists(path) then
		local id_sect = nil
		local i = 1;
		for line in io.lines(path) do
			table.insert(plugman.cfg,line)

			if line:find("*",1) then -- Secction Found
				id_sect = line:sub(2)
				if not plugman.list[id_sect] then plugman.list[id_sect] = {sectln = i} end
				--continue 
			--end
			else 
			
				if id_sect then
					if #line > 0 then
						local state = line:find("#",1)
						line = line:gsub('#',''):lower()
						if line:sub(1,4) == "ux0:" or line:sub(1,4) == "ur0:" then
							--os.message(id_sect.." "..plugman.list[id_sect].sectln.." ln "..line.." "..i) 
							table.insert(plugman.list[id_sect], {name = files.nopath(line), path = line, line = i, state = state} )
						end
					end
				end
			end--
			
			i += 1
		end
	end

end
