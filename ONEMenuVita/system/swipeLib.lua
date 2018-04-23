-- swipeLib, by RoberGalarga @ ONETeam 

-- ==== USO ====
-- 1) dofile a la lib
-- 2) llamar a swipe.set, args: threshold (obligatorio); x,y,sx,sy (opcionales, para definir zona activa)
-- 3) llamar a touch.read() y swipe.read()
-- 4) mapeo a otras teclas:
--	maps: { {real,swipe},...,{real,swipe} }
--		
--	Ejemplo { {"left","left"},{"right","right"} } asigna a buttons.left y buttons.right los valores de swipe.left y swipe.right
--	`	
--	Se puede asignar el valor de un swipe a más de una tecla, repitiendo las entradas:
--			{ {"left","left"},{"l","left"} }  Asigna el valor de swipe.left a buttons.left y buttons.l
--	
--	Para activar el mapeo, asignar la tabla a swipe.map directamente.
--	Para desactivarlo, asignar nil a swipe.map
--  ADVERTENCIA: Llamar a swipe.read() siempre después de buttons.read(), de lo contrario no surte efecto el mapeo!
--las diagonales están activadas por default... pa desactivarlas pones
--swipe.enableDiagonal=false

swipe={

	up=false,down=false,right=false,left=false, -- variables para detectar los swipes
		swpi=false,swpy=0,swpx=0,byZone=false,doV=false, --status, uso interno
	enableDiagonal=true, enableContinuous=true, disableAll=false, --vars de control, setearlas directamente para cambiar!
	disableContV=false, disableContH=false,

	set = function(tshd,x,y,sx,sy)
		if x and y and sx and sy then swipe.byZone = true else swipe.byZone = false end
			swipe.x,swipe.y,swipe.sx,swipe.sy = x,y,sx,sy
				swipe.tshd = tshd
	end,

	read = function()
		
		if not swipe.disableAll then

			if touch.front[1].pressed and not swipe.swpi then	--esta es para detectar el toque por primera vez
				if swipe.byZone then 
					if touch.front[1].x == math.minmax(touch.front[1].x,swipe.x,swipe.x+swipe.sx) and touch.front[1].y == math.minmax(touch.front[1].y,swipe.y,swipe.y+swipe.sy) then
						swipe.swpi = true
							swipe.swpy = touch.front[1].y
								swipe.swpx = touch.front[1].x
					end
				else
					swipe.swpi = true
						swipe.swpy = touch.front[1].y
							swipe.swpx = touch.front[1].x
				end
			end

			if not swipe.enableDiagonal and swipe.swpi then		--esta detecta la dirección del toque cuando se desactivan las diagonales!
				if not swipe.locked then
					if math.abs(swipe.swpy-touch.front[1].y) > swipe.tshd or math.abs(swipe.swpx-touch.front[1].x) > swipe.tshd then
							swipe.doV = ( math.abs(swipe.swpy-touch.front[1].y)>math.abs(swipe.swpx-touch.front[1].x) )
								swipe.locked = true
					end
				end
			end

			if swipe.enableContinuous then	--modo continuo
				if swipe.swpi then	
					if swipe.enableDiagonal then
						swipe.up,swipe.down,swipe.swpy = swipe.continuousCheck(swipe.swpy,touch.front[1].y,swipe.tshd)
							swipe.left,swipe.right,swipe.swpx = swipe.continuousCheck(swipe.swpx,touch.front[1].x,swipe.tshd)
					else
						if swipe.locked then

							if swipe.doV then

								if not swipe.disableContV then
							
									swipe.up,swipe.down,swipe.swpy = swipe.continuousCheck(swipe.swpy,touch.front[1].y,swipe.tshd)
										swipe.left,swipe.right = false,false
								else
									if touch.front[1].released and swipe.swpi then--modo simple
										swipe.swpi,swipe.locked = false,false
											swipe.up,swipe.down = swipe.singleCheck(swipe.swpy,touch.front[1].y,swipe.tshd)
												swipe.right,swipe.left,swipe.doV = false,false,false
									end
									swipe.updateMaping()
									return nil
								end

							else
								if not swipe.disableContH then
									swipe.left,swipe.right,swipe.swpx = swipe.continuousCheck(swipe.swpx,touch.front[1].x,swipe.tshd)
										swipe.up,swipe.down = false,false
								else
									if touch.front[1].released and swipe.swpi then--modo simple
										swipe.swpi,swipe.locked = false,false
											swipe.left,swipe.right = swipe.singleCheck(swipe.swpx,touch.front[1].x,swipe.tshd)
												swipe.up,swipe.down = false,false
									end
									swipe.updateMaping()
									return nil
								end
							end
						end
					end
						
					if touch.front[1].released then
						swipe.swpi = false
							swipe.locked=false
					end
					
						swipe.updateMaping()
					return nil
				end
			else		--modo simple
				if touch.front[1].released and swipe.swpi then
					swipe.swpi,swipe.locked = false,false
						if swipe.enableDiagonal then
							swipe.up,swipe.down = swipe.singleCheck(swipe.swpy,touch.front[1].y,swipe.tshd)
								swipe.left,swipe.right = swipe.singleCheck(swipe.swpx,touch.front[1].x,swipe.tshd)
						else
							if swipe.doV then
								swipe.up,swipe.down = swipe.singleCheck(swipe.swpy,touch.front[1].y,swipe.tshd)
									swipe.right,swipe.left,swipe.doV = false,false,false
							else
								swipe.left,swipe.right = swipe.singleCheck(swipe.swpx,touch.front[1].x,swipe.tshd)
									swipe.up,swipe.down = false,false
							end
						end
					swipe.updateMaping()
						return nil
				end
			end

			swipe.up,swipe.down,swipe.right,swipe.left=false,false,false,false
				swipe.updateMaping()
		end
	end,

	-- Funciones auxiliares, no usarlas directamente!
	updateMaping=function()
		if swipe.map then
			for i=1,#swipe.map do
				buttons[swipe.map[i][1]]=swipe[swipe.map[i][2]]
			end
		end
	end,

	continuousCheck = function(init,actual,tshd)
		local dif=init-actual
			if dif>0 and dif>tshd then
				return true,false,init-tshd
			elseif dif<0 and dif<tshd*-1 then
				return false,true,init+tshd
			else return false,false,init end
	end,

	singleCheck = function(init,actual,tshd)
		local dif = init-actual
			return (dif>0 and dif>tshd),(dif<0 and dif<tshd)
	end

}

swipe.set(30,255,70,695,430)
	swipe.enableDiagonal=false
		swipe.disableContV=true
