--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

-- ## Explorer ## --
icons_mimes={1,pbp=2,prx=2,bin=2,suprx=2,skprx=2,dat=2,db=2,a=2,prs=2,pmf=2,at9=2,dds=2,tmp=2,html=2,gft=2,sfm=2,icv=2,cer=2,dic=2,pgf=2,
rsc=2,rco=2,res=2,dreg=2,ireg=2,pdb=2,mai=2,bin_bak=2,psp2dmp=2,rif=2,trp=2,self=2,mp4=2,edat=2,log=2,ptf=2,ctf=2,inf=2,
png=3,gif=3,jpg=3,bmp=3,
mp3=4,s3m=4,wav=4,at3=4,ogg=4,
rar=5,zip=5,vpk=5,gz=5,
cso=6,iso=6,dax=6
}

isopened = { png = theme.style.IMAGECOLOR, jpg = theme.style.IMAGECOLOR, gif = theme.style.IMAGECOLOR, bmp = theme.style.IMAGECOLOR,
	mp3 = theme.style.MUSICCOLOR, ogg = theme.style.MUSICCOLOR, wav = theme.style.MUSICCOLOR,
	iso = theme.style.BINCOLOR, pbp = theme.style.BINCOLOR, cso = theme.style.BINCOLOR, dax = theme.style.BINCOLOR, bin = theme.style.BINCOLOR, suprx = theme.style.BINCOLOR, skprx = theme.style.BINCOLOR,
	zip = theme.style.ARCHIVECOLOR, rar = theme.style.ARCHIVECOLOR, vpk = theme.style.ARCHIVECOLOR, gz = theme.style.ARCHIVECOLOR,
	sfo = theme.style.SFOCOLOR,
}

-- Create two scrolls :P
scroll = {
   list = newScroll(),
   menu = newScroll(),
}

xtitle,movx = 35,0
title_scr_x = 5
maxim_files=16
backl, explorer, multi = {},{},{} -- All explorer functions
slidex=0

infosize = os.devinfo(Root[Dev])
if not infosize then
	infosize = {}
	infosize.max, infosize.free, infosize.used = 0,0,0
end

-- ## Explorer Drawer List ## --
function explorer.listshow(posy)

	if movx==0 then
		if scroll.list.maxim >= maxim_files then len_selector = __DISPLAYW-40 else len_selector = __DISPLAYW-10 end
	else
		len_selector = __DISPLAYW-173
	end

	if menu_ctx.close and slidex > 0 then slidex -= 10 end
	if not menu_ctx.close and slidex < 130 then slidex += 10 end

	for i=scroll.list.ini, scroll.list.lim do

		if i==scroll.list.sel then
			ccc = color.green:a(130)
			draw.fillrect(5+movx, posy-3, len_selector, 23, theme.style.SELCOLOR)
			if screen.textwidth(explorer.list[i].name or "",1) > 490 then 
				xtitle = screen.print(xtitle+movx, posy, explorer.list[i].name,1, isopened[explorer.list[i].ext] or theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __SLEFT, 490)
				xtitle -= movx
			else
				screen.clip(35+movx,0,490+movx,544)
				screen.print(35+movx, posy, explorer.list[i].name,1, isopened[explorer.list[i].ext] or theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ALEFT)
				xtitle=35
			end
		else
			ccc = theme.style.TXTBKGCOLOR
			screen.clip(35+movx,0,490+movx,544)
			screen.print(35+movx, posy, explorer.list[i].name,1, isopened[explorer.list[i].ext] or theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ALEFT)
		end
		screen.clip()

		if explorer.list[i].size then
			if icons_mimes[explorer.list[i].ext] then theme.data["icons"]:blitsprite(10+movx, posy, icons_mimes[explorer.list[i].ext]) -- mime type
			else theme.data["icons"]:blitsprite(10+movx, posy, 0) end -- file unk
		else
			theme.data["icons"]:blitsprite(10+movx, posy, 1) -- folder 
		end

		if explorer.list[i].multi then draw.fillrect(5+movx, posy-3, len_selector, 22, theme.style.MARKEDCOLOR) end

		screen.print(((905-250)+movx)+slidex, posy, explorer.list[i].size or strings.dir, 1, theme.style.TXTCOLOR,ccc, __ARIGHT)
		screen.print((910+movx)+slidex, posy, explorer.list[i].mtime, 1.0, theme.style.TXTCOLOR,ccc, __ARIGHT)
		posy += 26

	end--for

