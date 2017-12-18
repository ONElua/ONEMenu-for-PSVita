swipe={
	up=false, down=false, -- estas 2 son las q usaremos como si fueran buttons.up y buttons.down
		swpi=false,swpy=0, --status, uso interno
	set=function(x,y,sx,sy,tshd)
		swipe.x,swipe.y,swipe.sx,swipe.sy,swipe.tshd=x,y,sx,sy,tshd
	end,
	read=function()
		if touch.front[1].pressed and not swipe.swpi then
			if touch.front[1].x==math.minmax(touch.front[1].x,swipe.x,swipe.x+swipe.sx) and touch.front[1].y==math.minmax(touch.front[1].y,swipe.y,swipe.y+swipe.sy) then
				swipe.swpi = true
					swipe.swpy=touch.front[1].y
			end
		end
		
		if touch.front[1].released and swipe.swpi then
			swipe.swpi=false
				local dif=swipe.swpy-touch.front[1].y
				swipe.up = ( dif>0 and dif>swipe.tshd )
					swipe.down = ( dif<0 and dif<swipe.tshd*-1 )
				return nil
		end
		swipe.up,swipe.down=false,false
	end
}