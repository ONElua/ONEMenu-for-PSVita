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
		while true do
			buttons.read()
			if buttons[accept] then
				buttons.read() -- Flush
				return 10 -- Ok code
			elseif buttons[cancel] then
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

			if accept_x == 1 then
				screen.print(10,505,string.format("%s "..STRINGS_CONFIRM.." | %s "..STRINGS_SUBMENU_CANCEL,SYMBOL_CROSS, SYMBOL_CIRCLE),1.0,color.white, color.blue)
			else
				screen.print(10,505,string.format("%s "..STRINGS_CONFIRM.." | %s "..STRINGS_SUBMENU_CANCEL,SYMBOL_CIRCLE, SYMBOL_CROSS),1.0,color.white, color.blue)
			end
			screen.flip()
		end
	elseif step == 3 then -- Unpack :P
		if theme.data["back"] then theme.data["back"]:blit(0,0)	end
		draw.fillrect(0,0,960,30, theme.style.CBACKSBARCOLOR)

		screen.print(10,10,STRINGS_UNPACK_VPK)
		screen.print(925,10,STRINGS_CALLBACKS_PERCENT_ALL..math.floor((totalwritten*100)/totalsize).." %",1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ARIGHT)
		screen.print(10,70,STRINGS_CALLBACKS_FILE..tostring(file),1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
		screen.print(10,90,STRINGS_CALLBACKS_PERCENT..math.floor((written*100)/size_argv).." %",1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
		
		draw.fillrect(0,544-30,(totalwritten*960)/totalsize,30, color.new(0,255,0))

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
function onExtractFiles(size,written,file,totalsize,totalwritten)

	if theme.data["list"] then theme.data["list"]:blit(0,0)	end
	draw.fillrect(0,0,__DISPLAYW,30, theme.style.CBACKSBARCOLOR)

	if explorer.dst then
		screen.print(10,10,STRINGS_EXTRACTION+" <- -> "+explorer.dst)
	else
		screen.print(10,10,STRINGS_EXTRACTION)
	end

	screen.print(925,10,STRINGS_CALLBACKS_PERCENT_ALL..math.floor((totalwritten*100)/totalsize).." %",1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ARIGHT)
	screen.print(10,70,STRINGS_CALLBACKS_FILE..tostring(file),1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
	screen.print(10,90,STRINGS_CALLBACKS_PERCENT..math.floor((written*100)/size).." %",1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)

	screen.flip()
	
	buttons.read()
	if buttons[cancel] then return 0 end
	return 1
end

function onScanningFiles(file,unsize,position,unsafe)
	if bufftmp then bufftmp:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
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
	screen.print(10,130,STRINGS_CALLBACKS_PERCENT_ALL..math.floor((written*100)/size).."%")

	draw.fillrect(0,520,((written*960)/size),24,color.new(0,255,0))
	screen.flip()

	buttons.read()
	if buttons[cancel] then return 0 end --Cancel or Abort
	return 1
end