end

--Cycle Main for Explorer Files: show_explorer_list()
local xtmp = 0
function show_explorer_list()

	explorer.refresh(true)
	buttons.interval(16,5)
	while true do

		buttons.read()
		if theme.data["list"] then theme.data["list"]:blit(0,0) end

		movx = menu_ctx.x+menu_ctx.w

		if screen.textwidth(Root[Dev] or "",1) > 860 then 
			title_scr_x = screen.print(title_scr_x+movx,5,Root[Dev],1,theme.style.PATHCOLOR,color.black,__SLEFT,860)
			title_scr_x -= movx
		else
			screen.print(5+movx,5,Root[Dev],1,theme.style.PATHCOLOR,color.black,__ALEFT)
			title_scr_x = 5
		end

		if infosize.max > 0 then
			xtmp = screen.print(5+movx,33,files.sizeformat(infosize.max or 0).."/"..files.sizeformat(infosize.free or 0),1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
		else
			xtmp = screen.print(5+movx,33,"--/--",1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
		end

		if menu_ctx.close then
			local xRoot = xtmp + 15
			local w = (960-xRoot)/#Root2
			for i=1, #Root2 do
				if Dev == i then
					draw.fillrect(xRoot,28,w,28, color.shine)
				end
				screen.print(xRoot+(w/2), 33, Root2[i], 1, color.white, 0x0, __ACENTER)
				xRoot += w
			end
		end

		screen.print(940+movx,5,scroll.list.maxim,1,theme.style.COUNTCOLOR,theme.style.TXTBKGCOLOR,__ARIGHT)

		if (multi and #multi > 0) and action then
			if movx==0 then
				screen.print(940-movx,515,strings.items+#multi,1,color.new(255,69,0),color.black,__ARIGHT)
			else
				screen.print((940-movx)+160,515,strings.items+#multi,1,color.new(255,69,0),color.black,__ARIGHT)
			end
		end

		local y,h=70, (maxim_files*26)-2
		if scroll.list.maxim > 0 then
			if scroll.list.maxim >= maxim_files then -- Draw Scroll Bar
				local pos_height = math.max(h/scroll.list.maxim, maxim_files)
				--Bar Scroll
				draw.fillrect(930+movx, y-2, 8, h, color.shine)
				draw.fillrect(930+movx, y-2 + ((h-pos_height)/(scroll.list.maxim-1))*(scroll.list.sel-1), 8, pos_height, color.new(0,255,0))
			end
			explorer.listshow(y)
		else
			screen.print(10+movx,80,"...".."\n\n"..strings.back,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
		end

		screen.print(10+movx,515,os.date(_time.."  %m/%d/%y"),1,theme.style.DATETIMECOLOR,color.gray,__ALEFT)

		menu_ctx.run()

		screen.flip()

		ctrls_explorer_list()
	end

end

function explorer.refresh(onflag)
	if onflag then infosize = os.devinfo(Root2[Dev]) end
	if not infosize then
		infosize = {}
		infosize.max, infosize.free, infosize.used = 0,0,0
	end
	explorer.list = files.listsort(Root[Dev])
	scroll.list:set(explorer.list,maxim_files)
end

function ctrls_explorer_list()

	if menu_ctx.open then return end
	if not menu_ctx.close then return end

	if buttons[cancel] then -- return directory
		if check_root() then return end

		Root[Dev]=files.nofile(Root[Dev])
		explorer.refresh(false)

		if #backl>0 then
			if scroll.list.maxim == backl[#backl].maxim then
				scroll.list.ini = backl[#backl].ini
				scroll.list.lim = backl[#backl].lim
				scroll.list.sel = backl[#backl].sel
			end
			backl[#backl] = nil
		end
	end

	if scroll.list.maxim > 0 then -- Is exists any?
		if buttons.up or buttons.analogly < -60 then scroll.list:up() end
		if buttons.down or buttons.analogly > 60 then scroll.list:down() end

		if buttons[accept] then
			if explorer.list[scroll.list.sel].size then
				handle_files(explorer.list[scroll.list.sel])
			else
				table.insert(backl, {maxim = scroll.list.maxim, ini = scroll.list.ini, sel = scroll.list.sel, lim = scroll.list.lim, })
				Root[Dev]=explorer.list[scroll.list.sel].path
				explorer.refresh(false)
			end
		end
	end

	if buttons.released.r or buttons.released.l then
		if menu_ctx.open then return end                 -- Switch device
		if buttons.released.l then Dev -= 1 else Dev += 1 end

		if Dev > #Root then Dev = 1 end
		if Dev < 1 then Dev = #Root end
		os.delay(10)
		explorer.refresh(true)
	end

	if buttons.square then
		explorer.list[scroll.list.sel].multi = not explorer.list[scroll.list.sel].multi
		if explorer.list[scroll.list.sel].multi then
			table.insert(multi, explorer.list[scroll.list.sel].path)
			explorer.list[scroll.list.sel].index = #multi
		else
			table.remove(multi, explorer.list[scroll.list.sel].index)
		end
	end

	if buttons.select and menu_ctx.open==false then
		restart_cronopic()
		appman.launch()
	end

	shortcuts()

end

function handle_files(cnt)
	local extension = cnt.ext

	if extension == "png" or extension == "jpg" or extension == "bmp" or extension == "gif" then
		visorimg(cnt.path)
	elseif extension == "vpk" then
		buttons.homepopup(0)
			show_msg_vpk(cnt)
			if vpkdel then explorer.refresh(true) end
		buttons.homepopup(1)
	elseif extension == "zip" or extension == "rar" or extension == "7z" or extension == "gz" then
		show_scan(cnt)
	elseif extension == "pbp" or extension == "iso" or extension == "cso" then
		show_msg_pbp(cnt)
	elseif extension == "mp3" or extension == "wav" or extension == "ogg" then
		MusicPlayer(cnt)
	elseif extension == "txt" or extension == "lua" or extension == "ini" or extension == "sfo" or extension == "xml" or extension == "inf" then
		visortxt(cnt,true)
	end

end

__ACTION_WAIT_NOTHING = 0
__ACTION_WAIT_PASTE = 1
__ACTION_WAIT_EXTRACT = 2
 
local src_path_callback = function ()
   if #explorer.list > 0 then
      local ext = explorer.list[scroll.list.sel].ext or ""
      if menu_ctx.scroll.sel != 3 or (menu_ctx.scroll.sel == 3 and (ext:lower()=="zip" or ext:lower()=="rar" or ext:lower()=="vpk")) then
         if not multi or #multi < 1 then
            table.insert(multi, explorer.list[scroll.list.sel].path)
         end
         explorer.action = menu_ctx.scroll.sel
 
         if menu_ctx.scroll.sel != 3 then menu_ctx.wait_action = __ACTION_WAIT_PASTE else menu_ctx.wait_action = __ACTION_WAIT_EXTRACT end
         menu_ctx.wakefunct()
    	 menu_ctx.close = true
         action = true
      end
   end
end

local paste_callback = function ()
    explorer.dst = Root[Dev]
 
    if explorer.action == 1 then                        --Paste from Copy
        if #multi>0 then
            buttons.homepopup(0)
            reboot=false
            for i=1,#multi do
                files.copy(multi[i],explorer.dst)
            end
            buttons.homepopup(1)
            reboot=true
        end
 
    elseif explorer.action == 2 then                     --Paste from Move
        if #multi>0 then
            reboot=false
            local _dst = explorer.dst:sub(1,3)
            for i=1,#multi do
                if multi[i]:sub(1,3) == _dst then
                    files.move(multi[i],explorer.dst)
                else
                    buttons.homepopup(0)
                    if files.copy(multi[i],explorer.dst)==1 then files.delete(multi[i]) end
                    buttons.homepopup(1)
                end
            end
            reboot=true
        end
 
    elseif explorer.action == 3 then                     --Extract
        if #multi>0 then
            reboot=false
            for i=1,#multi do
                if os.message(multi[i]+"\n\n"+strings.pass,1)==1 then
                    local pass = osk.init(strings.ospass, "" , 50)
                    if pass then
                        buttons.homepopup(0)
                            files.extract(multi[i],explorer.dst,pass)
                        buttons.homepopup(1)
                    end
                else
                    buttons.homepopup(0)
                        files.extract(multi[i],explorer.dst)
                    buttons.homepopup(1)
                end
            end
            reboot=true
        end
    end
 
--clean
    menu_ctx.wakefunct()
    menu_ctx.close = true
    action = false
    explorer.refresh(true)
    explorer.action = 0
	menu_ctx.wait_action = __ACTION_WAIT_NOTHING
    explorer.dst = ""
    multi={}
end
 
local delete_callback = function () -- TODO: add move to -1 pos of the deleted element in list
    if #explorer.list > 0 then
        if explorer.list[scroll.list.sel].multi then
            if #multi>0 then
                if os.message(strings.delete.." "..#multi.."\n\n"..strings.filesfolders.."(s) ?",1) == 1 then
                    reboot=false
                        for i=1,#multi do files.delete(multi[i]) end
                    reboot=true
                end
            end
        else
            if os.message(strings.delete.." "..explorer.list[scroll.list.sel].name.." ?",1) == 1 then
                reboot=false
                    files.delete(explorer.list[scroll.list.sel].path)
                reboot=true
            end
        end
--clean
        menu_ctx.wakefunct()
        menu_ctx.close = true
        action = false
        explorer.refresh(true)
        explorer.action = 0
        multi={}
        os.delay(150)
    end
end
 
local makedir_callback = function () -- Added suport multi-new-folder
    local i=1
    while files.exists(Root[Dev].."/"..string.format("%s%03d",strings.newfolder,i)) do
        i+=1
    end
    local name_folder = osk.init(strings.creatfolder, string.format("%s%03d",strings.newfolder,i))
    if name_folder then
        local dest = Root[Dev].."/"..name_folder
        if Root[Dev]:sub(#Root[Dev]) == "/" then dest = Root[Dev]..name_folder end
        files.mkdir(dest)
--clean
        menu_ctx.wakefunct()
        menu_ctx.close = true
        action = false
        explorer.refresh(true)
        explorer.action = 0
        multi={}
    end
end
 
local rename_callback = function ()
    if #explorer.list > 0 then
        local new_name = osk.init(strings.rename,files.nopath(explorer.list[scroll.list.sel].path))
        if new_name then
            local fullpath = files.nofile(explorer.list[scroll.list.sel].path)
            files.rename(explorer.list[scroll.list.sel].path, new_name)
            explorer.list[scroll.list.sel].path = fullpath+new_name
            explorer.list[scroll.list.sel].name = new_name
            explorer.list[scroll.list.sel].ext = files.ext(new_name)
--clean
            menu_ctx.wakefunct()
            menu_ctx.close = true
            action = false
            explorer.action = 0
			multi={}
			explorer.list = files.listsort(Root[Dev])
        end
    end
end
 
local installgame_callback = function ()
    if #explorer.list > 0 then
        if explorer.list[scroll.list.sel].ext == "vpk" then
            buttons.homepopup(0)
                show_msg_vpk(explorer.list[scroll.list.sel])
            buttons.homepopup(1)
            return
        end
 
        if not files.exists(string.format("%s/eboot.bin",explorer.list[scroll.list.sel].path)) and
            not files.exists(string.format("%s/sce_sys/param.sfo",explorer.list[scroll.list.sel].path)) then return end
 
        local bufftmp = screen.buffertoimage()
        local x,y = (960-420)/2,(544-420)/2
        local resp=0

		local tmp_vpk  = {}

        local info = game.info(string.format("%s/sce_sys/param.sfo",explorer.list[scroll.list.sel].path))
        tmp_vpk.img = image.load(string.format("%s/sce_sys/icon0.png",explorer.list[scroll.list.sel].path))
 
        local res,xscr = false,290
        local Xa = "O: "
        local Oa = "X: "
        if accept_x == 1 then Xa,Oa = "X: ","O: " end
        while true do
            buttons.read()
            bufftmp:blit(0,0)
 
            draw.fillrect(x,y,420,420, theme.style.SELCOLOR)
            draw.framerect(x,y,420,420,color.black, color.shine,6)
   
            if info then
                if screen.textwidth(tostring(info.TITLE) or "UNK") > 380 then
                    xscr = screen.print(xscr, y+12, tostring(info.TITLE) or "UNK",1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__SLEFT,380)
                else
                    screen.print(960/2,y+12,tostring(info.TITLE),1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
                end
                if info.CATEGORY == "gp" then
                    screen.print(960/2,y+35,"UPDATE: "..tostring(info.APP_VER) or "",1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
                else
                    screen.print(960/2,y+35,tostring(info.APP_VER) or "",1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
                end
                screen.print(960/2,y+55,tostring(info.TITLE_ID),1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
            end
			if tmp_vpk.img then
				tmp_vpk.img:scale(150)
				tmp_vpk.img:setfilter(__IMG_FILTER_LINEAR, __IMG_FILTER_LINEAR)
				tmp_vpk.img:center()
				tmp_vpk.img:blit(960/2,544/2)
            end
 
            screen.print(960/2,y+325,strings.installvpk +" ?",1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
            screen.print(960/2,y+395,Xa..strings.confirm.." | "..Oa..strings.cancel,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
            screen.flip()
 
            if buttons[accept] or buttons[cancel] then
                if buttons[accept] then res = true end
                break
            end
        end
 
        if res == false then return end
 
        buttons.homepopup(0)
        reboot=false
            local result = game.installdir(explorer.list[scroll.list.sel].path)
        buttons.homepopup(1)
        reboot=true
 
		bufftmp = nil
		if result ==1 then
			if os.message(strings.launchpbp+"\n\n"+info.TITLE_ID+" ?",1) == 1 then
				if game.exists(info.TITLE_ID) then
					if info.CATEGORY == "ME" then game.open(info.TITLE_ID)
					else game.launch(info.TITLE_ID) end
				end
			end

			tmp_vpk.path = string.format("ux0:app/%s",info.TITLE_ID)
			tmp_vpk.dev = "ux0"

			--Size
			tmp_vpk.size = files.size(tmp_vpk.path)
			tmp_vpk.sizef = files.sizeformat(tmp_vpk.size or 0)
 
			tmp_vpk.clon = false
			tmp_vpk.basegame = false
 
			if not tmp_vpk.img then tmp_vpk.img = theme.data["icodef"] end
			if tmp_vpk.img then
				tmp_vpk.img:reset()
				tmp_vpk.img:resize(120,120)
				tmp_vpk.img:setfilter(__IMG_FILTER_LINEAR, __IMG_FILTER_LINEAR)
			end

			--id, type, version, dev, path, title
			tmp_vpk.id = info.TITLE_ID
			tmp_vpk.type = info.CATEGORY
			tmp_vpk.version = info.APP_VER or "00.00"
			tmp_vpk.title = info.TITLE or info.TITLE_ID

			--Update appman[x].list
			local index = 1
			if files.exists(tmp_vpk.path.."/data/boot.inf") or tmp_vpk.id == "PSPEMUCFW" then index = 5 else
				if info.CONTENT_ID:len() > 9 then index = 1	else index = 2 end
			end

			--Search game in appman[index].list
			local search = 0
			for i=1,appman[index].scroll.maxim do
				if tmp_vpk.id == appman[index].list[i].id then search = i break end
			end

			if search == 0 then
				if __FAV == 0 then
					tmp_vpk.fav = false
					table.insert(appman[index].list, tmp_vpk)
					table.sort(appman[index].list ,function (a,b) return string.lower(a.id)<string.lower(b.id) end)
					appman[index].scroll:set(appman[index].list,limit)
					--plugman.load()
				end
			else
				--update
				appman[index].list[search].dev = "ux0"
				appman[index].list[search].img = tmp_vpk.img

				--size
				appman[index].list[search].size = tmp_vpk.size
				appman[index].list[search].sizef = tmp_vpk.sizef

				appman[index].list[search].type = tmp_vpk.type
				appman[index].list[search].version = tmp_vpk.version
				appman[index].list[search].title = tmp_vpk.title

			end

			appman.len +=1
			infodevices()

		else
			os.message(strings.errorinstall)
		end

--clean
        menu_ctx.wakefunct()
        menu_ctx.close = true
        action = false
        explorer.refresh(true)
        explorer.action = 0
        multi={}
    end
end
 
local installtheme_callback = function ()
    if #explorer.list > 0 then
 
        if not files.exists(string.format("%s/theme.xml",explorer.list[scroll.list.sel].path)) then return end
       
        local path_tmp = explorer.list[scroll.list.sel].path
 
        if Root2[Dev] != "ux0:" then --return end
            if files.copy(explorer.list[scroll.list.sel].path,"ux0:data/customtheme")==1 then files.delete(explorer.list[scroll.list.sel].path) end
            path_tmp = "ux0:data/customtheme/"..explorer.list[scroll.list.sel].name
        end
 
        buttons.homepopup(0)
            reboot=false
                local result = themes.install(path_tmp)
            buttons.homepopup(1)
        reboot=true
 
        os.message(strings.instheme..strings.result..result)
        if result == 1 then
            if os.message(strings.settinsthemes,1)==1 then
                os.delay(150)
                os.uri("settings_dlg:custom_themes")
            end
        end
 
--clean
        menu_ctx.wakefunct()
        menu_ctx.close = true
        action = false
        explorer.refresh(true)
        explorer.action = 0
        multi={}
    end
end
 
local sizedir_callback = function ()
	if #explorer.list > 0 then
		if explorer.list[scroll.list.sel].multi then
			if #multi>0 then
				local sizedir=0
				message_wait()
				for i=1,#multi do
					sizedir += files.size(multi[i])
				end--for
				os.message(strings.total_size+"\n\n"+strings.sizeis+files.sizeformat(sizedir or 0))
			end
		else
			if not explorer.list[scroll.list.sel].size then                -- Its Dir
				message_wait()
				os.message(explorer.list[scroll.list.sel].name+"\n\n"+strings.sizeis+files.sizeformat(files.size(explorer.list[scroll.list.sel].path) or 0))
			else
				os.message(explorer.list[scroll.list.sel].name+"\n\n"+strings.sizeis+explorer.list[scroll.list.sel].size)
			end
		end
--clean
        sizedir=0
		menu_ctx.wakefunct()
        menu_ctx.close = true
        action = false
        explorer.refresh(true)
        explorer.action = 0
        multi={}
    end
end
 
local filesexport_callback = function ()
    if #explorer.list > 0 then
        local ext = explorer.list[scroll.list.sel].ext or ""
        if ext:lower() == "png" or ext:lower() == "jpg" or ext:lower() == "bmp" or ext:lower() == "gif" or ext:lower() == "mp3" or ext:lower() == "mp4" then
            reboot=false
                message_wait()
                local result = files.export(explorer.list[scroll.list.sel].path)
            reboot=true
 
            if result == 1 then
                if os.message(strings.opensettings,1)==1 then
                    os.delay(150)
                    if ext:lower() == "mp3" then os.uri("music:browse?category=ALL")
                    elseif ext:lower() == "mp4" then os.uri("video:browse?category=ALL")
                    else os.uri("photo:browse?category=ALL") end
                end
            end
--clean
            menu_ctx.wakefunct()
            menu_ctx.close = true
            action = false
            explorer.refresh(true)
            multi={}
            explorer.action = 0
        end
    end
end

local ftp_callback = function ()
	buttons.homepopup(0)
    local pos_menu = menu_ctx.scroll.sel
    menu_ctx.wakefunct2()
    if startftp() then
--clean
        menu_ctx.close = true
        action = false
        explorer.refresh(true)
        explorer.action = 0
        multi={}
    end
	buttons.homepopup(1)
    menu_ctx.scroll.sel = pos_menu
end
 
local usb_callback = function ()
	buttons.homepopup(0)
	local pos_menu = menu_ctx.scroll.sel
	menu_ctx.wakefunct2()
	usbMassStorage()
	buttons.homepopup(1)
	menu_ctx.scroll.sel = pos_menu
end

local qr_callback = function ()
	local pos_menu = menu_ctx.scroll.sel
	menu_ctx.wakefunct2()

	local url = nil

	url=cam.scanqr(strings.qrscan,theme.style.TXTBKGCOLOR)

	if url then
		if not wlan.isconnected() then wlan.connect() end
		if wlan.isconnected() then
			buttons.homepopup(0)
				local res,filename = http.getfile(url,"ux0:downloads/")
			buttons.homepopup(1)
			if res then
				if filename then
					if files.exists("ux0:downloads/"..filename) then
						os.message(strings.success.." ux0:downloads\n\n"..filename)
					end
				end
			else
				os.message(strings.failed.." ux0:downloads\n\n"..filename)
			end
		end
	end

--clean
	menu_ctx.close = true
	action = false
	explorer.refresh(true)
	explorer.action = 0
	multi={}
	menu_ctx.scroll.sel = pos_menu
end

local advanced_callback = function ()
	local pos_menu = menu_ctx.scroll.sel
	menu_ctx.wakefunct2()
	advanced_options()
--clean
	menu_ctx.close = true
	action = false
	explorer.refresh(true)
	explorer.action = 0
	multi={}
	menu_ctx.scroll.sel = pos_menu
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
 
local cancel_callback = function ()
	menu_ctx.wait_action = __ACTION_WAIT_NOTHING
	menu_ctx.wakefunct()
--clean
	menu_ctx.close = true
	action = false
	explorer.refresh(false)
	explorer.action = 0
	multi={}
end
 
menu_ctx = { -- Creamos un objeto menu contextual
    h = 450,				-- Height of menu
    w = 170,				-- Width of menu
    x = -160,				-- X origin of menu
    y = 55,					-- Y origin of menu
    open = false,			-- Is open the menu?
    close = true,
    speed = 10,				-- Speed of Effect Open/Close.
    ctrl = "triangle",		-- The button handle Open/Close menu.
    ctrl2 = "start",
    scroll = newScroll(),	-- Scroll of menu options.
	type = 1,
	wait_action = 0,
}

function menu_ctx.wakefunct()
    menu_ctx.options = { 	-- Handle Option Text and Option Function
		{ text = strings.delete,        funct = delete_callback },
        { text = strings.makedir,       funct = makedir_callback },
        { text = strings.rename,        funct = rename_callback },
        { text = strings.size,          funct = sizedir_callback },
        { text = strings.export,        funct = filesexport_callback },
        { text = strings.insvpkfromdir, funct = installgame_callback },
		{ text = strings.instheme,      funct = installtheme_callback },
		{ text = strings.cancel,        funct = cancel_callback },
    }
    if menu_ctx.wait_action==__ACTION_WAIT_PASTE then
        table.insert(menu_ctx.options, 1, { text = strings.paste,       funct = paste_callback })
    elseif menu_ctx.wait_action==__ACTION_WAIT_EXTRACT then
        table.insert(menu_ctx.options, 1, { text = strings.extractto,   funct = paste_callback })
    else
        table.insert(menu_ctx.options, 1, { text = strings.copy,        funct =  src_path_callback })
        table.insert(menu_ctx.options, 2, { text = strings.move,        funct = src_path_callback })
        table.insert(menu_ctx.options, 3, { text = strings.extract,     funct = src_path_callback })
    end
    menu_ctx.scroll = newScroll(menu_ctx.options, #menu_ctx.options)
end

function menu_ctx.wakefunct2()
    menu_ctx.options = { -- Handle Option Text and Option Function
        { text = strings.ftp,       funct = ftp_callback },
        { text = strings.usb,       funct = usb_callback },
		{ text = strings.qr,       	funct = qr_callback },
        { text = strings.restarthb,	funct = restart_callback },
        { text = strings.reset,     funct = reboot_callback },
        { text = strings.off,       funct = shutdown_callback },
        { text = strings.advanced,  funct = advanced_callback },
    }
    menu_ctx.scroll = newScroll(menu_ctx.options, #menu_ctx.options)
end
 
menu_ctx.wakefunct()
menu_ctx.wakefunct2()

function menu_ctx.run()
    if (menu_ctx.close or menu_ctx.type == 1) and buttons[menu_ctx.ctrl] then
		menu_ctx.type = 1;
		menu_ctx.close = not menu_ctx.close
		if buttons[menu_ctx.ctrl] then menu_ctx.wakefunct() end
	end
	if (menu_ctx.close or menu_ctx.type == 2) and buttons[menu_ctx.ctrl2] then
		menu_ctx.type = 2;
		menu_ctx.close = not menu_ctx.close
		if buttons[menu_ctx.ctrl2] then menu_ctx.wakefunct2() end
	end

    menu_ctx.draw()
	menu_ctx.buttons()
end

local x_print = 5
function menu_ctx.draw()

    if not menu_ctx.close and menu_ctx.x < 0 then
        menu_ctx.x += menu_ctx.speed
    elseif menu_ctx.close and menu_ctx.x > -menu_ctx.w then
        menu_ctx.x -= menu_ctx.speed
    end

	if menu_ctx.x > -menu_ctx.w then
		draw.fillrect(menu_ctx.x, menu_ctx.y, menu_ctx.w, menu_ctx.h, theme.style.BARCOLOR)
	end

    if menu_ctx.x >= 0 then

        menu_ctx.open = true
        local h = menu_ctx.y + 30 -- Punto de origen de las opciones
        for i=menu_ctx.scroll.ini,menu_ctx.scroll.lim do

			screen.clip(0,0,155, menu_ctx.h)
			if i==menu_ctx.scroll.sel then
				if screen.textwidth(menu_ctx.options[i].text) > 155 then
					x_print = screen.print(x_print, h, menu_ctx.options[i].text, 1, color.green, color.blue, __SLEFT,155)
				else
					screen.print(5, h, menu_ctx.options[i].text, 1, color.green, color.blue, __ALEFT)
					x_print = 5
				end
			else
				screen.print(5, h, menu_ctx.options[i].text, 1, theme.style.TXTCOLOR, color.blue, __ALEFT)
			end
			screen.clip()

			h += 25
        end
    else
        menu_ctx.open = false
    end
end

function menu_ctx.buttons()
	if not menu_ctx.open then return end

	if buttons.up or buttons.analogly < -60 then menu_ctx.scroll:up() end
	if buttons.down or buttons.analogly > 60 then menu_ctx.scroll:down() end

	if buttons[accept] and menu_ctx.options[menu_ctx.scroll.sel].funct then
		menu_ctx.options[menu_ctx.scroll.sel].funct()
    end

	if buttons[cancel] then -- Run function of cancel option.
		menu_ctx.close = not menu_ctx.close
	end
end
