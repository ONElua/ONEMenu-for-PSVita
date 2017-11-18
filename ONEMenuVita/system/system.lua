--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

uri = {}
uri["NPXS10000"] = "near:"
uri["NPXS10001"] = "pspy:"
uri["NPXS10002"] = "psns:browse?category=STORE-MSF73008-VITAGAMES"--"psns:browse?category="
uri["NPXS10003"] = "wbapp0:"
--uri["NPXS10004"] = "camera:"
--uri["NPXS10006"] = "pspr:"			--friends
--uri["NPXS10007"] = ""					--welcome park
uri["NPXS10008"] = "pstc:"
uri["NPXS10009"] = "music:" 
uri["NPXS10010"] = "video:"
--uri["NPXS10012"] = ""					--uso distancia PS3
--uri["NPXS10013"] = ""					--enlace ps4
uri["NPXS10014"] = "psnmsg:"
uri["NPXS10015"] = "settings_dlg:"
--uri["NPXS10026"] = ""					--CMA
uri["NPXS10072"] = "email:"
uri["NPXS10091"] = "scecalendar:"
--uri["NPXS10094"] = ""					--Parental Controls

system = { data = {}, len = 0 }

function system.refresh()

	if system.len == 0 then

		system.data = game.list(__GAME_LIST_SYS)
		table.sort(system.data, function (a,b) return string.lower(a.id)<string.lower(b.id) end)
		system.len = #system.data

		for i=1, system.len do
			if uri[system.data[i].id] then system.data[i].uri = uri[system.data[i].id] end
			if system.data[i].title	then system.data[i].title = system.data[i].title:gsub("\n"," ") end
		end
	end

end

--id, type, version, dev, path, title
function system.run()

	system.refresh()
	
	local scroll = newScroll(system.data,15)

	buttons.interval(10,10)
	while true do
		buttons.read()

		if theme.data["themesmanager"] then theme.data["themesmanager"]:blit(0,0) end
		screen.print(480,15,strings.liveareapps,1,theme.style.TITLECOLOR,color.gray,__ACENTER)

		if system.len > 0 then

			local y = 80
			for i=scroll.ini,scroll.lim do
				if i == scroll.sel then
					draw.fillrect(10,y-2,675,23,theme.style.SELCOLOR)
					if not preview then
						preview = image.load(system.data[i].path.."/sce_sys/icon0.png")
						if preview then preview:setfilter(__LINEAR, __LINEAR) end
					end
				end
				screen.print(15,y, system.data[i].title,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
				y+=26
			end

			if preview then	preview:blit(770,90) end 

			screen.print(10,520,system.data[scroll.sel].id,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
		else
			screen.print(480,15,strings.noliveareapps,1,theme.style.TITLECOLOR,color.gray,__ACENTER)

		end
		screen.flip()
		
		--Controls
		if system.len > 0 then

			if buttons.up or buttons.analogly<-60 then 
				if scroll:up() then	preview = nil end
			end

			if buttons.down or buttons.analogly>60 then
				if scroll:down() then preview = nil	end
			end

			if buttons[accept] then
				if not system.data[scroll.sel].uri then game.open(system.data[scroll.sel].id) else os.uri(system.data[scroll.sel].uri) end
			end

		end

		if buttons.start then
			os.delay(50)
			break
		end

		if (buttons.held.l and buttons.held.r and buttons.up) and reboot then os.restart() end
		if (buttons.held.l and buttons.held.r and buttons.down) and reboot then power.restart() end
		
	end
end
