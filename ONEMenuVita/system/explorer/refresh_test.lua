--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

function fillapps(list, obj)

	local info = game.info(obj.path.."/sce_sys/param.sfo")
	if info then
		if info.TITLE_ID and info.CATEGORY != "gda" then

			if info.TITLE then info.TITLE = info.TITLE:gsub("\n"," ") else info.TITLE = "UNK" end

			local resize = false
			if info.CATEGORY == "mb" or info.CATEGORY == "EG" or info.CATEGORY == "ME" then
				resize = true
			end

			local index = 1
			if obj.id == "PSPEMUCFW" then index = 3--index = 5 
			else

				if info.CONTENT_ID and info.CONTENT_ID:len() > 9 then
					index = 1
				else

					--checking magic
					local fp = io.open(obj.path.."/data/boot.bin","r")
					if fp then
						local magic = str2int(fp:read(4))
						fp:close()
						if magic == 0x00424241 then	index = 3 else index = 2 end
					else
						index = 2
					end
				end
			end

			table.insert(list, { id=info.TITLE_ID, type=info.CATEGORY, version=info.APP_VER or "00.00", title = info.TITLE or info.TITLE_ID,
								 path = obj.path, index = index, resize = resize, save = info.INSTALL_DIR_SAVEDATA or info.TITLE_ID,
								 sdk = info.PSP2_SYSTEM_VER or 0,
					    })
		end
	end

end

