--[[ 
   ONEMenu
   Application, themes and files manager.
   
   Licensed by Creative Commons Attribution-ShareAlike 4.0
   http://creativecommons.org/licenses/by-sa/4.0/
   
   Designed By Gdljjrod & DevDavisNunez.
   Collaborators: BaltazaR4 & Wzjk.
]]

__STITLE, __TITLE, __EDITB = "","",false

--Variable para permitir Reiniciar nuestra app
reboot = true

-- Timer and Oldstate to click actions.
local crono, clicked = timer.new(), false
cronopic, show_pic = timer.new(), false
pic_alpha = 0

limit,movx=7,0
elev = 0
sorting=""

function launch_game()
	if appman[cat].list[focus_index].uri then os.uri(appman[cat].list[focus_index].uri)
	elseif appman[cat].list[focus_index].type == "ME" then game.open(appman[cat].list[focus_index].id)
	else game.launch(appman[cat].list[focus_index].id) end
end

function restart_cronopic()
	cronopic:reset()
	cronopic:start()
		show_pic,pic1_crono = false,nil
	pic_alpha = 0
end

function appman.ctrls()

	if submenu_ctx.open then return end
	if not submenu_ctx.close then return end

	if submenu_ctx.x == -submenu_ctx.w then--no mover hasta que todo este dibujado

		if (buttons.right or swipe.left or buttons.held.r or buttons.analoglx > 60) then
			if appman[cat].scroll:down_menu() then
				if buttons.right and theme.data["slide"] then theme.data["slide"]:play() end
				elev=0
				restart_cronopic()
			end
		end

		if (buttons.left or swipe.right or buttons.held.l or buttons.analoglx < -60) then
			if appman[cat].scroll:up_menu() then
				if buttons.left and theme.data["slide"] then theme.data["slide"]:play() end
				elev=0
				restart_cronopic()
			end
		end

		if ((buttons.up or swipe.up) or (swipe.down or buttons.down)) then

			local tmp_cat = cat
			if buttons.up or swipe.up then
				cat-=1
				if cat < 1 then cat = #appman end
				while #appman[cat].list < 1 do
					cat-=1
					if cat < 1 then cat = #appman end
				end
			end

			if buttons.down or swipe.down then
				cat+=1
				if cat > #appman then cat = 1 end
				while #appman[cat].list < 1 do
					cat+=1
					if cat > #appman then cat = 1 end
				end
			end

			if tmp_cat != cat then
				os.delay(10)
				if theme.data["jump"] then theme.data["jump"]:play() end
				elev=0
				restart_cronopic()
			end

		end

	end

	if buttons.accept then
		launch_game()
	end
	if isTouched(100,180,200,120) and touch.front[1].released then--pressed then
		if clicked then
			clicked = false
			if crono:time() <= 300 then -- Double click and in time to Go.
				-- Your action here.
				launch_game()
			end
		else
			-- Your action here.
			clicked = true
			crono:reset()
			crono:start()
		end
	end

	if crono:time() > 300 then -- First click, but long time to double click...
		clicked = false
	end

	if cronopic:time() > 900 then
		show_pic = true
	end

end

