--[[ 
   ONEMenu
   Application, themes and files manager.
   
   Licensed by Creative Commons Attribution-ShareAlike 4.0
   http://creativecommons.org/licenses/by-sa/4.0/
   
   Designed By Gdljjrod & DevDavisNunez.
   Collaborators: BaltazaR4 & Wzjk.
]]

__STITLE, __TITLE, __EDITB = "","",false

categories = {
    { img = theme.data["psvita"] },  --cat 1
    { img = theme.data["hbvita"] },  --cat 2
	{ img = theme.data["psm"] },     --cat 3
	{ img = theme.data["retro"] },   --cat 4
	{ img = theme.data["adrbb"] },   --cat 5
}

--Variable para permitir Reiniciar nuestra app
reboot = true

-- Timer and Oldstate to click actions.
local crono, clicked = timer.new(), false
cronopic, show_pic = timer.new(), false
flag_begin = false
pic_alpha = 0

limit,movx=7,0
elev = 0
favs,sorting="",""

function launch_game()
	if appman[cat].list[focus_index].type == "ME" then game.open(appman[cat].list[focus_index].id)
	else game.launch(appman[cat].list[focus_index].id) end
end

function restart_cronopic()
	cronopic:reset()
		cronopic:start()
			show_pic,pic1_crono = false,nil
		pic_alpha = 0
	flag_begin = true
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
				if theme.data["jump"] then theme.data["jump"]:play() end
				elev=0
				restart_cronopic()
			end

		end

	end

	if buttons[accept] then launch_game() end
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

	if cronopic:time() > 950 and flag_begin then
		show_pic = true
	end

end

function appman.launch()

	buttons.interval(10,10)
	local counter = 0
	while true do

		buttons.read()
			touch.read()
		swipe.read()

		while IMAGE_PORT_I:available() > 0 do -- While have availables request.
			local entry = IMAGE_PORT_I:pop() -- Recibimos peticiones..
			if static_void[entry.y][entry.x].path_img == entry.path then -- Check ident
				if entry.img then 
					static_void[entry.y][entry.x].img = entry.img
				end
			end
			counter += 1
			entry = nil
		end
		
		if counter == appman.len then -- Recv all request, then all exists is loaded and return CPU/GPU
			os.cpu(__CPU)
			os.gpuclock(__GPU)
			flag_begin = true
		end

		buttons_reasign()

		if theme.data["back"] then theme.data["back"]:blit(0,0) end

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

		if buttons.select and not submenu_ctx.open then
			for i=1,#categories do 
				if #appman[i].list > 0 then
					for j=1,#appman[i].list do
						appman[i].list[j].pullsize = false
					end
				end
			end
			show_explorer_list()
		end--to Explorer

		if buttons.start and not submenu_ctx.open then system.run()	end--To System Apps

		shortcuts()

	end
end

---------------------------------- SubMenu Contextual 1 ---------------------------------------------------
local refresh_callback = function ()
	refresh_init(theme.data["back"])
	restart_cronopic()
	pic1=nil
	submenu_ctx.wakefunct()
end

local uninstall_callback = function ()
	if appman[cat].list[focus_index].id != __ID and appman[cat].list[focus_index].dev != "gro0" then

		local vbuff = screen.toimage()
		if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end

		if os.message(STRINGS_APP_REMOVE + appman[cat].list[focus_index].id + "?",1) == 1 then
			if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
			message_wait()

			--Backup Save from ux0:user/00/savedata
			if files.exists("ux0:user/00/savedata/"..appman[cat].list[focus_index].id) and cat == 1 then
				if os.message(STRINGS_APP_BACKUP_SAVE, 1) == 1 then
					files.copy("ux0:user/00/savedata/"..appman[cat].list[focus_index].id, "ux0:data/ONEMenu/Saves/")
				end
			end

			buttons.homepopup(0)
				reboot=false
					local result_rmv = game.delete(appman[cat].list[focus_index].id)
				reboot=true
			buttons.homepopup(1)

			if result_rmv == 1 then
				if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end

				if files.exists("ux0:repatch/"..appman[cat].list[focus_index].id) then
					if os.message(STRINGS_SUBMENU_DELETE.."\n\n".."ux0:rePatch/"..appman[cat].list[focus_index].id.."?",1) == 1 then
						reboot=false
							files.delete("ux0:rePatch/"..appman[cat].list[focus_index].id)
						reboot=true
					end
				end
				if files.exists("ux0:readdcont/"..appman[cat].list[focus_index].id) then
					if os.message(STRINGS_SUBMENU_DELETE.."\n\n".."ux0:readdcont/"..appman[cat].list[focus_index].id.."?",1) == 1 then
						reboot=false
							files.delete("ux0:readdcont/"..appman[cat].list[focus_index].id)
						reboot=true
					end
				end

				if cat == 5 then--Only Adrenaline Bubbles
					for i=1,#apps do
						if apps[i] == appman[cat].list[focus_index].id then
							table.remove(apps,z)
							write_favs(__PATH_FAVS)
							appman[cat].list[focus_index].fav = false

							if #apps <=0 then
								if __FAV == 1 then __FAV = 0 end
							end
							write_config()
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
				appman.len -= 1
				infodevices()
			end
			submenu_ctx.close = true
		end
		os.delay(15)
		if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
	end
