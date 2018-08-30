--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

function customthemes()

	local list = themes.list()
	list.len = #list

	if list.len >0 then
		local i = list.len
		while i > 0 do
			if list[i].id:sub(1,9) != "ux0:theme" then
				list[i].info = themes.info(list[i].id.."/".."theme.xml")
				if list[i].home then
					list[i].preview = image.load(list[i].id.."/"..list[i].home)
					if list[i].preview then
						list[i].preview:resize(252,151)
					end
				end
			else
				table.remove(list,i)
			end

			i -= 1
		end
		list.len = #list

		if list.len<=0 then os.message(STRINGS_CUSTOMTHEMES_EMPTY) return end

		local themesimg = image.load(__PATH_THEMES..__THEME.."/themesmanager.png") or image.load("system/theme/default/themesmanager.png")

		local livetheme = newScroll(list,15)
		while true do

			buttons.read()

			if themesimg then themesimg:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end

			screen.print(480,15,STRINGS_CUSTOMTHEMES_TITLE,1,theme.style.TITLECOLOR,theme.style.TXTBKGCOLOR,__ACENTER)

			if list.len > 0 then
				if buttons.up or buttons.analogly < -60 then livetheme:up() end
				if buttons.down or buttons.analogly > 60 then livetheme:down() end

				if buttons.square then
					if os.message(STRINGS_CUSTOMTHEMES_DELETE.."\n\n"..list[livetheme.sel].info.title.." ?",1)==1 then
						themes.delete(list[livetheme.sel].id)
						if os.message(STRINGS_CUSTOMTHEMES_DELFILES,1)==1 then
							files.delete(list[livetheme.sel].id)
						else
							files.move(list[livetheme.sel].id,"ux0:data/uninstall_customtheme")
						end
						table.remove(list,livetheme.sel)
						livetheme:set(list,15)
						list.len = #list
					end
				end

				draw.rect(700-1,84-1,252+2,151+2,color.white)
				local y = 70
				for i=livetheme.ini,livetheme.lim do
					if i==livetheme.sel then

						if list[i].preview then list[i].preview:blit(700,84) end

						screen.print(700+126,240,list[i].info.title or "unk",0.9,theme.style.TITLECOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
						screen.print(700+126,260,list[i].info.author or "unk",0.9,theme.style.TITLECOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
						draw.fillrect(15,y-3,665,25,theme.style.SELCOLOR)
					end
					screen.print(20,y,list[i].id,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
					y+=26
				end

				if theme.data["buttons1"] then theme.data["buttons1"]:blitsprite(10,518,2) end
				screen.print(35,520,STRINGS_APP_UNINSTALL,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
			else
				screen.print(35,520,STRINGS_CUSTOMTHEMES_EMPTY,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
			end

			screen.flip()

			if buttons[cancel] then
				themesimg = nil
				collectgarbage("collect")
				os.delay(80)
				break
			end
		end

	else os.message(STRINGS_CUSTOMTHEMES_EMPTY) end

end
