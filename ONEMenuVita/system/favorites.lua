--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

function favorites_manager()

	local srcn = newScroll(apps,15)
	buttons.interval(10,10)

	if __FAV == 1 then fav = strings.yes else fav = strings.no end
	while true do
		buttons.read()

		if theme.data["list"] then theme.data["list"]:blit(0,0) end

		screen.print(480,15,strings.favorites,1,theme.style.TITLECOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
		screen.print(950,15,strings.count + srcn.maxim,1,theme.style.COUNTCOLOR,theme.style.TXTBKGCOLOR,__ARIGHT)

		if srcn.maxim > 0 then

			if buttons.up or buttons.analogly < -60 then srcn:up() end
			if buttons.down or buttons.analogly > 60 then srcn:down() end

			local y = 70
			for i=srcn.ini,srcn.lim do
				if i == srcn.sel then draw.fillrect(10,y-2,930,23,theme.style.SELCOLOR) end

				screen.print(20,y,string.format("%02d",i)+' ) '+ apps[i],1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)

				y+=26
			end

		else
			screen.print(480,272,strings.empty,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
		end

		if buttons.start then
			if __FAV == 1 then
				__FAV,fav = 0,strings.no
				write_config()
			else
				if srcn.maxim > 0 then
					__FAV,fav = 1,strings.yes
					write_config()
				else
					os.message(strings.nofavorites)
				end
			end
		end

		if buttons.select and srcn.maxim > 0 then
			if os.message(strings.emptyfav,1) == 1 then
				apps={}
				srcn:set(apps,15)
				if __FAV == 1 then __FAV,fav = 0,strings.no end
				write_favs(__PATH_FAVS)
				write_config()

				for i=1, #appman do
					for j=1, #appman[i].list do
						if appman[i].list[j].fav then appman[i].list[j].fav = false end
					end
				end
			end
		end

		if buttons.square and srcn.maxim > 0 then
			if os.message(strings.delfavorites,1) == 1 then
				for i=1, #appman do
					for j=1, #appman[i].list do
						if appman[i].list[j].id == apps[srcn.sel] then appman[i].list[j].fav = false end
					end
				end
				table.remove(apps,srcn.sel)
				srcn:set(apps,15)

				write_favs(__PATH_FAVS)

				if srcn.maxim <=0 then
					if __FAV == 1 then __FAV,fav = 0,strings.no end
				end
				write_config()
			end
		end

		if theme.data["buttons2"] then
			theme.data["buttons2"]:blitsprite(5,515,0)--select
		end
		screen.print(40,520,strings.removefav,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)

		if theme.data["buttons2"] then
			theme.data["buttons2"]:blitsprite(960-30,515,1)--start
		end
		screen.print(960-40,520,strings.activate..fav,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ARIGHT)

		screen.flip()

		shortcuts()

		if buttons[cancel] then	os.delay(55) break end
	end
end