end

local shrink_callback = function ()

	if cat == 1 and appman[cat].list[focus_index].dev != "gro0" then--Only Vita Games in ux0:app

		local vbuff = screen.toimage()
		if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end

		local list_patch, list_app = {},{}

		function getlist(_path, _list, substring)
			local tmp = files.list(_path)	
			if tmp and #tmp > 0 then
				for i=1, #tmp do
					if tmp[i].directory then
						if not tmp[i].name:find("sce_",1) then getlist(tmp[i].path, _list, substring) end
					else
						if tmp[i].name != "eboot.bin" then
							local _size = (tmp[i].size or files.size(tmp[i].path))
							table.insert(_list, {path = tmp[i].path:gsub(substring,'ux0:app'):lower(), size = _size})
						end
					end
				end
			end
		end
		message_wait("ux0:Patch")
		os.delay(15)

		getlist("ux0:patch/"..appman[cat].list[focus_index].id, list_patch, "ux0:patch")
		getlist("ux0:app/"..appman[cat].list[focus_index].id, list_app, "ux0:patch")

		local size_del,list_del = 0,{}
		if #list_patch > 0 and #list_app > 0 then
			for i=1,#list_patch do
				for j=1,#list_app do
					if list_patch[i].path == list_app[j].path then
						size_del += list_app[j].size
						table.insert(list_del,list_app[j].path)
					end
				end
			end
		end

		if #list_del > 0 then
			if os.message(STRINGS_APP_SHRINK.."\n\n                        ux0:patch\n\n"..STRINGS_COUNT..#list_del.." "..STRINGS_CALLBACKS_MOVE_FILES.." "..files.sizeformat(size_del or 0).." "..STRINGS_APP_SHRINK_FREE,1) == 1 then
				for i=1,#list_del do
					files.delete(list_del[i])
				end
				--update size
				appman[cat].list[focus_index].size = files.size(appman[cat].list[focus_index].path)
				appman[cat].list[focus_index].sizef = files.sizeformat((appman[cat].list[focus_index].size or 0))
			end
		else
			os.message(STRINGS_APP_SHRINK_NO_FILES)
		end
		os.delay(15)

----------------repatch
		if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
		message_wait("ux0:rePatch")
		os.delay(15)

		list_patch, list_app = {},{}
		getlist("ux0:repatch/"..appman[cat].list[focus_index].id, list_patch, "ux0:repatch")
		getlist("ux0:app/"..appman[cat].list[focus_index].id, list_app, "ux0:repatch")

		local size_del,list_del = 0,{}
		if #list_patch > 0 and #list_app > 0 then
			for i=1,#list_patch do
				for j=1,#list_app do
					if list_patch[i].path == list_app[j].path then
						size_del += list_app[j].size
						table.insert(list_del,list_app[j].path)
					end
				end
			end
		end

		if #list_del > 0 then
			if os.message(STRINGS_APP_SHRINK.."\n\n                        ux0:rePatch\n\n"..STRINGS_COUNT..#list_del.." "..STRINGS_CALLBACKS_MOVE_FILES.." "..files.sizeformat(size_del or 0).." "..STRINGS_APP_SHRINK_FREE,1) == 1 then
				for i=1,#list_del do
					files.delete(list_del[i])
				end
				--update size
				appman[cat].list[focus_index].size = files.size(appman[cat].list[focus_index].path)
				appman[cat].list[focus_index].sizef = files.sizeformat((appman[cat].list[focus_index].size or 0))
			end
		else
			os.message(STRINGS_APP_SHRINK_NO_FILES)
		end
		os.delay(15)

----------------readdcont
		if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
		message_wait("ux0:readdcont")
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
		getlistaddcont("ux0:readdcont/"..appman[cat].list[focus_index].id, list_patch, "ux0:readdcont")
		getlistaddcont("ux0:addcont/"..appman[cat].list[focus_index].id, list_app, "ux0:readdcont")

		local size_del,list_del = 0,{}
		if #list_patch > 0 and #list_app > 0 then
			for i=1,#list_patch do
				for j=1,#list_app do
					if list_patch[i].path == list_app[j].path then
						size_del += list_app[j].size
						table.insert(list_del,list_app[j].path)
					end
				end
			end
		end

		if #list_del > 0 then
			if os.message(STRINGS_APP_SHRINK.."\n\n                        ux0:readdcont\n\n"..STRINGS_COUNT..#list_del.." "..STRINGS_CALLBACKS_MOVE_FILES.." "..files.sizeformat(size_del or 0).." "..STRINGS_APP_SHRINK_FREE,1) == 1 then
				for i=1,#list_del do
					files.delete(list_del[i])
				end
				--update addcont&readccont
				appman[cat].list[focus_index].sizef_addcont = files.sizeformat(files.size("ux0:addcont/"..appman[cat].list[focus_index].id or 0))
				appman[cat].list[focus_index].sizef_readdcont = files.sizeformat(files.size("ux0:readdcont/"..appman[cat].list[focus_index].id or 0))
			end
		else
			os.message(STRINGS_APP_SHRINK_NO_FILES)
		end
		os.delay(15)

----------------sce_sys/manual/
		if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
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
			if os.message(STRINGS_APP_DELETE_MANUAL.."\n\n"..STRINGS_COUNT..files_manual.." "..STRINGS_CALLBACKS_MOVE_FILES.." "..files.sizeformat(size_manual or 0).." "..STRINGS_APP_SHRINK_FREE,1) == 1 then
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

				--update sizef in patch
				appman[cat].list[focus_index].sizef_patch = files.sizeformat(files.size("ux0:patch/"..appman[cat].list[focus_index].id or 0))
			end
		else
			os.message(STRINGS_APP_NOTFIND_MANUAL)
		end

		infodevices()
		os.delay(15)
		if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end

	end
end

local switch_callback = function ()

	if appman[cat].list[focus_index].type == "mb" or appman[cat].list[focus_index].type == "EG" or appman[cat].list[focus_index].type == "ME" then return end

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

		if buttons[cancel] then
			os.delay(15)
			if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
			return
		end

		if buttons[accept] then
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

local editsfo_callback = function ()

	if appman[cat].list[focus_index].dev == "gro0" then return end

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

local pic1_callback = function ()

	local pos_menu = submenu_ctx.scroll.sel

	if __PIC1 == 1 then
		__PIC1,showpic = 0,STRINGS_APP_NO
	else
		__PIC1,showpic = 1,STRINGS_APP_YES
	end

	submenu_ctx.wakefunct()
	write_config()

	submenu_ctx.scroll.sel = pos_menu
end

local fav_callback = function ()

	local pos_menu = submenu_ctx.scroll.sel

	appman[cat].list[focus_index].fav = not appman[cat].list[focus_index].fav

	if appman[cat].list[focus_index].fav then
		favs = STRINGS_APP_YES
		table.insert(apps, appman[cat].list[focus_index].id)
	else
		favs = STRINGS_APP_NO
		for j=1,#apps do
			if appman[cat].list[focus_index].id == apps[j] then
				table.remove(apps, j)
			end
		end
	end

	write_favs(__PATH_FAVS)
	submenu_ctx.wakefunct()
	submenu_ctx.scroll.sel = pos_menu
end

__OPEN = false
local openfolder_callback = function ()

	if cat == 1 or cat == 2 or cat == 5 then
	
		local options = {
			{ text = "app", exit=false }
		}

		if files.exists(appman[cat].list[focus_index].dev..":/patch/"..appman[cat].list[focus_index].id) then
			table.insert(options, { text = "patch", exit=false })
		end
		if files.exists(appman[cat].list[focus_index].dev..":/repatch/"..appman[cat].list[focus_index].id) then
			table.insert(options, { text = "repatch", exit=false })
		end
		table.insert(options, { text = STRINGS_SUBMENU_CANCEL, exit=true })

		local scroll_op,cccolor = newScroll(options, #options),""

		if #options > 2 then
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

				if buttons[cancel] then
					os.delay(15)
					if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
					return
				end

				if buttons[accept] then
					if options[scroll_op.sel].exit then
						os.delay(15)
						if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
						return
					end
					break
				end

			end--while
		end

		for i=1,#categories do 
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

		if files.exists(appman[cat].list[focus_index].dev..":/"..options[scroll_op.sel].text.."/"..appman[cat].list[focus_index].id) then
			show_explorer_list(appman[cat].list[focus_index].dev..":/"..options[scroll_op.sel].text.."/"..appman[cat].list[focus_index].id)
		end

	end

end

---------------------------------- SubMenu Contextual 2 ---------------------------------------------------
local themesONEMenu_callback = function ()
	local pos_menu = submenu_ctx.scroll.sel
	theme.manager()
	submenu_ctx.wakefunct2()
	submenu_ctx.scroll.sel = pos_menu
end

local slides_callback = function ()
	local pos_menu = submenu_ctx.scroll.sel
	if __SLIDES == 100 then __SLIDES = 415 else __SLIDES = 100 end

	submenu_ctx.wakefunct2()
	write_config()

	submenu_ctx.scroll.sel = pos_menu
end

local togglefavs_callback = function ()
	local pos_menu = submenu_ctx.scroll.sel

	if __FAV == 1 then
		__FAV,_favs = 0,STRINGS_APP_NO
		write_config()
	else
		if #apps > 0 then
			__FAV,_favs = 1,STRINGS_APP_YES
			write_config()
		else
			os.message(STRINGS_FAVORITES_ACTIVED)
			os.delay(15)
			if theme.data["back"] then theme.data["back"]:blit(0,0) end
		end
	end
	submenu_ctx.wakefunct2()
	submenu_ctx.scroll.sel = pos_menu
end

local sort_callback = function ()

	local options = {
		{ text = STRINGS_APP_SORT_ID },
		{ text = STRINGS_APP_SORT_TITLE },
	}
	if cat == 1 then
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

		if buttons[cancel] then
			os.delay(15)
			if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
			return
		end

		if buttons[accept] then
			if scroll_op.sel == 1 then mov = 1
				elseif scroll_op.sel == 2 then mov = 2
					elseif scroll_op.sel == 3 then mov = 3
			end
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

		if buttons[cancel] then
			os.delay(15)
			if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
			return
		end

		if buttons[accept] then
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

	
	if cat == 1 and mov == 3 then
		appman[cat].sort,appman[cat].asc = 2,sort_asc
		sorting = STRINGS_APP_SORT_REGION
		table.sort(appman[cat].list, tableSortReg)
	else
		if mov == 1 then
			appman[cat].sort,appman[cat].asc = 0,sort_asc
			sorting = STRINGS_APP_SORT_ID
			if appman[cat].asc == 1 then
				table.sort(appman[cat].list, function (a,b) return string.lower(a.id)<string.lower(b.id) end)
			else
				table.sort(appman[cat].list, function (a,b) return string.lower(a.id)>string.lower(b.id) end)
			end
		elseif mov == 2 then
			appman[cat].sort,appman[cat].asc = 1,sort_asc
			sorting = STRINGS_APP_SORT_TITLE
			if appman[cat].asc == 1 then
				table.sort(appman[cat].list, function (a,b) return string.lower(a.title)<string.lower(b.title) end)
			else
				table.sort(appman[cat].list, function (a,b) return string.lower(a.title)>string.lower(b.title) end)
			end
		end
	end

	write_config()
	os.delay(15)
	if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
	submenu_ctx.close = true
end

local update_callback = function ()
	local pos_menu = submenu_ctx.scroll.sel

	if __UPDATE == 1 then 
		_update = STRINGS_APP_NO
		__UPDATE = 0
	else
		_update = STRINGS_APP_YES
		__UPDATE = 1
	end

	write_config()
	os.delay(150)

	submenu_ctx.wakefunct2()
	submenu_ctx.scroll.sel = pos_menu
end

local themesONEMenu_callback = function ()
	local pos_menu = submenu_ctx.scroll.sel
	theme.manager()
	submenu_ctx.wakefunct2()
	submenu_ctx.scroll.sel = pos_menu
end

local slides_callback = function ()
	local pos_menu = submenu_ctx.scroll.sel
	if __SLIDES == 100 then __SLIDES = 415 else __SLIDES = 100 end

	submenu_ctx.wakefunct2()
	write_config()

	submenu_ctx.scroll.sel = pos_menu
end

local togglefavs_callback = function ()
	local pos_menu = submenu_ctx.scroll.sel

	if __FAV == 1 then
		__FAV,_favs = 0,STRINGS_APP_NO
		write_config()
	else
		if #apps > 0 then
			__FAV,_favs = 1,STRINGS_APP_YES
			write_config()
		else
			os.message(STRINGS_FAVORITES_ACTIVED)
			os.delay(15)
			if theme.data["back"] then theme.data["back"]:blit(0,0) end
		end
	end
	submenu_ctx.wakefunct2()
	submenu_ctx.scroll.sel = pos_menu
end

local Re_Folders_Cleanup_callback = function ()

	local vbuff = screen.toimage()
	if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end

	local list_RePatch, list_ReAddcont = {},{}

--ReAddcont

	if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
		message_wait("ux0:ReAddcont")
	os.delay(1250)

	local tmp = files.listdirs("ux0:ReAddcont")
	local size_Readdcont = 0
	if tmp and #tmp > 0 then
		for i=1, #tmp do
			if tmp[i].directory then
				if not game.exists(tmp[i].name) then
					local _size = files.size(tmp[i].path) or 0
					size_Readdcont += _size
					if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
						message_wait("ReAddcont\n\n"..tmp[i].name)
					os.delay(600)
					table.insert(list_ReAddcont, { path = tmp[i].path, name = tmp[i].name, size = _size })
				end
			end
		end
	end

--Repatch

	if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
		message_wait("ux0:RePatch")
	os.delay(1250)

	local tmp = files.listdirs("ux0:RePatch")
	local size_RePatch = 0
	if tmp and #tmp > 0 then
		for i=1, #tmp do
			if tmp[i].directory then
				if not game.exists(tmp[i].name) then
					local _size = files.size(tmp[i].path) or 0
					size_RePatch += _size
					if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
					message_wait("RePatch\n\n"..tmp[i].name)
					os.delay(600)
					table.insert(list_RePatch, { path = tmp[i].path, name = tmp[i].name, size = _size })
				end
			end
		end
	end

	--Delete?
	if #list_ReAddcont > 0 then
		if os.message(STRINGS_APP_FOUND_REFOLDERS.." : "..#list_ReAddcont.." "..STRINGS_APP_REFOLDERS_GAME.." ReAddcont\n\n"..STRINGS_CALLBACKS_SIZE_ALL..files.sizeformat(size_Readdcont or 0).."\n\n"..STRINGS_APP_REFOLDERS_DELETE,1) == 1 then
			for i=1,#list_ReAddcont do
				files.delete(list_ReAddcont[i].path)
			end
		end
	end

	if #list_RePatch > 0 then
		if os.message(STRINGS_APP_FOUND_REFOLDERS.." : "..#list_RePatch.." "..STRINGS_APP_REFOLDERS_GAME.." RePatch\n\n"..STRINGS_CALLBACKS_SIZE_ALL..files.sizeformat(size_RePatch or 0).."\n\n"..STRINGS_APP_REFOLDERS_DELETE,1) == 1 then
			for i=1,#list_RePatch do
				files.delete(list_RePatch[i].path)
			end
		end
	end


	if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
	submenu_ctx.close = true
end

local restart_callback = function ()
    os.delay(150)
    os.restart()
end

local reboot_callback = function ()
    os.delay(1000)
    power.restart()
end

local shutdown_callback = function ()
    os.delay(1000)
    power.shutdown()
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
	type = 1,
}

function submenu_ctx.wakefunct()

	if __PIC1 == 1 then showpic = STRINGS_APP_YES else showpic = STRINGS_APP_NO end

	submenu_ctx.options = { -- Handle Option Text and Option Function
		{ text = STRINGS_REFRESH_LIVEAREA,     	funct = refresh_callback },
		{ text = STRINGS_APP_UNINSTALL,       	funct = uninstall_callback },
		{ text = STRINGS_APP_SHRINK_GAME,       funct = shrink_callback },
		{ text = STRINGS_APP_SWITCH,         	funct = switch_callback },
		{ text = STRINGS_APP_EDIT_BUBBLE,       funct = editsfo_callback },
		{ text = STRINGS_APP_SHOW_PIC..showpic, funct = pic1_callback, pad = true },
		{ text = STRINGS_APP_MARK_FAV..favs,    funct = fav_callback,  pad = true },
		{ text = STRINGS_APP_OPEN_FOLDER,       funct = openfolder_callback,  pad = true },
	}
	submenu_ctx.scroll = newScroll(submenu_ctx.options, #submenu_ctx.options)
end

function submenu_ctx.wakefunct2()

	if __SLIDES == 100 then var = STRINGS_APP_SLIDE_ORIGINAL else var = STRINGS_APP_SLIDE_PS4 end
	if __FAV == 1 then _favs = STRINGS_APP_YES else _favs = STRINGS_APP_NO end

    submenu_ctx.options = { -- Handle Option Text and Option Function
        { text = STRINGS_SUBMENU_THEMES,            	funct = themesONEMenu_callback },
        { text = STRINGS_APP_SLIDES..var,       		funct = slides_callback,     pad = true },
		{ text = STRINGS_FAVORITES_TOGGLE.._favs,		funct = togglefavs_callback, pad = true },
		{ text = STRINGS_APP_SORT_CATEGORY..sorting,	funct = sort_callback,       pad = true },
		{ text = STRINGS_ENABLE_UPDATE.._update,   		funct = update_callback,     pad = true },

		{ text = STRINGS_REFOLDERS_CLEANUP,				funct = Re_Folders_Cleanup_callback },

		{ text = STRINGS_SUBMENU_RESTART,         		funct = restart_callback },
        { text = STRINGS_SUBMENU_RESET,             	funct = reboot_callback },
        { text = STRINGS_SUBMENU_POWEROFF,              funct = shutdown_callback },
    }
    submenu_ctx.scroll = newScroll(submenu_ctx.options, #submenu_ctx.options)
end

submenu_ctx.wakefunct()
submenu_ctx.wakefunct2()

function submenu_ctx.run()

    if buttons[submenu_ctx.ctrl] then submenu_ctx.close = not submenu_ctx.close end
	if buttons[submenu_ctx.ctrl] then
		submenu_ctx.type = 1
		submenu_ctx.wakefunct()
	end

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

	if appman[cat].list[focus_index].fav then favs = STRINGS_APP_YES else favs = STRINGS_APP_NO end

	if appman[cat].sort == 0 then sorting = STRINGS_APP_SORT_ID
		elseif appman[cat].sort == 1 then sorting = STRINGS_APP_SORT_TITLE
			elseif appman[cat].sort == 2 then sorting = STRINGS_APP_SORT_REGION
	end

	--gd,gp PSVITA:1	hbsvita2	mb PSM:3	EG PSP & ME PSX: 4		AdrenalineBubbles:5
	if not submenu_ctx.close and not pic1 then

		if __PIC1 == 1 then
			if appman[cat].list[focus_index].type == "mb" then
				pic1 = game.bg0(appman[cat].list[focus_index].id)
				if not pic1 then
					pic1 = image.load(string.format("%s/pic0.png","ur0:appmeta/"..appman[cat].list[focus_index].id))
				end
			else
				pic1 = image.load(string.format("%s/pic0.png","ur0:appmeta/"..appman[cat].list[focus_index].id))
				if not pic1 then
					pic1 = game.bg0(appman[cat].list[focus_index].id)
				end
			end
			if pic1 then
				pic1:resize(960,460)
				pic1:center()
			end
		end

	end

	if not submenu_ctx.close and submenu_ctx.x < 0 then
		submenu_ctx.x += submenu_ctx.speed
	elseif submenu_ctx.close and submenu_ctx.x > -submenu_ctx.w then
		submenu_ctx.x -= submenu_ctx.speed
	end

	--Peticion en hilo para obtener el Size
	if submenu_ctx.x > -submenu_ctx.w then

		if submenu_ctx.type == 1 then
			if not appman[cat].list[focus_index].pullsize then
				appman[cat].list[focus_index].pullsize = true
				SIZES_PORT_O:push({cat = cat, focus = focus_index, path = appman[cat].list[focus_index].path, id = appman[cat].list[focus_index].id }) -- Enviamos peticion
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

				if submenu_ctx.type == 1 then
					if (i!=4) then draw.fillrect(5,h-2,335,23,theme.style.SELCOLOR)
					else draw.fillrect(5,h-2,215,23,theme.style.SELCOLOR) end
				else
					draw.fillrect(5,h-2,335,23,theme.style.SELCOLOR)
				end

				if screen.textwidth(submenu_ctx.options[i].text) > 320 then
					xprint = screen.print(xprint, h, submenu_ctx.options[i].text, 1, color.green,theme.style.TXTBKGCOLOR, __SLEFT,320)
				else
					screen.print(12, h, submenu_ctx.options[i].text, 1, color.green,theme.style.TXTBKGCOLOR, __ALEFT)
					xprint = 12
				end

			else
				screen.print(12, h, submenu_ctx.options[i].text, 1, color.white,theme.style.TXTBKGCOLOR, __ALEFT)
			end

			if submenu_ctx.type == 2 and i == 3 then
				h += 70

				if screen.textwidth(STRINGS_APP_LIST_SORT_NOW) > 320 then
					if appman[cat].asc == 1 then
						xprint = screen.print(xprint, 160, STRINGS_APP_LIST_SORT_NOW.." "..sorting.."/"..STRINGS_APP_SORT_ASCENDENT, 1, color.white,theme.style.TXTBKGCOLOR, __SLEFT,320)
					else
						xprint = screen.print(xprint, 160, STRINGS_APP_LIST_SORT_NOW.." "..sorting.."/"..STRINGS_APP_SORT_DESCENDENT, 1, color.white,theme.style.TXTBKGCOLOR, __SLEFT,320)
					end
				else
					if appman[cat].asc == 1 then
						screen.print(12, 160, STRINGS_APP_LIST_SORT_NOW.." "..sorting.."/"..STRINGS_APP_SORT_ASCENDENT, 1, color.white,theme.style.TXTBKGCOLOR, __ALEFT)
					else
						screen.print(12, 160, STRINGS_APP_LIST_SORT_NOW.." "..sorting.."/"..STRINGS_APP_SORT_DESCENDENT, 1, color.white,theme.style.TXTBKGCOLOR, __ALEFT)
					end
					xprint = 12
				end
			elseif submenu_ctx.type == 2 and (i == 4 or i==5 or i==6) then
				h += 45
			else
				h += 26
			end

		end

		--Textos informativos en el submenu
		if submenu_ctx.type == 1 then

			draw.gradline(5,268,submenu_ctx.w - 15,268,theme.style.GRADRECTCOLOR, theme.style.GRADSHADOWCOLOR)
			draw.gradline(5,269,submenu_ctx.w - 15,269,theme.style.GRADSHADOWCOLOR, theme.style.GRADRECTCOLOR)

			local h = 280
			screen.print(10,h, STRINGS_APP_VERSION..": "..appman[cat].list[focus_index].version or "", 1.0, theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
			h+=30
			if cat == 3 or cat == 4 then
				screen.print(10,h, STRINGS_APP_SIZE_IND..": ", 1.0, theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
			else
				screen.print(10,h, "App: ", 1.0, theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
			end
			screen.print(340,h,(appman[cat].list[focus_index].sizef or STRINGS_APP_GET_SIZE),1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ARIGHT)

			h+=35
			if cat == 1 then

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

		end

	else
		submenu_ctx.open = false
	end
end

function submenu_ctx.buttons()
	if not submenu_ctx.open then return end

	if buttons.up or buttons.analogly < -60 then submenu_ctx.scroll:up() end
	if buttons.down or buttons.analogly > 60 then submenu_ctx.scroll:down() end

	if buttons[cancel] then -- Run function of cancel option.
		submenu_ctx.close = not submenu_ctx.close
	end

	if buttons[accept] then
		submenu_ctx.options[submenu_ctx.scroll.sel].funct()
	end
	if (buttons.left or buttons.right) and submenu_ctx.options[submenu_ctx.scroll.sel].pad then
		submenu_ctx.options[submenu_ctx.scroll.sel].funct()
	end

	if buttons.released.l or buttons.released.r then
		if submenu_ctx.type == 1 then
			submenu_ctx.type = 2
			submenu_ctx.wakefunct2()
		else
			submenu_ctx.type = 1
			submenu_ctx.wakefunct()
		end
	end
end
