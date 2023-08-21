--[[

    Licensed by Creative Commons Attribution-ShareAlike 4.0
   http://creativecommons.org/licenses/by-sa/4.0/
   
   Designed By RG & Gdljjrod.
   
]]

mf={
    getDirectLink = function(file)
		local mf = {}
        local objh = html.parsefile(file)
	    if objh then
			
			local name = objh:find(html.TAG_DIV, html.ATTR_CLASS, "filename")
			if name.text then
				name.text = name.text:gsub('\n','')
				mf.name = name.text
			end

		    local varS = objh:find(html.TAG_A, html.ATTR_CLASS, "input")
			if not varS.raw then varS = objh:find(html.TAG_A, html.ATTR_CLASS, "input popsok") end
			if varS.raw and varS.href then-- return varS.href end
				mf.link = varS.href
			end

			local details = objh:find(html.TAG_UL, html.ATTR_CLASS, "details")
			if details.raw then
				if details.raw:find("File size",1,true) then
					local size = details.raw:match('<span>(.-)</span></li>')
					--os.dialog(size,"size")
					if size then mf.size = size end 
				end
			end

			objh = nil
        end

        return mf
	end
}