function refresh_init(img)

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

	if img then img:blit(0,0) end
	message_wait()
	os.delay(15)

	local vbuff = screen.toimage()
	if vbuff then vbuff:blit(0,0) elseif img then img:blit(0,0) end


	local list = {}
	--Scanning ux0:app
	local tmp = files.listdirs("ux0:app")
	if tmp and #tmp > 0 then
		table.sort(tmp ,function (a,b) return string.lower(a.name)<string.lower(b.name) end)
		for i=1, #tmp do
			if game.exists(tmp[i].name) then
				if not game.rif(tmp[i].name) then
					fillapps(list, tmp[i])
				end
			else
				fillapps(list, tmp[i])
			end
		end
	end

	--Scanning ux0:psm
	local tmp = files.listdirs("ux0:psm")
	local list_psm = {}
	if tmp and #tmp > 0 then
		table.sort(tmp ,function (a,b) return string.lower(a.name)<string.lower(b.name) end)
		for i=1, #tmp do
			if game.exists(tmp[i].name) then
				os.message(tmp[i].name)
				if not game.rif_psm(tmp[i].name) then
					os.message("RIF2 no existe "..tmp[i].name)
					tmp[i].psm = true
					table.insert(list_psm, tmp[i])
				end
			else
				tmp[i].psm = true
				table.insert(list_psm, tmp[i])
			end
		end
	end

	--Installing
	local count = 0

	--1st APP
	if #list > 0 then
		for i=1, #list do
			
			__TITTLEAPP, __IDAPP = "",""
			if img then img:blit(0,0) end
			__TITTLEAPP, __IDAPP = list[i].title, list[i].id

			buttons.homepopup(0)
				local result = game.refresh(list[i].path)
			buttons.homepopup(1)

			if result == 1 then

				count += 1
				list[i].dev = "ux0"

				--Size
				list[i].size = files.size(list[i].path)
				list[i].sizef = files.sizeformat(list[i].size or 0)
 
				--Update appman[].list
				local icon0 = image.load("ur0:appmeta/"..list[i].id.."/icon0.png")
				if icon0 then
					list[i].img = icon0
					if list[i].resize then
						list[i].img:resize(120,100)
					else
						list[i].img:resize(120,120)
					end
					list[i].img:setfilter(__IMG_FILTER_LINEAR, __IMG_FILTER_LINEAR)
				else
					list[i].img = theme.data["icodef"]
				end
				list[i].path_pic = "ur0:appmeta/"..list[i].id.."/pic0.png"

				local sfo = game.info(list[i].path.."/sce_sys/param.sfo")
				if sfo and sfo.CONTENT_ID then list[i].region = regions[sfo.CONTENT_ID[1]] or 5	end
				list[i].Nregion = name_region[list[i].region] or ""

				--Search game in appman[index].list
				local search = 0
				for j=1,appman[list[i].index].scroll.maxim do
					if list[i].id == appman[list[i].index].list[j].id then search = j break end
				end

				if search == 0 then
					table.insert(appman[list[i].index].list, list[i])
					--table.sort(appman[list[i].index].list ,function (a,b) return string.lower(a.dev)<string.lower(b.dev) end)
					SortGeneric(appman[list[i].index].list,appman[list[i].index].sort,appman[list[i].index].asc)
					appman[list[i].index].scroll:set(appman[list[i].index].list,limit)
				else
					--Update
					appman[list[i].index].list[search].dev = "ux0"
					appman[list[i].index].list[search].img = list[i].img	--Icon New ??...Maybe
					appman[list[i].index].list[search].type = list[i].type
					appman[list[i].index].list[search].version = list[i].version
					appman[list[i].index].list[search].title = list[i].title
					appman[list[i].index].list[search].save = list[i].save
					appman[list[i].index].list[search].sdk = list[i].sdk
				end

				--Restore Save from "ux0:data/ONEMenu/Saves
				if files.exists("ux0:data/ONEMenu/SAVES/"..list[i].save) then
					local info = files.info("ux0:data/ONEMenu/SAVES/"..list[i].save)
					if os.message(STRINGS_APP_RESTORE_SAVE.."\n"..info.mtime or "", 1) == 1 then
						files.copy("ux0:data/ONEMenu/SAVES/"..list[i].save, "ux0:user/00/savedata/")
							game.umount()
								game.mount("ux0:user/00/savedata/"..list[i].save)
								personalize_savedata("ux0:user/00/savedata/"..list[i].save.."/sce_sys/param.sfo")
							game.umount()
						end
				end
				appman.len+=1

			else
				os.message(STRINGS_LIVEAREA_NOTINSTALLED..list[i].id)
			end

		end

	else
		os.message(STRINGS_LIVEAREA_NO_GAMES)
	end

	--1st PSM
	if #list_psm > 0 then
		for i=1, #list_psm do
			
			__TITTLEAPP, __IDAPP = "",""
			if img then img:blit(0,0) end
			__TITTLEAPP, __IDAPP = "PSM GAME", list_psm[i].name

			buttons.homepopup(0)
				local result = game.refresh_psm(list_psm[i].path)
			buttons.homepopup(1)

			os.message(tostring(result))

			if result == 1 then

				local info_psm = game.details(list_psm[i].name)
				os.message(tostring(#info_psm))
				count += 1
				list_psm[i].dev = "ux0"

				--Size
				list_psm[i].size = files.size(list_psm[i].path)
				list_psm[i].sizef = files.sizeformat(list_psm[i].size or 0)
 
				--Update appman[].list_psm
				local icon0 = image.load("ur0:appmeta/"..list_psm[i].id.."/pic0.png")
				if icon0 then
					list_psm[i].img = icon0
					list_psm[i].img:resize(120,100)
					list_psm[i].img:setfilter(__IMG_FILTER_LINEAR, __IMG_FILTER_LINEAR)
				else
					list_psm[i].img = theme.data["icodef"]
				end
				list_psm[i].path_pic = "ur0:appmeta/"..list_psm[i].id.."/pic0.png"

				--list_psm[i].region = 5
				--list_psm[i].Nregion = ""
				list_psm[i].index = 5

				--Search game in appman[index].list_psm
				local search = 0
				for j=1,appman[list_psm[i].index].scroll.maxim do
					if list_psm[i].id == appman[list_psm[i].index].list_psm[j].id then search = j break end
				end

				if search == 0 then
					table.insert(appman[list_psm[i].index].list, list_psm[i])
					SortGeneric(appman[list_psm[i].index].list,appman[list_psm[i].index].sort,appman[list_psm[i].index].asc)
					appman[list_psm[i].index].scroll:set(appman[list_psm[i].index].list,limit)
				else
					--Update
					appman[list_psm[i].index].list[search].dev = "ux0"
					appman[list_psm[i].index].list[search].img = list_psm[i].img	--Icon New ??...Maybe
					if info_psm then
						appman[list_psm[i].index].list[search].type = info_psm[i].type
						appman[list_psm[i].index].list[search].version = info_psm[i].version
						appman[list_psm[i].index].list[search].title = info_psm[i].title
						appman[list_psm[i].index].list[search].sdk = info_psm[i].sdk
					end
				end

				appman.len+=1

			else
				os.message(STRINGS_LIVEAREA_NOTINSTALLED.." PSM "..list_psm[i].id)
			end

		end

	else
		os.message(STRINGS_LIVEAREA_NO_GAMES.." PSM")
	end

	__TITTLEAPP, __IDAPP = "",""

	if count > 0 then os.message(STRINGS_LIVEAREA_GAMES..count) end

	if img then img:blit(0,0) elseif vbuff then vbuff:blit(0,0) end
	message_wait(STRINGS_LIVEAREA_EXTRAREFRESH)
	os.delay(15)

	local installs = game.extrarefresh()
	os.message(STRINGS_LIVEAREA_TOTAL_EXTRA..installs)

	infodevices()
	os.delay(15)
	if vbuff then vbuff:blit(0,0) elseif img then img:blit(0,0) end

end
