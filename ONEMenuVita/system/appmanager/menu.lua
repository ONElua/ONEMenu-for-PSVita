--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

--Asignamos limites y las img para nuestras categorias
for i=1,#appman do

	appman[i].scroll = newScroll(appman[i].list,limit)
	appman[i].slide.img = categories[i].img
	if appman[i].slide.img then
		appman[i].slide.w = appman[i].slide.img:getw()
	end

	if i==1 then
		appman[i].sort = tonumber(ini.read(__PATH_INI,"sort","sort","0"))
		appman[i].asc = tonumber(ini.read(__PATH_INI,"sort","asc","1"))
	else
		appman[i].sort = tonumber(ini.read(__PATH_INI,"sort","sort"..i,"0"))
		appman[i].asc = tonumber(ini.read(__PATH_INI,"sort","asc"..i,"1"))
	end

	if #appman[i].list > 0 then

		if i == 1 and appman[i].sort == 2 then
			table.sort(appman[i].list, tableSortReg)
		else
			if appman[i].sort == 0 then
				if appman[i].asc == 1 then
					table.sort(appman[i].list, function (a,b) return string.lower(a.id)<string.lower(b.id) end)
				else
					table.sort(appman[i].list, function (a,b) return string.lower(a.id)>string.lower(b.id) end)
				end
			elseif appman[i].sort == 1 then
				if appman[i].asc == 1 then
					table.sort(appman[i].list, function (a,b) return string.lower(a.title)<string.lower(b.title) end)
				else
					table.sort(appman[i].list, function (a,b) return string.lower(a.title)>string.lower(b.title) end)
				end
			end
		end
	end
end

--Blit Slides
function slides_efect()

	for i=1,__CATEGORIES do

		if i == cat then
			appman[i].slide.acel=1
			appman[i].slide.x-=8

			if appman[i].slide.x < -(appman[i].slide.w) then appman[i].slide.x = -appman[i].slide.w end
			if appman[i].slide.img then
				appman[i].slide.img:blit(960 + appman[i].slide.x, __SLIDES)
			end

		else
			appman[i].slide.x+=appman[i].slide.acel
			appman[i].slide.acel+=3.5
			if appman[i].slide.x >= 0 then	-- >=0 no more blit
				appman[i].slide.x = 0
			else
				if appman[i].slide.img then
					appman[i].slide.img:blit(960 + appman[i].slide.x, __SLIDES)
				end
			end
		end

	end
end

function main_draw()

	x_neg = -35
	x_init = 45
	focus_x = 210
	movx = submenu_ctx.x+submenu_ctx.w

	for i=appman[cat].scroll.ini,appman[cat].scroll.lim do

		if i==appman[cat].scroll.sel then
			focus_index,x_init = i,x_init+focus_x		--Es la separacion del seleccionado (focus) y el siguiente icono
		else
			if appman[cat].scroll.sel>1 then
				if i==appman[cat].scroll.ini then
					if not pic1_crono then
						blit_icons(i,x_neg)				--Blitea el icono anterior al seleccionado, mas cerca al 0 blitea mas a la derecha
					end
				else
					if not pic1_crono then
						blit_icons(i,x_init)
						x_init+=130
					end
				end
			else
				if not pic1_crono then
					blit_icons(i,x_init)
					x_init+=130
				end
			end
		end
	end

	focus_icon()

	if not pic1_crono then
		slides_efect()
	end

end

-- Blit all Icons & Mirror
function blit_icons(i,x1)

	--Solo blitear los demás iconos cuando no se abra el submenu
	if submenu_ctx.close then
		pic1 = nil
		if appman[cat].list[i].img then

			if appman[cat].list[i].img:geth() == 120 then
				if __SLIDES == 100 then--Original Style
					y_init = 200
					y2_init = y_init+120+10
				else y_init = 150 end

			else
				if __SLIDES == 100 then
					y_init = 220
					y2_init = y_init+100+10
				else y_init = 170 end
			end
			appman[cat].list[i].img:blit(x1,y_init,210)--175

			--Blit for favorites
			if appman[cat].list[i].fav then
				if theme.data["buttons1"] then
					theme.data["buttons1"]:blitsprite(x1,y_init,8)	
				end
			end

			-----------------------------------Mirror-------------------------------------------------------------------
			if __SLIDES == 100 then
				appman[cat].list[i].img:flipv()
					appman[cat].list[i].img:blit(x1,y2_init,54)
				appman[cat].list[i].img:flipv()
			end
			-----------------------------------Mirror-------------------------------------------------------------------
		end
	end

end

