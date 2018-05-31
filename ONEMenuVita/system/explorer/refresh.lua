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
			if files.exists(obj.path.."/data/boot.inf") or obj.id == "PSPEMUCFW" then index = 5
			else
				if info.CONTENT_ID and info.CONTENT_ID:len() > 9 then index = 1 else index = 2 end
			end

			table.insert(list, { id=info.TITLE_ID, type=info.CATEGORY, version=info.APP_VER or "00.00", title=info.TITLE or info.TITLE_ID,
								 path=obj.path, index = index, resize = resize })
		end
	end

end

function refresh_init(img)

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
				if not game.rif(tmp[i].name) and not game.frif(tmp[i].name) then
					fillapps(list, tmp[i])
				end
			else
				fillapps(list, tmp[i])
			end
		end
	end

	--Installing
	if #list > 0 then
		local count = 0
		for i=1, #list do

			if img then img:blit(0,0)	end
			__TITTLEAPP, __IDAPP = list[i].title, list[i].id

			buttons.homepopup(0)
				local result = game.refresh(list[i].path)
			buttons.homepopup(1)

			if result == 1 then

				count += 1
				list[i].dev = "ux0:"

				--Size
				list[i].size = files.size(list[i].path)
				list[i].sizef = files.sizeformat(list[i].size or 0)
 
				--Update appman[].list
				local icon0 = image.load("ur0:appmeta/"..list[i].id.."/icon0.png")
				if icon0 then
					list[i].img = icon0
					if __FAV == 1 then
						list[i].img:resize(120,120)
					else
						if list[i].resize then
							list[i].img:resize(120,100)
						else
							list[i].img:resize(120,120)
						end
					end
					list[i].img:setfilter(__IMG_FILTER_LINEAR, __IMG_FILTER_LINEAR)
				else
					list[i].img = theme.data["icodef"]
				end

				local sfo = game.info(list[i].path.."/sce_sys/param.sfo")
				if sfo and sfo.CONTENT_ID then list[i].region = regions[sfo.CONTENT_ID[1]] or 5	end
				list[i].Nregion = name_region[list[i].region] or ""

				--Search game in appman[index].list
				local search = 0
				for j=1,appman[list[i].index].scroll.maxim do
					if list[i].id == appman[list[i].index].list[j].id then search = j break end
				end

				if search == 0 then
					if __FAV == 0 then
						list[i].fav = false
						table.insert(appman[list[i].index].list, list[i])

						if list[i].index == 1 and appman[list[i].index].sort == 3 then
							table.sort(appman[list[i].index].list, tableSortReg)
						else
							if appman[list[i].index].sort == 0 then
								if appman[list[i].index].asc == 1 then
									table.sort(appman[list[i].index].list ,function (a,b) return string.lower(a.id)<string.lower(b.id) end)
								else
									table.sort(appman[list[i].index].list ,function (a,b) return string.lower(a.id)>string.lower(b.id) end)
								end
							else
								if appman[list[i].index].asc == 1 then
									table.sort(appman[list[i].index].list ,function (a,b) return string.lower(a.title)<string.lower(b.title) end)
								else
									table.sort(appman[list[i].index].list ,function (a,b) return string.lower(a.title)>string.lower(b.title) end)
								end
							end
						end

						appman[list[i].index].scroll:set(appman[list[i].index].list,limit)
					end
				else
					--update
					appman[list[i].index].list[search].dev = "ux0:"
					appman[list[i].index].list[search].img = list[i].img

					appman[list[i].index].list[search].type = list[i].type
					appman[list[i].index].list[search].version = list[i].version
					appman[list[i].index].list[search].title = list[i].title

				end

				appman.len +=1
				infodevices()

			else
				os.message(strings.notinstalled..list[i].id)
			end
		end
		os.message(strings.gamesinst..count)

	else
		os.message(strings.nogames)
	end

	os.delay(15)
	if vbuff then vbuff:blit(0,0) elseif img then img:blit(0,0) end
	__TITTLEAPP, __IDAPP = "",""

end
