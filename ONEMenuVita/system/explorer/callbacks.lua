--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

--CallBacks LUA
function onAppInstall(step, size_argv, written, file, totalsize, totalwritten)

    if step == 1 then -- Only msg of state
    	if theme.data["back"] then theme.data["back"]:blit(0,0) end

		draw.fillrect(0,0,960,30, theme.style.CBACKSBARCOLOR)
		screen.print(10,10,STRINGS_INSTALL_SEARCH_UNSAFE)

		screen.flip()
	elseif step == 2 then -- Alerta Vpk requiere confirmacion!
		local Xa = "O: "
		local Oa = "X: "
		if accept_x == 1 then Xa,Oa = "X: ","O: " end
		while true do
			buttons.read()
			if buttons.accept then
				buttons.read() -- Flush
				return 10 -- Ok code
			elseif buttons.cancel then
				buttons.read() -- Flush
				return 0 -- Any other code 
			end

			if theme.data["back"] then theme.data["back"]:blit(0,0)	end
			draw.fillrect(0,0,960,30, theme.style.CBACKSBARCOLOR)

			if size_argv == 1 then
				screen.print(10,10,STRINGS_WARNING_UNSAFE)
			elseif size_argv == 2 then
				screen.print(10,10,STRINGS_WARNING_DANGEROUS)
			end

			screen.print(10,505,Xa..STRINGS_CONFIRM.." | "..Oa..STRINGS_SUBMENU_CANCEL,1.0,color.white, color.blue)
			screen.flip()
		end
	elseif step == 3 then -- Unpack :P
		if theme.data["back"] then theme.data["back"]:blit(0,0)	end
		draw.fillrect(0,0,960,30, theme.style.CBACKSBARCOLOR)

		screen.print(10,10,STRINGS_UNPACK_VPK)

		l = (written*940)/size_argv
			screen.print(3+l,495,math.floor((written*100)/size_argv).."%",0.8,0xFFFFFFFF,0x0,__ACENTER)
				draw.fillrect(10,524,l,6,color.new(0,255,0))
					draw.circle(10+l,526,6,color.new(0,255,0),30)
		
		
		screen.print(925,10,STRINGS_CALLBACKS_PERCENT_ALL..math.floor((totalwritten*100)/totalsize).." %",1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ARIGHT)
		--screen.print(10,70,STRINGS_CALLBACKS_FILE..tostring(file),1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
		--screen.print(10,90,STRINGS_CALLBACKS_PERCENT..math.floor((written*100)/size_argv).." %",1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)

		--draw.fillrect(0,544-30,(totalwritten*960)/totalsize,30, color.new(0,255,0))

		screen.flip()
	elseif step == 4 then -- Promote o install :P
		if theme.data["back"] then theme.data["back"]:blit(0,0)	end
		draw.fillrect(0,0,960,30, theme.style.CBACKSBARCOLOR)

		screen.print(10,10,STRINGS_INSTALLING)
		screen.print(10,55,__TITTLEAPP, 1.0, theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ALEFT)
		screen.print(10,80,__IDAPP, 1.0, theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ALEFT)
		screen.flip()
	end
end

-- CallBack Extraction
function onExtract7zFiles(filename,size,num,numfiles)
	if theme.data["list"] then theme.data["list"]:blit(0,0)	end
--	if bufftmp then bufftmp:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
	draw.fillrect(0,0,__DISPLAYW,30, theme.style.CBACKSBARCOLOR)

	if explorer.dst then
		screen.print(10,10,STRINGS_EXTRACTION.." <- -> "..explorer.dst)
	else
		screen.print(10,10,STRINGS_EXTRACTION)
	end

	screen.print(950,10,num.." / "..numfiles,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ARIGHT)
	screen.print(10,70,STRINGS_CALLBACKS_FILE..tostring(filename),1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
	screen.print(10,95,STRINGS_CALLBACKS_SIZE..tostring(files.sizeformat(size) or 0),1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)

	l = (num*940)/numfiles
		screen.print(3+l,495,math.floor((num*100)/numfiles).."%",0.8,0xFFFFFFFF,0x0,__ACENTER)
			draw.fillrect(10,524,l,6,color.new(0,255,0))
				draw.circle(10+l,526,6,color.new(0,255,0),30)

	screen.flip()
	
	buttons.read()
	--if buttons.cancel then return 0 end
	return 1
end

function onExtractFiles(size,written,file,totalsize,totalwritten)
	if theme.data["list"] then theme.data["list"]:blit(0,0)	end
--	if bufftmp then bufftmp:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
	draw.fillrect(0,0,__DISPLAYW,30, theme.style.CBACKSBARCOLOR)

	if explorer.dst then
		screen.print(10,10,STRINGS_EXTRACTION.." <- -> "..explorer.dst)
	else
		screen.print(10,10,STRINGS_EXTRACTION)
	end

	l = (written*940)/size
		screen.print(3+l,495,math.floor((written*100)/size).."%",0.8,0xFFFFFFFF,0x0,__ACENTER)
			draw.fillrect(10,524,l,6,color.new(0,255,0))
				draw.circle(10+l,526,6,color.new(0,255,0),30)

	screen.print(925,10,STRINGS_CALLBACKS_PERCENT_ALL..math.floor((totalwritten*100)/totalsize).." %",1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ARIGHT)
	screen.print(10,70,STRINGS_CALLBACKS_FILE..tostring(file),1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
	--screen.print(10,90,STRINGS_CALLBACKS_PERCENT..math.floor((written*100)/size).." %",1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)

--[[
	local Xa = "O: "
	local Oa = "X: "
	if accept_x == 1 then Xa,Oa = "X: ","O: " end
	screen.print(925,35,Oa..STRINGS_SUBMENU_CANCEL,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ARIGHT)--515
]]
	screen.flip()
	
	buttons.read()
	--if buttons.cancel then return 0 end
	return 1
end

function onCompressZip(size,written,file)

	if theme.data["list"] then theme.data["list"]:blit(0,0)	end
	draw.fillrect(0,0,__DISPLAYW,30, theme.style.CBACKSBARCOLOR)

	l = (written*940)/size
		screen.print(3+l,495,math.floor((written*100)/size).."%",0.8,0xFFFFFFFF,0x0,__ACENTER)
			draw.fillrect(10,524,l,6,color.new(0,255,0))
				draw.circle(10+l,526,6,color.new(0,255,0),30)

	screen.print(10,10,STRINGS_COMPRESS)
	screen.print(10,70,STRINGS_CALLBACKS_FILE..tostring(file),1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
	--screen.print(10,90,STRINGS_CALLBACKS_PERCENT..math.floor((written*100)/size).." %",1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)

	local Xa = "O: "
	local Oa = "X: "
	if accept_x == 1 then Xa,Oa = "X: ","O: " end
	screen.print(925,10,Oa..STRINGS_SUBMENU_CANCEL,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ARIGHT)--515

	screen.flip()
	
	buttons.read()
	if buttons.cancel then return 0 end
	return 1
end

function onScanningFiles(file,unsize,position,unsafe)
	if theme.data["list"] then theme.data["list"]:blit(0,0)	end
--	if bufftmp then bufftmp:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
	draw.fillrect(0,0,__DISPLAYW,30, theme.style.CBACKSBARCOLOR)

	local ccc=color.white
	if unsafe==1 then ccc=color.yellow elseif unsafe==2 then ccc=color.red end

	local x,y = (960-420)/2,(544-420)/2

	screen.print(__DISPLAYW/2,y+7,STRINGS_CALLBACKS_FILE..tostring(file),1,ccc,color.black,__ACENTER)
	screen.print(__DISPLAYW/2,y+37,STRINGS_CALLBACKS_UNSAFE..tostring(unsafe),1,ccc,color.black,__ACENTER)

	draw.fillrect(x,y,420,420,theme.style.CBACKSBARCOLOR)
	draw.rect(x,y,420,420,color.black)

	if not angle then angle = 0 end
	angle += 24
	if angle > 360 then angle = 0 end
	draw.framearc(__DISPLAYW/2, __DISPLAYH/2, 40, color.new(255,255,255), 0, 360, 20, 30)
	draw.framearc(__DISPLAYW/2, __DISPLAYH/2, 40, color.new(0,255,0), angle, 90, 20, 30)

	screen.print(__DISPLAYW/2,(__DISPLAYH/2)+45,STRINGS_SCANNING,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)

	screen.flip()
end

-- CallBack CopyFiles
fileant = ""
total_size,files_move, cont = 0,0,0

function onCopyFiles(size,written,file)
	power.tick(__POWER_TICK_ALL)
	if _print then

		if theme.data["list"] then theme.data["list"]:blit(0,0)	end
		draw.fillrect(0,0,__DISPLAYW,30, theme.style.CBACKSBARCOLOR)

		if explorer.dst then
			screen.print(10,10,STRINGS_COPYFILE.." <- -> "+explorer.dst)
		else
			screen.print(10,10,STRINGS_COPYFILE)
		end

		screen.print(945,10,math.floor((written*100)/size).." %",1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ARIGHT)
		screen.print(10,70,STRINGS_CALLBACKS_FILE..tostring(file),1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)

		if game_move then
			if file != fileant then	cont+=1 end

			if cont <= files_move or cont == files_move+1 then
				if cont == files_move+1 then cont = files_move end
				screen.print(480,415,STRINGS_CALLBACKS_MOVE_FILES.." ( "..(cont).." / "..files_move.." )",1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ACENTER)
				draw.rect(0, 440, 960, 24, theme.style.CBACKSBARCOLOR)
				draw.fillrect(0,440, (cont*960)/files_move,24, theme.style.CBACKSBARCOLOR)
			else
				screen.print(480,415,STRINGS_CALLBACKS_UPDATE_DB,1,color.white,color.blue, __ACENTER)
			end

			fileant = file
		end

		screen.flip()
	end
end

-- CallBack DeleteFiles
function onDeleteFiles(file)
	power.tick(__POWER_TICK_ALL)
	if not game_move then
		if theme.data["list"] then theme.data["list"]:blit(0,0) end
		draw.fillrect(0,0,__DISPLAYW,30, theme.style.CBACKSBARCOLOR)

		screen.print(10,10,STRINGS_DELFILE,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
		screen.print(10,70,STRINGS_CALLBACKS_FILE..tostring(file),1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)

		screen.flip()
	end
end

function onNetGetFile(size,written,speed)
	if theme.data["list"] then theme.data["list"]:blit(0,0) end
	draw.fillrect(0,0,960,30, theme.style.CBACKSBARCOLOR)

	screen.print(10,10,STRINGS_DOWNLOAD)
	screen.print(10,80,STRINGS_CALLBACKS_FILE.." "..__NAME_DOWNLOAD)
	screen.print(10,105,STRINGS_CALLBACKS_SIZE_ALL..tostring(files.sizeformat(size) or 0))
	--screen.print(10,130,STRINGS_CALLBACKS_PERCENT_ALL..math.floor((written*100)/size).."%")

	l = (written*940)/size
		screen.print(3+l,495,math.floor((written*100)/size).."%",0.8,0xFFFFFFFF,0x0,__ACENTER)
			draw.fillrect(10,524,l,6,color.new(0,255,0))
				draw.circle(10+l,526,6,color.new(0,255,0),30)

	--draw.fillrect(0,520,((written*960)/size),24,color.new(0,255,0))
	screen.flip()

	local Oa = "X: "
	if accept_x == 1 then Oa = "O: " end
	screen.print(925,10,Oa..STRINGS_SUBMENU_CANCEL,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ARIGHT)--515

	buttons.read()
	if buttons.cancel then return 0 end --Cancel or Abort
	return 1
end

musicfile = ""
function onMusicExportFile(progress)
	if theme.data["list"] then theme.data["list"]:blit(0,0) end
	draw.fillrect(0,0,960,30, theme.style.CBACKSBARCOLOR)

	screen.print(10,10,"PROGRESS: "..tostring(progress or 0).." %")
	screen.print(10,80,musicfile)
	screen.flip()

	--buttons.read()
	--if buttons.cancel then return 0 end --Cancel or Abort
	return 1
end

function onPbpUnpack(size,written,file)
	if theme.data["list"] then theme.data["list"]:blit(0,0) end
	draw.fillrect(0,0,960,35, theme.style.CBACKSBARCOLOR)

	screen.print(10,10,STRINGS_CALLBACKS_FILE.." "..file)

	l = (written*940)/size
		screen.print(3+l,495,math.floor((written*100)/size).."%",0.8,0xFFFFFFFF,0x0,__ACENTER)
			draw.fillrect(10,524,l,6,color.new(0,255,0))
				draw.circle(10+l,526,6,color.new(0,255,0),30)

	os.delay(750)
	screen.flip()

end
