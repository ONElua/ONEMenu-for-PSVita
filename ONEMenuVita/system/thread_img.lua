--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

IMAGE_PORT_O = channel.new("IMAGE_PORT_I")
IMAGE_PORT_I = channel.new("IMAGE_PORT_O")

while true do

	if IMAGE_PORT_I:available() > 0 then

		local entry = IMAGE_PORT_I:pop()

		--IMAGE_PORT_O:push( {i = i, j=j, path = appman[i].list[j].path_img, fav = __FAV, resize = appman[i].list[j].resize } ) -- Enviamos peticion
		entry.img = image.load(entry.path)

		if entry.img then
			if entry.fav == 1 then
				entry.img:resize(120,120)
			else
				if entry.resize then
					entry.img:resize(120,100)
				else
					entry.img:resize(120,120)
				end	
			end
			entry.img:setfilter(__IMG_FILTER_LINEAR, __IMG_FILTER_LINEAR)
		end

		IMAGE_PORT_O:push(entry)
		if entry.img then entry.img:lost() end
	end

	os.delay(40) -- ONE frame
end