-- Blit Focus_index
function focus_icon()

	if pic1_crono then
		
		if pic_alpha < 255 then
			pic_alpha += 08
			if not angle then angle = 0 end
			angle += 24
			if angle > 360 then angle = 0 end
			draw.framearc(925, 470, 23, theme.style.TXTCOLOR, 0, 360, 20, 30)
			draw.framearc(925, 470, 23, theme.style.TXTBKGCOLOR, angle, 90, 20, 30)--gira
		end
		pic1_crono:blit(960/2, 544/2, pic_alpha)
	end

	if __SLIDES == 100 or not submenu_ctx.close or pic1_crono then
		screen.print(10,15, appman[cat].list[focus_index].title,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
	end

	if submenu_ctx.close and not pic1_crono then
		if show_pic and __PIC1==1 then
			if appman[cat].list[focus_index].type == "mb" then
				pic1_crono = game.bg0(appman[cat].list[focus_index].id)
				if not pic1_crono then
					pic1_crono = image.load("ur0:appmeta/"..appman[cat].list[focus_index].id.."/pic0.png")
				end
			else
				pic1_crono = image.load("ur0:appmeta/"..appman[cat].list[focus_index].id.."/pic0.png")
				if not pic1_crono then
					pic1_crono = game.bg0(appman[cat].list[focus_index].id)--id al recompilar
				end
			end
			if pic1_crono then
				pic1_crono:resize(960,460)
				pic1_crono:center()
			end
		end
	end

	if appman[cat].list[focus_index].img then

		if appman[cat].list[focus_index].img:geth() == 120 then
			if __SLIDES == 100 then y_init = 200 else y_init = 170 end
		else
			if __SLIDES == 100 then y_init = 220 else y_init = 190 end
		end

		if submenu_ctx.open and __PIC1 == 1 then
			if pic1 then pic1:blit(960/2, 544/2,185) end
		end

		--Resize +20
		appman[cat].list[focus_index].img:resize(appman[cat].list[focus_index].img:getw() + 20, appman[cat].list[focus_index].img:geth() + 20)

		--Original
		if __SLIDES == 100 then

			appman[cat].list[focus_index].img:blit(100+movx,(y_init - (elev/2)- 35))			-- aqui debo dar mas para q suba mas el focus

			--Blit for favorites
			if appman[cat].list[focus_index].fav then
				if theme.data["buttons1"] then
					theme.data["buttons1"]:blitsprite(100+movx,(y_init - (elev/2)- 35),8)	
				end
			end

			-----------------------------------Mirror-------------------------------------------------------------------
			appman[cat].list[focus_index].img:flipv()
				if appman[cat].list[focus_index].img:geth() == 140 then y2_init= y_init+120+10 else y2_init= y_init+100+10 end
				appman[cat].list[focus_index].img:blit(100+movx,(y2_init + (elev/2)+ 15),60)		--si doy menos blitea arriba el espejo (dif de 20 vs y)
			appman[cat].list[focus_index].img:flipv()
			-----------------------------------Mirror-------------------------------------------------------------------

		--PS4 XMB
		else

			if submenu_ctx.close then

				if appman[cat].list[focus_index].type == "mb" or appman[cat].list[focus_index].type == "EG"	or appman[cat].list[focus_index].type == "ME" then
				fill = 170 else fill = 150 end

				if not pic1_crono then
					screen.print(255,350, appman[cat].list[focus_index].title,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
					
					local wtext = screen.textwidth(appman[cat].list[focus_index].title,1) + 10
					draw.gradline(252,370,252+wtext,370,theme.style.GRADRECTCOLOR, theme.style.GRADSHADOWCOLOR)
					draw.gradline(252,371,252+wtext,371,theme.style.GRADSHADOWCOLOR, theme.style.GRADRECTCOLOR)
				end
				draw.rect(95,fill, appman[cat].list[focus_index].img:getw()+10, 230,color.shine)
				draw.gradrect(95,fill, appman[cat].list[focus_index].img:getw()+10, 230, theme.style.GRADRECTCOLOR, theme.style.GRADSHADOWCOLOR, __DIAGONAL)--__DOUBLEVER
				screen.print(95 + (appman[cat].list[focus_index].img:getw()+10)/2,350,SYMBOL_CROSS.." "..strings.start,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ACENTER)

			end

			appman[cat].list[focus_index].img:blit(100+movx,y_init + (elev/2))

			--Blit for favorites
			if appman[cat].list[focus_index].fav then
				if theme.data["buttons1"] then
					theme.data["buttons1"]:blitsprite(100+movx,y_init + (elev/2),8)	
				end
			end

		end

		--Restore Resize -20
		appman[cat].list[focus_index].img:resize(appman[cat].list[focus_index].img:getw() - 20, appman[cat].list[focus_index].img:geth() - 20)

		elev+=2
		if elev > 20 then elev = 20 end

	end

	screen.print(10,520,appman[cat].list[focus_index].dev..": "..appman[cat].list[focus_index].id.." "..appman[cat].list[focus_index].Nregion,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
	screen.print(955,520,os.date(_time.."  %m/%d/%y").." ("..#appman[cat].list..")",1,theme.style.DATETIMECOLOR,color.gray,__ARIGHT)

end
