--[[
	Updater Of App.
	Designed by DevDavisNunez to ONElua projects.. :D
	TODO:
	Maybe, extract in APP, and only installdir in this..
]]

buttons.homepopup(0)
color.loadpalette()
update = image.load("update.png")

args = os.arg()
if args:len() == 0 then
	os.message("Error args lost!")
	os.exit()
end

args /= "&"
if #args != 3 then
	os.message("Error args lost!")
	os.exit()
end

function onAppInstall(step, size_argv, written, file, totalsize, totalwritten)

    if step == 1 then												-- Only msg of state
		if update then update:blit(0,0) end
			draw.fillrect(0,0,960,30, color.green:a(100))
			screen.print(10,10,"Search in vpk, Unsafe or Dangerous files!")
		screen.flip()
	elseif step == 2 then											-- Warning Vpk confirmation!
		return 10 -- Ok
	elseif step == 3 then											-- Unpack
		if update then update:blit(0,0) end
			draw.fillrect(0,0,960,30, color.green:a(100))
				screen.print(10,10,"Unpack vpk...")
				screen.print(10,35,"File: "..tostring(file))

				l = (totalwritten*940)/totalsize
					screen.print(3+l,495,math.floor((totalwritten*100)/totalsize).."%",0.8,0xFFFFFFFF,0x0,__ACENTER)
						draw.fillrect(10,524,l,6,color.new(0,255,0))
							draw.circle(10+l,526,6,color.new(0,255,0),30)

		screen.flip()
	elseif step == 4 then											-- Promote or install
		if update then update:blit(0,0) end
			draw.fillrect(0,0,960,30, color.green:a(100))
			screen.print(10,10,"Installing...")
		screen.flip()
	end
end

game.install(args[3])
files.delete(args[3])

buttons.homepopup(1)

game.launch(args[2])