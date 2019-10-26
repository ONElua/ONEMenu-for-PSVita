--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

local refresh_callback = function ()
	refresh_init(theme.data["back"])
	restart_cronopic()
end

local pic1_callback = function ()

	if __PIC1 == 1 then
		__PIC1,showpic = 0,STRINGS_APP_NO
	else
		__PIC1,showpic = 1,STRINGS_APP_YES
	end

	restart_cronopic()
	write_config()
	os.delay(150)
	SubOptions()
end

local slides_callback = function ()

	if __SLIDES == 100 then
		__SLIDES = 415
		var = STRINGS_APP_SLIDE_ORIGINAL
	else
		__SLIDES = 100
		var = STRINGS_APP_SLIDE_PS4
	end

	write_config()
	os.delay(150)

	SubOptions()
end

local themesONEMenu_callback = function ()

	local vbuff = screen.toimage()
	if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end

		theme.manager()

	os.delay(15)
	if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
end

local update_callback = function ()

	if __UPDATE == 1 then 
		_update = STRINGS_APP_NO
		__UPDATE = 0
	else
		_update = STRINGS_APP_YES
		__UPDATE = 1
	end

	write_config()
	os.delay(150)

	SubOptions()
end

function SubOptions()
	if __PIC1 == 1 then showpic = STRINGS_APP_YES else showpic = STRINGS_APP_NO end
	if __SLIDES == 100 then var = STRINGS_APP_SLIDE_ORIGINAL else var = STRINGS_APP_SLIDE_PS4 end

    Sub_Options = { -- Handle Option Text and Option Function

		{ text = STRINGS_REFRESH_LIVEAREA,  		funct = refresh_callback,				descr = STRINGS_RELOAD_CONTENT_DESCR },

		{ text = STRINGS_APP_SHOW_PIC..showpic, 	funct = pic1_callback,		pad = true, descr = STRINGS_SHOW_PIC_DESCR },
		{ text = STRINGS_APP_SLIDES..var,       	funct = slides_callback,	pad = true,	descr = STRINGS_SLIDES_DESCR },
		{ text = STRINGS_SUBMENU_THEMES,            funct = themesONEMenu_callback,			descr = STRINGS_THEMES1MENU_DESCR },

		{ text = STRINGS_ENABLE_UPDATE.._update,   	funct = update_callback,    pad = true,	descr = STRINGS_ENABLE_UPDATE_DESCR },
    }

end

function SubSystem()

	Sub_Options = {} -- Handle Option Text and Option Function
    SubOptions()
	local scrollsys = newScroll(Sub_Options, #Sub_Options)

	local x_scrext = 20
	buttons.interval(16,5)
	while true do
		buttons.read()
		if theme.data["back"] then theme.data["back"]:blit(0,0) end

		draw.fillrect(0,0,960,544,color.black:a(105))

		screen.print(480,15,STRINGS_SUBMENU_TITLE,1,theme.style.TITLECOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
		local y = 70
		for i=scrollsys.ini,scrollsys.lim do
			if i == scrollsys.sel then draw.fillrect(10,y-2,930,23,theme.style.SELCOLOR) end

			screen.print(480,y, Sub_Options[i].text,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)

			if i == 1 or i == 4 or i == 6 or i == 8 then
				y+=36
			else
				y+=26
			end

		end

		if screen.textwidth(Sub_Options[scrollsys.sel].descr) > 935 then
			x_scrext = screen.print(x_scrext, 520, Sub_Options[scrollsys.sel].descr,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__SLEFT,915)
		else
			screen.print(480, 520, Sub_Options[scrollsys.sel].descr,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
		end

		screen.flip()

		--Controls
		if buttons.up or buttons.analogly < -60 then
			if scrollsys:up() then x_scrext = 20 end
		end
		if buttons.down or buttons.analogly > 60 then
			if scrollsys:down() then x_scrext = 20 end
		end

		if buttons.cancel or buttons.start then
			os.delay(80)
			break
		end

		if buttons.accept or ( (buttons.left or buttons.right) and Sub_Options[scrollsys.sel].pad ) then Sub_Options[scrollsys.sel].funct() end

	end--while

end