function appman.launch()

	buttons.interval(10,10)
	while true do

		buttons.read()
			touch.read()
		swipe.read()

		if snow then stars.render() end

		while IMAGE_PORT_I:available() > 0 do -- While have availables request.
			local entry = IMAGE_PORT_I:pop() -- Recibimos peticiones..
			if static_void[entry.y][entry.x].path_img == entry.path then -- Check ident
				if not entry.img then
					entry.img = iconDef
					if entry.resize then
						entry.img:resize(120,100)
					else
						entry.img:resize(120,120)
					end
					entry.img:setfilter(__IMG_FILTER_LINEAR, __IMG_FILTER_LINEAR)
				end
				static_void[entry.y][entry.x].img = entry.img

			end
			entry = nil
		end

		buttons_reasign()

		if appman.len > 0 then
			main_draw()
			submenu_ctx.run()
		else
			screen.print(10,30,STRINGS_APP_EMPTY,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
		end

		screen.flip()

		if appman.len > 0 then
			appman.ctrls()
		end

		if buttons.square and not submenu_ctx.open and (not buttons.held.l or buttons.held.r)  then
			system.run()
		else
			if buttons.cancel and not submenu_ctx.open then
				while true do
					buttons.read()

					local mp4 = video.import(theme.data["back"])
					if mp4 != -1 then
						video.mount()
							VideoPlayer(mp4)
						video.umount()
					else
						break
					end

					if buttons.released.cancel then break end

				end
				os.delay(25)
			end
		end

		if buttons.select and not submenu_ctx.open then
			for i=1,#appman do 
				if #appman[i].list > 0 then
					for j=1,#appman[i].list do
						appman[i].list[j].pullsize = false
					end
				end
			end
			show_explorer_list()
		end--to Explorer

		--SubMenu Contextual 2
		if buttons.start and not submenu_ctx.open then
			local vbuff = screen.toimage()
			if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end

				SubSystem()

			os.delay(15)
			if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
		end

		shortcuts()

	end
end

---------------------------------- SubMenu Contextual 1 ---------------------------------------------------

local uninstall_callback = function ()
	if appman[cat].list[focus_index].id != __ID and appman[cat].list[focus_index].dev != "gro0" then

		local vbuff = screen.toimage()
		if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end

		if os.dialog(STRINGS_APP_REMOVE.."?\n"..appman[cat].list[focus_index].title, appman[cat].list[focus_index].id, __DIALOG_MODE_OK_CANCEL) == true then
			if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
			message_wait()

			--Backup Save from ux0:user/00/savedata
			if appman[cat].cats == "psvita" and appman[cat].list[focus_index].save then
				if files.exists("ux0:user/00/savedata/"..appman[cat].list[focus_index].save) then--cat == 1 then
					if os.message(STRINGS_APP_BACKUP_SAVE, 1) == 1 then
						--game.umount()
							--game.mount("ux0:user/00/savedata/"..appman[cat].list[focus_index].save)
							files.copy("ux0:user/00/savedata/"..appman[cat].list[focus_index].save, "ux0:data/ONEMenu/Saves/")
						--game.umount()
					end
				end
			end

			buttons.homepopup(0)
				reboot=false
					local result_rmv = game.delete(appman[cat].list[focus_index].id)
				reboot=true
			buttons.homepopup(1)

			if result_rmv == 1 then
				appman.len -= 1
				if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end

				local path_ReAddcont = { "ux0:ReAddcont/", "uma0:ReAddcont/", "imc0:ReAddcont/", "xmc0:ReAddcont/" }
				for i=1,#path_ReAddcont do
					if files.exists(path_ReAddcont[i]..appman[cat].list[focus_index].id) then
						if os.message(STRINGS_SUBMENU_DELETE.."\n"..path_ReAddcont[i]..appman[cat].list[focus_index].id.."?",1) == 1 then
							reboot=false
								files.delete(path_ReAddcont[i]..appman[cat].list[focus_index].id)
							reboot=true
						end
					end
				end
	
				local path_RePatch = { "ux0:RePatch/", "uma0:RePatch/", "imc0:RePatch/", "xmc0:RePatch/" }
				for i=1,#path_RePatch do
					if files.exists(path_RePatch[i]..appman[cat].list[focus_index].id) then
						if os.message(STRINGS_SUBMENU_DELETE.."\n"..path_RePatch[i]..appman[cat].list[focus_index].id.."?",1) == 1 then
							reboot=false
								files.delete(path_RePatch[i]..appman[cat].list[focus_index].id)
							reboot=true
						end
					end
				end
	
				table.remove(appman[cat].list, appman[cat].scroll.sel)
				appman[cat].scroll.maxim=#appman[cat].list

				if #appman[cat].list < 1 then
					while #appman[cat].list < 1 do
						cat += 1
						if cat > #appman then cat = 1 end
					end
				else

					if appman[cat].scroll.sel==appman[cat].scroll.lim then

						if appman[cat].scroll.ini != 1 then appman[cat].scroll.ini-=1 end
						appman[cat].scroll.sel-=1
						appman[cat].scroll.lim=appman[cat].scroll.sel
					elseif appman[cat].scroll.lim>#appman[cat].list then
						appman[cat].scroll.lim-=1
					end
				end
				infodevices()
			end
			submenu_ctx.close = true
		end
		os.delay(15)
		if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
	end
end

local shrink_callback = function ()

	if appman[cat].cats == "psvita" and appman[cat].list[focus_index].dev != "gro0" then--Only Vita Games in ux0:app

		if theme.data["back"] then theme.data["back"]:blit(0,0) end

		local list_patch, list_app, string_total = {},{},""

		function getlist(_path, _list, substring, __path)
			local tmp = files.list(_path)	
			if tmp and #tmp > 0 then
				for i=1, #tmp do
					if tmp[i].directory then
						if not tmp[i].name:find("sce_",1) then getlist(tmp[i].path, _list, substring, __path) end
					else
						if tmp[i].name != "eboot.bin" then
							local _size = (tmp[i].size or files.size(tmp[i].path))
							table.insert(_list, {path = tmp[i].path:gsub(substring, __path):lower(), size = _size})
						end
					end
				end
			end
		end
		message_wait("App vs Patch")
		os.delay(25)

		getlist("ux0:patch/"..appman[cat].list[focus_index].id, list_patch, "ux0:patch", 'ux0:app')
		getlist("ux0:app/"..appman[cat].list[focus_index].id, list_app, "ux0:patch", 'ux0:app')

		local size_del,list_del = 0,{}
		if #list_patch > 0 and #list_app > 0 then
			for i=1,#list_patch do
				for j=1,#list_app do
					if list_patch[i].path == list_app[j].path then
						size_del += list_app[j].size
						table.insert(list_del,list_app[j].path)
						if theme.data["back"] then theme.data["back"]:blit(0,0) end
							message_wait(list_app[j].path)
							string_total += list_app[j].path.."\n"
						os.delay(75)
					end
				end
			end
		end

		if #list_del > 0 then
			if os.dialog(STRINGS_APP_SHRINK.."\n"..STRINGS_COUNT..#list_del.." "..STRINGS_CALLBACKS_MOVE_FILES.." "..files.sizeformat(size_del or 0).." "..STRINGS_APP_SHRINK_FREE.."\n\n"..string_total, "ux0:patch/"..appman[cat].list[focus_index].id, __DIALOG_MODE_OK_CANCEL) == true then
				for i=1,#list_del do
					files.delete(list_del[i])
				end
				--update size
				appman[cat].list[focus_index].size = files.size(appman[cat].list[focus_index].path)
				appman[cat].list[focus_index].sizef = files.sizeformat((appman[cat].list[focus_index].size or 0))
			end
		else
			os.message(STRINGS_APP_SHRINK_NO_FILES.."\nux0:Patch")
		end
		os.delay(15)

----------------Repatch
--ux0, uma0, imc0, grw0, xmc0

	local Repatch_Find = nil
	local path_RePatch = { "ux0:RePatch", "uma0:RePatch", "imc0:RePatch", "xmc0:RePatch" }

	for i=1,#path_RePatch do
		if files.exists(path_RePatch[i].."/"..appman[cat].list[focus_index].id) then
			Repatch_Find = path_RePatch[i]
			break
		end
	end

	string_total = ""
	if Repatch_Find then

		if theme.data["back"] then theme.data["back"]:blit(0,0) end
		message_wait("App vs "..Repatch_Find)
		os.delay(15)

		list_patch, list_app = {},{}

		getlist(Repatch_Find.."/"..appman[cat].list[focus_index].id, list_patch, Repatch_Find, 'ux0:app')
		getlist("ux0:app/"..appman[cat].list[focus_index].id, list_app, Repatch_Find, 'ux0:app')

		local size_del,list_del = 0,{}
		if #list_patch > 0 and #list_app > 0 then
			for i=1,#list_patch do
				for j=1,#list_app do
					if list_patch[i].path == list_app[j].path then
						size_del += list_app[j].size
						table.insert(list_del,list_app[j].path)
						if theme.data["back"] then theme.data["back"]:blit(0,0) end
							message_wait(list_app[j].path)
							string_total += list_app[j].path.."\n"
						os.delay(75)
					end
				end
			end
		end

		if #list_del > 0 then
			if os.dialog(STRINGS_APP_SHRINK.."\n"..STRINGS_COUNT..#list_del.." "..STRINGS_CALLBACKS_MOVE_FILES.." "..files.sizeformat(size_del or 0).." "..STRINGS_APP_SHRINK_FREE.."\n\n"..string_total, "ux0:RePatch/"..appman[cat].list[focus_index].id, __DIALOG_MODE_OK_CANCEL) == true then
				for i=1,#list_del do
					files.delete(list_del[i])
				end
				--update size
				appman[cat].list[focus_index].size = files.size(appman[cat].list[focus_index].path)
				appman[cat].list[focus_index].sizef = files.sizeformat((appman[cat].list[focus_index].size or 0))
			end
		else
			os.message(STRINGS_APP_SHRINK_NO_FILES.."\n"..Repatch_Find)
		end
		os.delay(15)

		string_total = ""

		if theme.data["back"] then theme.data["back"]:blit(0,0) end
		message_wait("Patch vs Repatch")
		os.delay(15)

		list_repatch, list_patch = {},{}

		getlist(Repatch_Find.."/"..appman[cat].list[focus_index].id, list_repatch, Repatch_Find, 'ux0:patch')
		getlist("ux0:patch/"..appman[cat].list[focus_index].id, list_patch, Repatch_Find, 'ux0:patch')

		local size_del,list_del = 0,{}
		if #list_repatch > 0 and #list_patch > 0 then
			for i=1,#list_repatch do
				for j=1,#list_patch do
					if list_repatch[i].path == list_patch[j].path then
						size_del += list_patch[j].size
						table.insert(list_del,list_patch[j].path)
						if theme.data["back"] then theme.data["back"]:blit(0,0) end
							message_wait(list_patch[j].path)
							string_total += list_patch[j].path.."\n"
						os.delay(75)
					end
				end
			end
		end

		if #list_del > 0 then
			if os.dialog(STRINGS_APP_SHRINK.."\n"..STRINGS_COUNT..#list_del.." "..STRINGS_CALLBACKS_MOVE_FILES.." "..files.sizeformat(size_del or 0).." "..STRINGS_APP_SHRINK_FREE.."\n\n"..string_total, "ux0:Patch/"..appman[cat].list[focus_index].id, __DIALOG_MODE_OK_CANCEL) == true then
				for i=1,#list_del do
					files.delete(list_del[i])
				end
				--update sizef patch
				appman[cat].list[focus_index].sizef_patch = files.sizeformat(files.size("ux0:patch/"..appman[cat].list[focus_index].id or 0))
			end
		else
			os.message(STRINGS_APP_SHRINK_NO_FILES.."\n"..Repatch_Find)
		end
		os.delay(15)

	end

--[[
----------------ReAddcont

	local ReAddcont_Find = nil
	local path_ReAddcont = { "ux0:ReAddcont", "uma0:ReAddcont", "imc0:ReAddcont", "xmc0:ReAddcont" }

	for i=1,#path_ReAddcont do
		if files.exists(path_ReAddcont[i].."/"..appman[cat].list[focus_index].id) then
			ReAddcont_Find = path_ReAddcont[i]
			break
		end
	end

	string_total = ""
	if ReAddcont_Find then

		if theme.data["back"] then theme.data["back"]:blit(0,0) end
		message_wait(ReAddcont_Find)
		os.delay(15)

		function getlistaddcont(_path, _list, substring)
			local tmp = files.list(_path)	
			if tmp and #tmp > 0 then
				for i=1, #tmp do
					if tmp[i].directory then
						if not tmp[i].name:find("sce_",1) then getlistaddcont(tmp[i].path, _list, substring) end
					else
						if tmp[i].name != "eboot.bin" then
							local _size = (tmp[i].size or files.size(tmp[i].path))
							table.insert(_list, {path = tmp[i].path:gsub(substring,'ux0:addcont'):lower(), size = _size})
						end
					end
				end
			end
		end

		list_patch, list_app = {},{}
		getlistaddcont(ReAddcont_Find.."/"..appman[cat].list[focus_index].id, list_patch, ReAddcont_Find)
		getlistaddcont("ux0:addcont/"..appman[cat].list[focus_index].id, list_app, ReAddcont_Find)

		local size_del,list_del = 0,{}
		if #list_patch > 0 and #list_app > 0 then
			for i=1,#list_patch do
				for j=1,#list_app do
					if list_patch[i].path == list_app[j].path then
						size_del += list_app[j].size
						table.insert(list_del,list_app[j].path)
						if theme.data["back"] then theme.data["back"]:blit(0,0) end
							message_wait(list_app[j].path)
							string_total += list_app[j].path.."\n"
						os.delay(75)
					end
				end
			end
		end

		if #list_del > 0 then
			if os.dialog(STRINGS_APP_SHRINK.."\n"..STRINGS_COUNT..#list_del.." "..STRINGS_CALLBACKS_MOVE_FILES.." "..files.sizeformat(size_del or 0).." "..STRINGS_APP_SHRINK_FREE.."\n\n"..string_total, "ux0:ReAddcont/"..appman[cat].list[focus_index].id, __DIALOG_MODE_OK_CANCEL) == true then
				for i=1,#list_del do
					files.delete(list_del[i])
				end
				--update addcont&readccont
				appman[cat].list[focus_index].sizef_addcont = files.sizeformat(files.size(ReAddcont_Find.."/"..appman[cat].list[focus_index].id or 0))
				appman[cat].list[focus_index].sizef_readdcont = files.sizeformat(files.size(ReAddcont_Find.."/"..appman[cat].list[focus_index].id or 0))
			end
		else
			os.message(STRINGS_APP_SHRINK_NO_FILES.."\n"..ReAddcont_Find)
		end
		os.delay(15)

	end
]]
	string_total = ""

----------------sce_sys/manual/
		if theme.data["back"] then theme.data["back"]:blit(0,0) end
		message_wait("sce_sys/manual/")
		os.delay(15)

		local pathmanual,pathpatch  = appman[cat].list[focus_index].path.."/sce_sys/manual/","ux0:patch/"..appman[cat].list[focus_index].id.."/sce_sys/manual/"
		local scesys_manual, patch_manual, size_manual, dirs_manual, files_manual = false,false,0,0,0

		if files.exists(pathmanual) then
			size_manual, dirs_manual, files_manual = files.size(pathmanual)
			scesys_manual = true
		end
		if files.exists(pathpatch) then
			local tam,fold,arch = 0,0,0
			tam,fold,arch = files.size(pathpatch)
			patch_manual = true
			size_manual += tam
			files_manual += arch
		end

		if scesys_manual or patch_manual then
			if os.dialog(STRINGS_COUNT..files_manual.." "..STRINGS_CALLBACKS_MOVE_FILES.." "..files.sizeformat(size_manual or 0).." "..STRINGS_APP_SHRINK_FREE,STRINGS_APP_DELETE_MANUAL, __DIALOG_MODE_OK_CANCEL) == true then
				if scesys_manual then
					reboot=false
						files.delete(pathmanual)
					reboot=true
				end

				if patch_manual then
					reboot=false
						files.delete(pathpatch)
					reboot=true
				end
				--update size
				appman[cat].list[focus_index].size = files.size(appman[cat].list[focus_index].path)
				appman[cat].list[focus_index].sizef = files.sizeformat((appman[cat].list[focus_index].size or 0))

				--update size patch
				appman[cat].list[focus_index].sizef_patch = files.sizeformat(files.size("ux0:patch/"..appman[cat].list[focus_index].id or 0))
			end
		else
			os.message(STRINGS_APP_NOTFIND_MANUAL)
		end

		infodevices()
		os.delay(15)
		if theme.data["back"] then theme.data["back"]:blit(0,0) end

	end
end

local switch_callback = function ()

	--__GAME_MOVE_UX02UR0=1
	--__GAME_MOVE_UR02UX0=2
	--__GAME_MOVE_UX02UMA0=3
	--__GAME_MOVE_UMA02UX0=4
	--__GAME_MOVE_UR02UMA0=5
	--__GAME_MOVE_UMA02UR0=6
	local mov = __GAME_MOVE_UX02UR0
	local loc1,loc2,v1,v2 = "ur0","uma0",__GAME_MOVE_UX02UR0,__GAME_MOVE_UX02UMA0

	if appman[cat].list[focus_index].dev == "ur0" then
		loc1,loc2,v1,v2 = "ux0","uma0",__GAME_MOVE_UR02UX0,__GAME_MOVE_UR02UMA0
	elseif appman[cat].list[focus_index].dev == "ux0" then
		loc1,loc2,v1,v2 = "ur0","uma0",__GAME_MOVE_UX02UR0,__GAME_MOVE_UX02UMA0
	elseif appman[cat].list[focus_index].dev == "uma0" then
		loc1,loc2,v1,v2 = "ux0","ur0",__GAME_MOVE_UMA02UX0,__GAME_MOVE_UMA02UR0
	end

	local options = {
			{ text = loc1 },
			{ text = loc2 },
			{ text = STRINGS_SUBMENU_CANCEL }
		}
	local scroll_op,cccolor = newScroll(options, #options),""

	local vbuff = screen.toimage()
	while true do
		buttons.read()
		if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end

		screen.print(350,80,STRINGS_APP_PARTITIONS,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ARIGHT)
		draw.line(220,50,220,submenu_ctx.y + 129, color.green)

		local y = 100
		for i=scroll_op.ini,scroll_op.lim do
			if i == scroll_op.sel then cccolor = color.green else cccolor = color.white end
			screen.print(350,y, options[i].text,1.0,cccolor,theme.style.TXTBKGCOLOR,__ARIGHT)
			y+=22
		end

		local h = 480
		draw.fillrect(10,h, 330, 15, color.gray)
		draw.fillrect(10,h, math.map(infoux0.used, 0,infoux0.max, 0, 330 ), 15, color.shine:a(80))
		draw.rect(10,h,330,15,color.white:a(200))
		h-=20
		screen.print(10,h,"(ux0) "..infoux0.maxf.."/"..infoux0.freef,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
		h-=20

		if infour0 then
			draw.fillrect(10,h, 330, 15, color.gray)
			draw.fillrect(10,h, math.map(infour0.used, 0,infour0.max, 0, 330 ), 15, color.shine:a(80))
			draw.rect(10,h,330,15,color.white:a(200))
			h-=20
			screen.print(10,h,"(ur0) "..infour0.maxf.."/"..infour0.freef,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
			h-=20
		end
		if infouma0 then
			draw.fillrect(10,h, 330, 15, color.gray)
			draw.fillrect(10,h, math.map(infouma0.used, 0,infouma0.max, 0, 330 ), 15, color.shine:a(80))
			draw.rect(10,h,330,15,color.white:a(200))
			h-=20
			screen.print(10,h,"(uma0) "..infouma0.maxf.."/"..infouma0.freef,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
		end

		screen.flip()

		if buttons.up then scroll_op:up() elseif buttons.down then scroll_op:down() end

		if buttons.cancel then
			os.delay(15)
			if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
			return
		end

		if buttons.accept then
			if scroll_op.sel == 1 then mov = v1
			elseif scroll_op.sel == 2 then mov = v2
			else
				os.delay(15)
				if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
				return
			end
			break
		end

	end--while

	buttons.homepopup(0)
	reboot=false
		game_move=true
			total_size,folders,filess = files.size(appman[cat].list[focus_index].path)
			files_move,cont = folders+filess,0
			local result = game.move(appman[cat].list[focus_index].id, mov, total_size)
			total_size,files_move, cont = 0,0,0
			fileant = ""
		game_move=false
	buttons.homepopup(1)
	reboot=true

	os.delay(100)

	if result ==1 then
		if mov == __GAME_MOVE_UX02UR0 or mov == __GAME_MOVE_UMA02UR0 then
			appman[cat].list[focus_index].path = "ur0:app/"..appman[cat].list[focus_index].id
			appman[cat].list[focus_index].dev = "ur0"
		elseif mov == __GAME_MOVE_UR02UX0 or mov == __GAME_MOVE_UMA02UX0 then
			appman[cat].list[focus_index].path = "ux0:app/"..appman[cat].list[focus_index].id
			appman[cat].list[focus_index].dev = "ux0"
		elseif mov == __GAME_MOVE_UX02UMA0 or mov == __GAME_MOVE_UR02UMA0 then
			appman[cat].list[focus_index].path = "uma0:app/"..appman[cat].list[focus_index].id
			appman[cat].list[focus_index].dev = "uma0"
		end
		if appman[cat].list[focus_index].id == __ID then
			os.message(STRINGS_RESTART)
			power.restart()
		end
	elseif result ==-4 then os.message(STRINGS_APP_NOT_MEMORY) end

	infodevices()
	os.delay(15)
	if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
end

function image.startup(img)
    local w,h = img:getw(), img:geth()

	if w != 280 or h != 158 then
		w,h = 280,158
		img = img:copyscale(w,h)
	end

	local px,py = 0, 192-h --34
	local sheet = image.new(280, 192, 0x0)
	for y=0,h-1 do
		for x=0,w-1 do
			local c = img:pixel(x,y)
			if c:a() == 0 then c = 0x0 end 
			sheet:pixel(px+x, py+y, c)
		end
	end
	return sheet
end

function editbubbles(obj)

	local tmp = files.listdirs("ux0:ABM/")

	if tmp then table.sort(tmp,function(a,b) return string.lower(a.name)<string.lower(b.name) end)
	else tmp = {} end

	local resources = { 
		{ name = "ICON0.PNG", 	 w = 128,	h = 128,	dest = "/sce_sys/icon0.png", },
		{ name = "STARTUP.PNG",  w = 280,	h = 158,	dest = "/sce_sys/livearea/contents/startup.png", },
		{ name = "PIC0.PNG", 	 w = 960,	h = 544,	dest = "/sce_sys/pic0.png", },
		{ name = "BG0.PNG", 	 w = 840,	h = 500,	dest = "/sce_sys/livearea/contents/bg0.png", },
		{ name = "BG.PNG", 	 	 w = 840,	h = 500,	dest = "/sce_sys/livearea/contents/bg.png" },
		{ name = "BOOT.PNG", 	 w = 480,	h = 272,	dest = "/data/boot.png", },
		{ name = "TEMPLATE.XML", w = 0,		h = 0,		dest = "/sce_sys/livearea/contents/", },
	}

	--FRAMEX.PNG 1 to 10
	for i=1,10 do
		table.insert(resources, { name = "FRAME"..i..".PNG", w = 0,	h = 0, dest = "/sce_sys/livearea/contents/", })
	end

	local find_png, inside, backl, manual_flag = false,false,{},false
	local bubble_color = 1
	local maximset = 10
	local scrids, newpath = newScroll(tmp, maximset),"ux0:ABM/"
	buttons.interval(12,5)
	while true do
		buttons.read()

		if theme.data["back"] then theme.data["back"]:blit(0,0) end

--		draw.fillrect(0,0,960,30, 0x64545353) --UP
		screen.print(480,5, STRINGS_EDIT_BUBBLE, 1, theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ACENTER)

		if scrids.maxim > 0 then

			screen.print(15,35, newpath, 1, color.white,color.blue)
			local y = 75
			for i=scrids.ini, scrids.lim do

				if i == scrids.sel then
					if not inside then draw.fillrect(14,y-3,936,25, theme.style.SELCOLOR)
					else draw.fillrect(14,y-3,682,25,theme.style.SELCOLOR) end
				end
				screen.print(20,y,tmp[i].name,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)

				y += 32
			end

			--Bar Scroll
			local ybar, h = 70, (maximset*32)-2
			draw.fillrect(3, ybar-2, 8, h, color.shine)
			--if scrids.maxim >= maximset then -- Draw Scroll Bar
				local pos_height = math.max(h/scrids.maxim, maximset)
				draw.fillrect(3, ybar-2 + ((h-pos_height)/(scrids.maxim-1))*(scrids.sel-1), 8, pos_height, color.new(0,255,0))
			--end

			if tmp[scrids.sel].img then
				tmp[scrids.sel].img:blit(700,84)
			end

			screen.print(10,450, obj.id, 1, theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ALEFT)
			screen.print(10,480, obj.title, 1, theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ALEFT)

			if inside and (find_png or manual_flag) then
				screen.print(480,523,STRINGS_EDIT_BUBBLE_PROCESS,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ACENTER)
			end

		else
			screen.print(480,230, STRINGS_APP_EMPTY, 1, theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ACENTER)
		end

		if inside then
			screen.print(950,520, SYMBOL_CIRCLE..": "..STRINGS_BACK, 1, theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ARIGHT)
		end

		--draw.fillrect(0,516,960,30, 0x64545353)--Down

		screen.flip()

		--Controls
		if buttons.cancel then
			if inside then
				newpath = files.nofile(newpath)
				tmp = files.listdirs(newpath)

				if tmp then table.sort(tmp,function(a,b) return string.lower(a.name)<string.lower(b.name) end)
				else tmp = {} end

				os.delay(750)

				find_png, inside, backlist, manual_flag = false,false,{},false
				maximset = 10
				scrids:set(tmp,maximset)
				if #backl>0 then
					if scrids.maxim == backl[#backl].maxim then
						scrids.ini = backl[#backl].ini
						scrids.lim = backl[#backl].lim
						scrids.sel = backl[#backl].sel
					end
					backl[#backl] = nil
				end

			else
				buttons.read() break
			end
		end

		if scrids.maxim > 0 then

			if (buttons.up or buttons.analogly < -60) then scrids:up() end
			if (buttons.down or buttons.analogly > 60) then scrids:down() end

			if buttons.accept and tmp[scrids.sel].directory then
				table.insert(backl, {maxim = scrids.maxim, ini = scrids.ini, sel = scrids.sel, lim = scrids.lim })
				inside = true
				newpath = "ux0:ABM/"..tmp[scrids.sel].name

				--MANUAL folder
				manual_flag = false
				if files.exists(newpath.."/Manual/") then manual_flag = true end

				tmp = {}
				local png = files.listfiles(newpath)
				if png and #png > 0 then
					table.sort(png,function(a,b) return string.lower(a.name)<string.lower(b.name) end)
					for i=1,#png do
						if png[i].ext:upper() == "PNG" or png[i].ext:upper() == "XML" then
							find_png = true
							for j=1,#resources do

								if (png[i].name:upper() == resources[j].name) then

									local noscaled = false
									if png[i].ext:upper() == "PNG" then

										png[i].img = image.load(png[i].path)

										if png[i].img then
											if png[i].name:upper() == "ICON0.PNG" then
												if png[i].img:getrealw() == 128 and png[i].img:getrealw() == 128 then
													noscaled = true
												end
											end
											png[i].img:resize(252,151)
											png[i].img:setfilter(__IMG_FILTER_LINEAR, __IMG_FILTER_LINEAR)
										end

									end
									table.insert(tmp, { name = png[i].name, path = png[i].path, ext = png[i].ext, img = png[i].img or nil,
														directory = png[i].directory or false })
									tmp.nostretched = true
									tmp.noscaled = noscaled

								end
							end--for resources

						end
					end--for png
				end

				if manual_flag then
					table.insert(tmp, { name = "Manual" })
				end

				maximset = #tmp
				scrids = newScroll(tmp, maximset)
			end

			if buttons.start and inside and (find_png or manual_flag) then--hacer la reinstalación

				buttons.homepopup(0)

				local img = nil
				local path_tmp = "ux0:data/vpk_abm/"
				files.delete(path_tmp)
				files.mkdir(path_tmp)

				if theme.data["back"] then theme.data["back"]:blit(0,0) end
				draw.fillrect(0,0,960,30, color.shine)
				screen.print(10,10,STRINGS_BACKUP)
				os.delay(250)
				screen.flip()

				local onCopyFilesOld = onCopyFiles
				function onCopyFiles(size,written,file)
					return 10 -- Ok code
				end
				--Backup All
				files.copy(obj.path.."/sce_sys/livearea/", path_tmp.."sce_sys/")
				files.copy(obj.path.."/sce_sys/package/", path_tmp.."sce_sys/")
				files.copy(obj.path.."/sce_sys/icon0.png", path_tmp.."sce_sys/")
				files.copy(obj.path.."/sce_sys/param.sfo", path_tmp.."sce_sys/")
				files.copy(obj.path.."/sce_sys/pic0.png", path_tmp.."sce_sys/")
				files.copy(obj.path.."/data/", path_tmp)

				for i=1,#resources do
					for j=1,#tmp do

						if tmp[j].name:upper() == resources[i].name then

							--Resources to 8bits
							if theme.data["back"] then theme.data["back"]:blit(0,0) end

							if i < 7 then--no mayor a xml y frames

								img = image.load(tmp[j].path)
								if img then
									img:scale(75)
									img:center()
									img:blit(480,272)
								end

								draw.fillrect(0,0,960,30, color.shine)
								screen.print(10,10,STRINGS_CONVERTING)
								screen.print(950,10,resources[i].name,1, color.white, color.blue, __ARIGHT)
								screen.flip()

								if img then
									img:reset()

									local scale = false
									if tmp[j].name:upper() != "ICON0.PNG" then
										if img:getrealw() != resources[i].w or img:getrealh() != resources[i].h then
											img=img:copyscale(resources[i].w, resources[i].h)
											scale = true
										end
									end

									--i==2 STARTUP.PNG
									if i == 2 then
										--Fix Startup.png Forzar 8bits
										image.save(image.startup(img), obj.path..resources[i].dest, 1)
									else
										if tmp[j].name:upper() == "ICON0.PNG" then
											if tmp.nostretched then
												if img:getrealw() != resources[i].w or img:getrealh() != resources[i].h then
													image.save(img:copyscale(128,128), obj.path..resources[i].dest, 1)
												else
													image.save(img, obj.path..resources[i].dest, 1)
												end
											else
												image.save(image.nostretched(img, colors[bubble_color]), obj.path..resources[i].dest, 1)
											end
										else
											if tmp[j].name:upper() == "BOOT.PNG" then
												image.save(img, obj.path..resources[i].dest)
											else
												image.save(img, obj.path..resources[i].dest, 1)
											end
										end
									end

								end--if img

							else

								files.copy(tmp[j].path, obj.path..resources[i].dest)
									
								if i > 7 then
									img = image.load(tmp[j].path)
									if img then
										img:scale(75)
										img:center()
										img:blit(480,272)
									end

									draw.fillrect(0,0,960,30, color.shine)
									screen.print(10,10,STRINGS_CONVERTING)
									screen.print(950,10,resources[i].name,1, color.white, color.blue, __ARIGHT)
									screen.flip()

									image.save(img, obj.path..resources[i].dest, 1)
								end

							end
						end
					end
				end--for

				--MANUAL folder
				if files.exists(newpath.."/Manual/") then
					if theme.data["back"] then theme.data["back"]:blit(0,0) end
					draw.fillrect(0,0,960,30, color.shine)
						screen.print(10,10,STRINGS_INSTALL_MANUAL)
					screen.flip()
					files.move(obj.path.."/sce_sys/Manual/", path_tmp.."sce_sys/")
					files.copy(newpath.."/Manual/", obj.path.."/sce_sys/")
				else
					--check Manual Bubble ?
					if files.exists(obj.path.."/sce_sys/Manual/001.png") then
						if theme.data["back"] then theme.data["back"]:blit(0,0) end
						draw.fillrect(0,0,960,30, color.shine)
						if os.dialog(STRINGS_MANUAL_KEEP, STRINGS_INSTALL_MANUAL, __DIALOG_MODE_OK_CANCEL) == false then
							files.move(obj.path.."/sce_sys/Manual/", path_tmp.."sce_sys/")
						end
					end
				end

				--Install Bubble
				files.copy("ur0:shell/db/app.db",path_tmp)
				bubble_id,reinstall = obj.id,true
				
				local onAppInstallOld = onAppInstall
				function onAppInstall(step, size_argv, written, file, totalsize, totalwritten)
					return 10 -- Ok code
				end

				local result = game.installdir(obj.path)
				if result != 1 then
					--Restore
					files.copy(path_tmp.."app.db", "ur0:shell/db/")
					files.move(path_tmp.."sce_sys/",obj.path)
					files.move(path_tmp.."data/",obj.path)
					os.message(STRINGS_ERROR_INST,0)
				end
				onAppInstall = onAppInstallOld
				onCopyFiles = onCopyFilesOld
				buttons.read()--flush
				
				local onDeleteFilesOld = onDeleteFiles
				function onDeleteFiles(file)
					return 10 -- Ok code
				end
				files.delete(path_tmp)
				onDeleteFiles = onDeleteFilesOld

				obj.img = image.load(obj.path_img)

				infodevices()
				
				buttons.homepopup(1)
				buttons.read() break
			end

		end

	end--while

end

--PIGS000001,SONIC0001,SONIC0002,GRVA00007
local bubble_edit_callback = function ()

	if appman[cat].list[focus_index].dev == "gro0" or appman[cat].list[focus_index].id == "PCSG90096" then return end

	local pos_menu = submenu_ctx.scroll.sel
	local vbuff = screen.toimage()

	editbubbles(appman[cat].list[focus_index])

	submenu_ctx.wakefunct()
	submenu_ctx.scroll.sel = pos_menu
	os.delay(15)
	if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end

end

local editsfo_callback = function ()

	--Init load prkxs
	if not __kernel then
		if files.exists("modules/kernel.skprx") then
			if os.requirek("modules/kernel.skprx")==1 then __kernel = true end
		else
			if os.requirek("ux0:VitaShell/module/kernel.skprx")==1 then	__kernel = true end
		end
	end

	if not __user then
		if files.exists("modules/user.suprx") then
			if os.requireu("modules/user.suprx")==1 then __user = true end
		else
			if os.requireu("ux0:VitaShell/module/user.suprx")==1 then __user = true end
		end
	end

	if appman[cat].list[focus_index].dev == "gro0" or (not __kernel and not __user) then return end

	local pos_menu = submenu_ctx.scroll.sel
	local vbuff = screen.toimage()

	game.umount()
	buttons.homepopup(0)
		local res = game.mount("ux0:appmeta/"..appman[cat].list[focus_index].id)

		--Edit SFO
		local obj = {}
		obj.path = "ux0:appmeta/"..appman[cat].list[focus_index].id.."/param.sfo"
		obj.ext = "sfo"
		--Clean
		__STITLE, __TITLE, __EDITB = "","",true
		local edit_sfo = visortxt(obj,true)

	game.umount()
	buttons.homepopup(1)

	if edit_sfo then
		if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end

		local reboot_updatedb, restart_only = false,false

		--STitle,Title,ID
		if __TITLE != "" then
			os.titledb(string.sub(__TITLE,1,127), appman[cat].list[focus_index].id)
			if os.message(STRINGS_TITLE_UPDATE_DB,1) == 1 then reboot_updatedb = true end
		end

		if __STITLE != "" then
			os.stitledb(string.sub(__STITLE,1,51), appman[cat].list[focus_index].id)
			if os.message(STRINGS_STITLE_RESTART,1) == 1 then restart_only = true end
		end

		if reboot_updatedb then
			os.delay(150)
			_print=false
			os.updatedb()
			os.message(STRINGS_RESTART_UPDATEDB)
			os.delay(1500)
			power.restart()
		end
		if restart_only then
			os.delay(1500)
			power.restart()
		end

	end
	__STITLE, __TITLE, __EDITB = "","",false

	submenu_ctx.wakefunct()
	submenu_ctx.scroll.sel = pos_menu
	os.delay(15)
	if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end

end

local openfolder_callback = function ()

	local options = { }

	if appman[cat].cats == "psvita" or appman[cat].cats == "hbvita" or appman[cat].cats == "adrbb" then
		table.insert(options, { text = "App", path = appman[cat].list[focus_index].dev..":/app/"..appman[cat].list[focus_index].id, exit=false })

		if appman[cat].cats == "psvita" then
			--Patch
			if files.exists(appman[cat].list[focus_index].dev..":/patch/"..appman[cat].list[focus_index].id) then
				table.insert(options, { text = "Patch", path = appman[cat].list[focus_index].dev..":/patch/"..appman[cat].list[focus_index].id, exit = false })
			end

			--Repatch
			local Repatch_Find = nil
			local path_RePatch = { "ux0:/RePatch", "uma0:/RePatch", "imc0:/RePatch", "xmc0:/RePatch" }

			for i=1,#path_RePatch do
				if files.exists(path_RePatch[i].."/"..appman[cat].list[focus_index].id) then
					Repatch_Find = path_RePatch[i]
					break
				end
			end
			if Repatch_Find and files.exists(Repatch_Find.."/"..appman[cat].list[focus_index].id) then
				table.insert(options, { text = "RePatch", path = Repatch_Find.."/"..appman[cat].list[focus_index].id, exit = false })
			end

			--ReAddcont
			local ReAddcont_Find = nil
			local path_ReAddcont = { "ux0:/ReAddcont", "uma0:/ReAddcont", "imc0:/ReAddcont", "xmc0:/ReAddcont" }

			for i=1,#path_ReAddcont do
				if files.exists(path_ReAddcont[i].."/"..appman[cat].list[focus_index].id) then
					ReAddcont_Find = path_ReAddcont[i]
					break
				end
			end
			if ReAddcont_Find and files.exists(ReAddcont_Find.."/"..appman[cat].list[focus_index].id) then
				table.insert(options, { text = "ReAddcont", path = ReAddcont_Find.."/"..appman[cat].list[focus_index].id, exit = false })
			end

		end

	else

		if appman[cat].cats == "psm" then
			table.insert(options, { text = "PSM", path = appman[cat].list[focus_index].dev..":/psm/"..appman[cat].list[focus_index].id, exit = false })
		elseif appman[cat].cats == "retro" then
			table.insert(options, { text = "PSPEMU", path = appman[cat].list[focus_index].dev..":/pspemu/psp/game/"..appman[cat].list[focus_index].id, exit = false })
		end

	end
	table.insert(options, { text = STRINGS_SUBMENU_CANCEL, exit = true })

	local scroll_op,cccolor = newScroll(options, #options),""

	local vbuff = screen.toimage()
	while true do
		buttons.read()
		if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end

		draw.line(260,47,260,submenu_ctx.y + 145, color.green)
		draw.line(260,submenu_ctx.y + 145,360,submenu_ctx.y + 145, color.green)

		local y = 80
		for i=scroll_op.ini,scroll_op.lim do
			if i == scroll_op.sel then cccolor = color.green else cccolor = color.white end
			screen.print(350,y, options[i].text,1.0,cccolor,theme.style.TXTBKGCOLOR,__ARIGHT)
			y+=25
		end

		screen.flip()

		if buttons.up then scroll_op:up() elseif buttons.down then scroll_op:down() end

		if buttons.cancel then
			os.delay(15)
			if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
			return
		end

		if buttons.accept then
			if options[scroll_op.sel].exit then
				os.delay(15)
				if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
				return
			end
			break
		end

	end--while

	for i=1,#appman do 
		if #appman[i].list > 0 then
			for j=1,#appman[i].list do
				appman[i].list[j].pullsize = false
			end
		end
	end

	for i=1,#Root2 do
		if (appman[cat].list[focus_index].dev..":" == Root2[i]) then
			Dev = i
			break
		end
	end

	show_explorer_list(options[scroll_op.sel].path)

end

local sort_callback = function ()

	local options = {
		{ text = STRINGS_APP_SORT_ID },
		{ text = STRINGS_APP_SORT_TITLE },
	}

	if appman[cat].cats == "psvita" then
		table.insert(options, { text = STRINGS_APP_SORT_REGION })
	end

	local scroll_op,cccolor,mov = newScroll(options, #options),"",1

	local vbuff = screen.toimage()
	while true do
		buttons.read()
		if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end

		screen.print(350,80,STRINGS_APP_LIST_SORT,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ARIGHT)

		local y = 100
		for i=scroll_op.ini,scroll_op.lim do
			if i == scroll_op.sel then cccolor = color.green else cccolor = color.white end
			screen.print(350,y, options[i].text,1.0,cccolor,theme.style.TXTBKGCOLOR,__ARIGHT)
			y+=22
		end

		screen.flip()

		if buttons.up then scroll_op:up() elseif buttons.down then scroll_op:down() end

		if buttons.cancel then
			os.delay(15)
			if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
			return
		end

		if buttons.accept then mov = scroll_op.sel
			break
		end

	end--while

	options = {
		{ text = STRINGS_APP_SORT_ASCENDENT },
		{ text = STRINGS_APP_SORT_DESCENDENT },
	}
	scroll_op:set(options, #options)
	cccolor = ""

	local sort_asc = 1
	while true do
		buttons.read()
		if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end

		local y = 100
		for i=scroll_op.ini,scroll_op.lim do
			if i == scroll_op.sel then cccolor = color.green else cccolor = color.white end
			screen.print(350,y, options[i].text,1.0,cccolor,theme.style.TXTBKGCOLOR,__ARIGHT)
			y+=22
		end

		screen.flip()

		if buttons.up then scroll_op:up() elseif buttons.down then scroll_op:down() end

		if buttons.cancel then
			os.delay(15)
			if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
			return
		end

		if buttons.accept then
			if scroll_op.sel == 1 then sort_asc = 1
				elseif scroll_op.sel == 2 then sort_asc = 0
			end
			break
		end
	end--while

	os.delay(250)
		if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
		message_wait(STRINGS_APP_LIST_REFRESH)
	os.delay(250)

	appman[cat].sort, appman[cat].asc = mov-1, sort_asc
	if mov == 1 then
		sorting = STRINGS_APP_SORT_ID
	elseif mov == 2 then
		sorting = STRINGS_APP_SORT_TITLE
	elseif mov == 3 then
		sorting = STRINGS_APP_SORT_REGION
	end
	SortGeneric(appman[cat].list,appman[cat].sort,appman[cat].asc)

	write_config()
	os.delay(15)
	if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
	submenu_ctx.close = true
end

submenu_ctx = {
	h = 450,				-- Height of menu
	w = 355,				-- Width of menu
	x = -355,				-- X origin of menu
	y = 46,					-- Y origin of menu
	open = false,			-- Is open the menu?
	close = true,
	speed = 15,				-- Speed of Effect Open/Close.
	ctrl = "triangle",		-- The button handle Open/Close menu.
	scroll = newScroll(),	-- Scroll of menu options.
}

function submenu_ctx.wakefunct()

	-- Handle Option Text and Option Function
	submenu_ctx.options = {}

	table.insert(submenu_ctx.options, { text = STRINGS_APP_UNINSTALL, funct = uninstall_callback })

	if appman[cat].cats == "psvita" then
		table.insert(submenu_ctx.options, { text = STRINGS_APP_SHRINK_GAME, funct = shrink_callback })
	end

	if appman[cat].cats == "hbvita" then
		table.insert(submenu_ctx.options, { text = STRINGS_APP_SWITCH, funct = switch_callback })
	end

	if appman[cat].cats == "hbvita" or appman[cat].cats == "adrbb" then
		table.insert(submenu_ctx.options, { text = STRINGS_APP_EDIT_RESOURCES, funct = bubble_edit_callback })
	end

	if appman[cat].cats == "psvita" or appman[cat].cats == "hbvita" or appman[cat].cats == "adrbb" then
		table.insert(submenu_ctx.options, { text = STRINGS_APP_EDIT_BUBBLE, funct = editsfo_callback })
	end

	table.insert(submenu_ctx.options, { text = STRINGS_APP_OPEN_FOLDER, funct = openfolder_callback, })

	table.insert(submenu_ctx.options, { text = STRINGS_APP_SORT_CATEGORY..sorting, funct = sort_callback, pad = true })

	submenu_ctx.scroll = newScroll(submenu_ctx.options, #submenu_ctx.options)

end

function submenu_ctx.run()
	if buttons[submenu_ctx.ctrl] then submenu_ctx.close = not submenu_ctx.close end
	if buttons[submenu_ctx.ctrl] then submenu_ctx.wakefunct() end
    submenu_ctx.draw()
	submenu_ctx.buttons()
end

SIZES_PORT_I = channel.new("SIZES_PORT_I")
SIZES_PORT_O = channel.new("SIZES_PORT_O")
THID_SIZE = thread.new("system/appmanager/thread_size.lua")

local xprint = 12
function submenu_ctx.draw()

	if not submenu_ctx.close then
		restart_cronopic()
	end

	if appman[cat].sort == 0 then sorting = STRINGS_APP_SORT_ID
		elseif appman[cat].sort == 1 then sorting = STRINGS_APP_SORT_TITLE
			elseif appman[cat].sort == 2 then sorting = STRINGS_APP_SORT_REGION
	end

	if not submenu_ctx.close and submenu_ctx.x < 0 then
		submenu_ctx.x += submenu_ctx.speed
	elseif submenu_ctx.close and submenu_ctx.x > -submenu_ctx.w then
		submenu_ctx.x -= submenu_ctx.speed
	end

	--Peticion en hilo para obtener el Size
	if submenu_ctx.x > -submenu_ctx.w then

		if not appman[cat].list[focus_index].pullsize then

			local Repatch_Find = ""
			local path_RePatch = { "ux0:RePatch", "uma0:RePatch", "imc0:RePatch", "xmc0:RePatch" }

			for i=1,#path_RePatch do
				if files.exists(path_RePatch[i].."/"..appman[cat].list[focus_index].id) then
					Repatch_Find = path_RePatch[i]
					break
				end
			end
			local ReAddcont_Find = ""
			local path_ReAddcont = { "ux0:ReAddcont", "uma0:ReAddcont", "imc0:ReAddcont", "xmc0:ReAddcont" }

			for i=1,#path_ReAddcont do
				if files.exists(path_ReAddcont[i].."/"..appman[cat].list[focus_index].id) then
					ReAddcont_Find = path_ReAddcont[i]
					break
				end
			end

			appman[cat].list[focus_index].pullsize = true
			SIZES_PORT_O:push(	{ cat = cat, focus = focus_index, path = appman[cat].list[focus_index].path, id = appman[cat].list[focus_index].id,
								  repatch_path = Repatch_Find, readccont_path = ReAddcont_Find }) -- Enviamos peticion
		end

		
		if SIZES_PORT_I:available() > 0 then -- De tal manera que si se quedo un previo, lo pueda setear..
			local entry = SIZES_PORT_I:pop() -- Recibimos peticiones..
			if appman[entry.cat].list[entry.focus] and appman[entry.cat].list[entry.focus].path == entry.path then -- Por si lo borran o cambio etc..
				appman[entry.cat].list[entry.focus].size = entry.size
				appman[entry.cat].list[entry.focus].sizef = entry.sizef
				appman[entry.cat].list[entry.focus].sizef_patch = entry.sizef_patch
				appman[entry.cat].list[entry.focus].sizef_repatch = entry.sizef_repatch
				appman[entry.cat].list[entry.focus].sizef_addcont = entry.sizef_addcont
				appman[entry.cat].list[entry.focus].sizef_readdcont = entry.sizef_readdcont
			end
		end
		draw.fillrect(submenu_ctx.x, submenu_ctx.y, submenu_ctx.w, submenu_ctx.h, theme.style.BARCOLOR)
	end

	--Blit icons specials...battery, wifi, avatar...
	if batt.lifepercent()<30 then cbat = color.red else cbat = theme.style.PERCENTCOLOR end

	screen.print(925,15,batt.lifepercent().."%",1,cbat,color.gray,__ARIGHT)
	if not batt.charging() then
		if batt.lifepercent()<30 then cbat = theme.style.LOWBATTERYCOLOR else cbat = theme.style.BATTERYCOLOR end
		draw.fillrect(938,5+25,13,math.map(batt.lifepercent(), 0, 100, 0, -20 ), cbat)
		theme.data["buttons1"]:blitsprite(935,10,6)
	else
		theme.data["buttons1"]:blitsprite(935,10,7)
	end

	if os.getreg("/CONFIG/SYSTEM/", "flight_mode", 1) == 1 then
		theme.data["wifi"]:blitsprite(840,10,5)
	else
		local frame = wlan.strength()
		if frame then
			theme.data["wifi"]:blitsprite(840,10,math.ceil(frame/25))
		else
			theme.data["wifi"]:blitsprite(840,10,0)
		end
	end

	if avatar then avatar:blit(790,5) end

	if submenu_ctx.x >= 0 then
		submenu_ctx.open = true
		local h = submenu_ctx.y + 13 -- Punto de origen de las opciones

		for i=submenu_ctx.scroll.ini,submenu_ctx.scroll.lim do

			if i==submenu_ctx.scroll.sel then

				if submenu_ctx.options[submenu_ctx.scroll.sel].text == STRINGS_APP_SWITCH then
					draw.fillrect(5,h-2,215,23,theme.style.SELCOLOR)
				else draw.fillrect(5,h-2,335,23,theme.style.SELCOLOR) end

				if screen.textwidth(submenu_ctx.options[i].text) > 320 then
					xprint = screen.print(xprint, h, submenu_ctx.options[i].text, 1, color.green,theme.style.TXTBKGCOLOR, __SLEFT,320)
				else
					screen.print(12, h, submenu_ctx.options[i].text, 1, color.green,theme.style.TXTBKGCOLOR, __ALEFT)
					xprint = 12
				end

			else
				screen.print(12, h, submenu_ctx.options[i].text, 1, color.white,theme.style.TXTBKGCOLOR, __ALEFT)
			end

			h += 26

		end

		if screen.textwidth(STRINGS_APP_LIST_SORT_NOW) > 320 then
			if appman[cat].asc == 1 then
				xprint = screen.print(xprint, h+20, STRINGS_APP_LIST_SORT_NOW.." "..sorting.."/"..STRINGS_APP_SORT_ASCENDENT, 1, color.white,theme.style.TXTBKGCOLOR, __SLEFT,320)
			else
				xprint = screen.print(xprint, h+20, STRINGS_APP_LIST_SORT_NOW.." "..sorting.."/"..STRINGS_APP_SORT_DESCENDENT, 1, color.white,theme.style.TXTBKGCOLOR, __SLEFT,320)
			end
		else
			if appman[cat].asc == 1 then
				screen.print(12, h+20, STRINGS_APP_LIST_SORT_NOW.." "..sorting.."/"..STRINGS_APP_SORT_ASCENDENT, 1, color.white,theme.style.TXTBKGCOLOR, __ALEFT)
			else
				screen.print(12, h+20, STRINGS_APP_LIST_SORT_NOW.." "..sorting.."/"..STRINGS_APP_SORT_DESCENDENT, 1, color.white,theme.style.TXTBKGCOLOR, __ALEFT)
			end
			xprint = 12
		end

		--Textos informativos en el submenu
		draw.gradline(5,268,submenu_ctx.w - 15,268,theme.style.GRADRECTCOLOR, theme.style.GRADSHADOWCOLOR)
		draw.gradline(5,269,submenu_ctx.w - 15,269,theme.style.GRADSHADOWCOLOR, theme.style.GRADRECTCOLOR)

		local h = 280
		screen.print(10,h, STRINGS_APP_VERSION..": "..appman[cat].list[focus_index].version or "", 1.0, theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
		h+=30
		--if cat == 3 or cat == 4 then--or cat == 6 then
		if appman[cat].cats == "psm" or appman[cat].cats == "retro" then
			screen.print(10,h, STRINGS_APP_SIZE_IND..": ", 1.0, theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
		else
			screen.print(10,h, "App: ", 1.0, theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
		end
		screen.print(340,h,(appman[cat].list[focus_index].sizef or STRINGS_APP_GET_SIZE),1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ARIGHT)

		h+=26
		--if cat == 1 then
		if appman[cat].cats == "psvita" then

			screen.print(10,h, "SaveID: ", 1.0, theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
			screen.print(340,h,(appman[cat].list[focus_index].save),1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ARIGHT)

			h+=35
			screen.print(10,h, "Patch: ", 1.0, theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT )
			screen.print(340,h,(appman[cat].list[focus_index].sizef_patch or STRINGS_APP_GET_SIZE),1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ARIGHT)
			h+=26
			screen.print(10,h, "RePatch: ", 1.0, theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
			screen.print(340,h,(appman[cat].list[focus_index].sizef_repatch or STRINGS_APP_GET_SIZE),1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ARIGHT)

			h+=35
			screen.print(10,h, "Addcont: ", 1.0, theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
			screen.print(340,h,(appman[cat].list[focus_index].sizef_addcont or STRINGS_APP_GET_SIZE),1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ARIGHT)
			h+=26
			screen.print(10,h, "ReAddcont: ", 1.0, theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
			screen.print(340,h,(appman[cat].list[focus_index].sizef_readdcont or STRINGS_APP_GET_SIZE),1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ARIGHT)

		end

	else
		submenu_ctx.open = false
	end
end

function submenu_ctx.buttons()
	if not submenu_ctx.open then return end

	if buttons.up or buttons.analogly < -60 then submenu_ctx.scroll:up() end
	if buttons.down or buttons.analogly > 60 then submenu_ctx.scroll:down() end

	if buttons.cancel then -- Run function of cancel option.
		submenu_ctx.close = not submenu_ctx.close
	end

	if buttons.accept or ( (buttons.left or buttons.right) and submenu_ctx.options[submenu_ctx.scroll.sel].pad ) then
		submenu_ctx.options[submenu_ctx.scroll.sel].funct()
	end

end
