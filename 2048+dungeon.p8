pico-8 cartridge // http://www.pico-8.com
version 27
__lua__

--TODO
--	Guardar en que poscicion muere para que al ejecutarse el moviemeitno tenga sentido.
--	los enemigos tmabien pueden cojer los objetos.
--	Mostrar los estados (envenenado, debil, ...) cambiando la coplor del enemigo.

--	FX
--		vibracion de pantalla con acciones del jugador
--		sonido que se escale con los combos

--bugs
--	las escaleras y los pinchos aparecen en el mismo sitio

--INFO
--	tipos fichas 0=interaccion con jugador y entre ell 1=enemigo 2=pickup

function _init()
	ta_movimiento = 20
	ta_ataques=10
	ta_contador = ta_movimiento+ta_ataques
	
	mode=0
	
	start_menu()
	--start_game()
end

function start_menu()
	mode=0
end

function start_game()
	mode=1
	fase_juego=0
	--preparar variables
	nc=flr(rnd(5))+6
	nf=flr(rnd(5))+6
	p_casillas = 0 --Indica la posicion donde se esta realizando la accion en la tabla casillas.
	mapa = {1,1,1,1,1,1,1,0,0,0,0,1,1,0,1,1,1,1,1,0,1,0,0,1,1,0,0,0,0,1,1,1,1,1,1,1}
	t_casillas = {}
	t_sprites={}
	n_trampas = 0
	t_trampas = {}
	-- Crear tablero
	for y=0,nf-1 do
		for x=0,nc-1 do
			
			t_casillas[y*nc+x]=m_casilla(x*8+64-(nc*4), y*8+64-(nf*4))
			r=flr(rnd(3))
			t_casillas[y*nc+x].ficha=flr(rnd(r))
			
			if y==0 or x==0 or x==nc-1 or y==nf-1 then
				t_casillas[y*nc+x].ficha=1
			end
		end
	end
	--	Poner sprites al tablero
	CrearTScriptes()

	--	Crear trampa
	local r = flr(rnd(nc*nf))
	t_trampas[n_trampas] = t_escaleras(CasillaVacia(r))--t_pinchos(CasillaVacia(r))
	n_trampas+=1
	local r = flr(rnd(nc*nf))
	t_trampas[n_trampas] = t_pinchos(CasillaVacia(r))
	n_trampas+=1
	--Crear jugador
	r=flr(rnd(nc*nf))
	r=CasillaVacia(r)
	jugador = f_jugador(t_casillas[r].x, t_casillas[r].y)
	t_casillas[r].ficha=jugador
	--	Crear una caja
	r=flr(rnd(nc*nf))
	r=CasillaVacia(r)
	t_casillas[r].ficha=f_caja(t_casillas[r].x, t_casillas[r].y,1,0)
	--	Crear un enemigo
	r=flr(rnd(nc*nf))
	r=CasillaVacia(r)
	t_casillas[r].ficha=f_enemigo1(t_casillas[r].x, t_casillas[r].y)
end

function start_gameover()
	mode=2
end

function _update60()
	if mode==1 then
		update_game()
	elseif mode==0 then
		update_start()
	elseif mode==2 then
		update_gameover()
	end
end

function _draw()
	if mode==1 then
		draw_game()
	elseif mode==0 then
		draw_start()
	elseif mode==2 then
		draw_gameover()
	end
end

-->8
--updates
function update_start()
	if btn(4) then
		start_game()
	end
end

function update_game()
	if fase_juego==2 then
		if btn(4) then
			start_game()
		end
	else
		if ta_contador<ta_movimiento+ta_ataques then
			ta_contador += 1
		elseif fase_juego==1 then
			fase_juego=2
		elseif btnp(0) and jugador_canmove(-1,0) then -- Isquierda
			moveCasillas(-1,0)
			ta_contador = 0
			accionarTrampas()
		elseif btnp(1) and jugador_canmove(1,0) then -- Derecha
			moveCasillas(1,0)
			ta_contador = 0
			accionarTrampas()
		elseif btnp(2) and jugador_canmove(0,-1) then -- Arriba
			moveCasillas(0,-1)
			ta_contador = 0
			accionarTrampas()
		elseif btnp(3) and jugador_canmove(0,1) then -- Abajo
			moveCasillas(0,1)
			ta_contador = 0
			accionarTrampas()
		end
	end
end

function update_gameover()
	if btn(4) then
		start_game()
	end
end

-->8
--draws
function draw_start()
	cls()
	print("2048 dungeon",40,40,7)
	print("press 🅾️ to start",32,80,11)
end

function draw_game()
	cls(0)
	if fase_juego == 0 then
		local l_por = mid(0, ta_contador/ta_movimiento, 1)
		-- Pintar mazmorra
		for i=0,nc*nf-1 do
			spr(t_sprites[i].ficha,t_sprites[i].x,t_sprites[i].y);
			if hayFicha(i) then
				--printh("------------")
				--printh(ta_contador)
				--printh(l_por)
				--printh(t_casillas[i].ficha.x.."-"..t_casillas[i].ficha.y)
				--printh(t_casillas[i].x.."-"..t_casillas[i].y)
				if ta_contador>ta_movimiento and ta_contador<ta_movimiento then
					spr(t_casillas[i].ficha.sprt, lerp(t_casillas[i].ficha.x,t_casillas[i].x,l_por), lerp(t_casillas[i].ficha.y,t_casillas[i].y,l_por))
				else
					spr(t_casillas[i].ficha.sprt, lerp(t_casillas[i].ficha.x,t_casillas[i].x,l_por), lerp(t_casillas[i].ficha.y,t_casillas[i].y,l_por))
				end
			end
		end
		-- Pintar trampas
		if ta_contador>ta_movimiento and ta_contador<ta_movimiento+ta_ataques then
			for i=0, n_trampas-1 do
				t_trampas[i]:draw(ta_contador-ta_movimiento)
			end
		end
	else
		rectfill(0,60,128,75,0)
		print("nivel completado",32,62,7)
		print("press 🅾️ to continue",24,68,6)
	end
end

function draw_gameover()
	rectfill(0,60,128,75,0)
	print("game over",46,62,7)
	print("press 🅾️ to restart",27,68,6)
end

-->8
--utilidades
function lerp(n0,n1,x)
	perc = x * x * x *(x *(x * 6 - 15) + 10)
	return (1-perc)*n0 + perc*n1
end

function FaltaFicha(x,y,ul,u,ur,l,r,dl,d,dr)
	printh("------")
	printh(x.."x"..y)
	printh(ul.." "..u.." "..ur)
	printh(l.."   "..r)
	printh(dl.." "..d.." "..dr)
	t_sprites[y*nc+x].ficha=0
end

function CasillaVacia(n)
	if t_casillas[n].ficha==0 then
		return n
	else
		return CasillaVacia((n+1)%(nc*nf))
	end
end

function _encontrar(_t)
	for i=0,nc*nf-1 do
		if hayFicha(i) and t_casillas[i].ficha.tipo == _t then
			return i
		end
	end
	return -1
end

function jugador_canmove(_dx,_dy)
	local nf = _encontrar(0)
	return _canmove(nf,_dx,_dy)
end

function _canmove(_nf, _dx, _dy)
	--Convertir numero de ficha a x e y.
	local x = _nf%nc
	local y = _nf-x
	y = y/nc
	
	repeat
		x+=_dx
		y+=_dy
		if t_casillas[y*nc+x].ficha==0 then
			return true
		end
	until (t_casillas[y*nc+x].ficha==1)
	return false
end

-->8
--piezas
function f_ficha()
	local f = {
		x=0,y=0,vida=10,
		tipo=1,sprt=0,llv=false,
		
		draw = function(self,t)
			spr(self.sprt, self.x, self.y)
		end,
		
		accion = function(self, otro)
			return false
		end,
		
		reaccion =function(self, otro)
			return false
		end,
		
		dano = function (self, d)
			return false
		end
	}
	return f
end

function f_fichaCombate()
	local f = f_ficha()
	f.danAtaq=1
	
	f.accion = function(self,otro)
		if otro.tipo!=self.tipo then
			return otro:reaccion(self)
		end
		return false
	end
	
	f.reaccion = function(self, otro)
		return self:dano(otro.danAtaq)
	end
	
	f.dano = function (self, d)
		self.vida -= d
		if self.vida < 1 then
			if self.llv then
				t_casillas[p_casillas].ficha = f_llave(self.x,self.y)
				return false;
			end
			self = 0
			return true
		end
		return false
	end
	
	f.curar = function (self, c)
		self.vida += c
		return false
	end
	
	return f
end

function f_jugador(posX, posY)
	local f = f_fichaCombate()
	f.x=posX
	f.y=posY
	f.danAtaq=3
	f.tipo = 0
	f.sprt = 1
	
	f.accion = function(self,otro)
		return otro:reaccion(self)
	end
	
	f.dano = function (self,d)
		self.vida-=d
		--printh("---vida---"..self.vida)
		if self.vida < 1 then
			--fase_juego=1
			start_gameover()
			--self = 0
		end
		return false
	end
	
	return f
end

function f_enemigo1(posX, posY)
	local f = f_fichaCombate()
	f.x = posX
	f.y = posY
	f.tipo = 1
	f.sprt = 2
	
	return f
end

function f_caja(_x,_y,_obj,_cnt)
	local f = f_fichaCombate()
	f.x = _x
	f.y = _y
	f.tipo = 2
	f.sprt = 4
	f.danAtaq = 0
	f.obj = _obj
	f.cnt = _cnt
	
	f.accion = function(self, otro)
		return false
	end
	
	f.dano = function (self, d)
		self.vida -= d
		if self.vida<1 then
			if self.obj == 0 then
				t_casillas[p_casillas].ficha = f_pocion(self.x,self.y, self.cnt)
			elseif self.obj == 1 then
				t_casillas[p_casillas].ficha = f_llave(self.x,self.y)
			else
				return true
			end
		end
		return false
	end
	
	return f
end

function f_pocion(_x, _y, _vida)
	local f = f_ficha()

	f.x = _x
	f.y = _y
	vida = _vida
	f.tipo = 2
	f.sprt = 3
	
	f.accion = function(self, otro)
		if otro.tipo == self.tipo then
			return false
		end
		otro:curar(self.vida)
		self = 0
		return true
	end
	
	f.reaccion = function(self, otro)
		otro:curar(self.vida)
		self = 0
		return true
	end
	return f
end

function f_pegamento(_x, _y, _vida)
	local f = f_ficha()

	f.x = _x
	f.y = _y
	vida = _vida
	f.tipo = 2
	f.sprt = 3
	
	f.accion = function(self, otro)
		if otro.tipo == self.tipo then
			return false
		end
		otro:curar(self.vida)
		self = 0
		return true
	end
	
	f.reaccion = function(self, otro)
		otro:curar(self.vida)
		self = 0
		return true
	end
	return f
end

function f_llave(_x, _y)
	local f = f_ficha()

	f.x = _x
	f.y = _y
	vida = _vida
	f.tipo = 2
	f.sprt = 5
	
	f.accion = function(self, otro)
		if otro.tipo == self.tipo then
			return false
		end
		otro.llv = true
		self = 0
		return true
	end
	
	f.reaccion = function(self, otro)
		otro.llv = true
		self = 0
		return true
	end
	return f
end

function t_trampa (casilla)
	local t = {
		x=t_casillas[casilla].x,
		y=t_casillas[casilla].y,
		c=casilla,
		spr_idle,
		spr_idle_pared,
		spr_ataq,
		f=0,
		
		init = function(self)
			if t_casillas[self.c-nc].ficha==1 then
				t_sprites[self.c].ficha = self.spr_idle_pared
			else
				t_sprites[self.c].ficha = self.spr_idle
			end
		end,
		
		draw = function(self,t)
			if t<2 then
				spr(self.spr_ataq[1], self.x, self.y)
			elseif t<4 then
				spr(self.spr_ataq[2], self.x, self.y)
			elseif t<6 then
				spr(self.spr_ataq[3], self.x, self.y)
			elseif t<8 then
				spr(self.spr_ataq[4], self.x, self.y)
			else
				spr(self.spr_ataq[5], self.x, self.y)
			end
		end
	}
	return t
end

function t_pinchos (casilla)
	local t=t_trampa(casilla)
	t.spr_idle=43
	t.spr_idle_pared=59
	t.spr_ataq={27,28,29,28,27}
	t.danAtaq=3
	
	t.accion=function(self)
		if hayFicha(self.c) then
			p_casillas=self.c
			if t_casillas[self.c].ficha:dano(self.danAtaq) then
				t_casillas[self.c].ficha=0
			end
		end
	end
	t:init()
	return t
end

function t_escaleras(casilla)
	local t=t_trampa(casilla)
	t.spr_idle=44
	t.spr_idle_pared=60
	t.spr_ataq={43,11,12,13,14}
	t.prev=false
	
	t.accion = function(self)
		if hayFicha(self.c) then
			p_casillas=self.c
			if t_casillas[self.c].ficha.tipo==0 and t_casillas[self.c].ficha.llv then
				fase_juego=1
				--start_game()
			end
		end
	end
	
	t.draw = function(s,t)
		if not s.prev and jugador.llv then
			if t<2 then
				spr(s.spr_ataq[1], s.x, s.y)
			elseif t<4 then
				spr(s.spr_ataq[2], s.x, s.y)
			elseif t<6 then
				spr(s.spr_ataq[3], s.x, s.y)
			elseif t<8 then
				spr(s.spr_ataq[4], s.x, s.y)
			else
				spr(s.spr_ataq[5], s.x, s.y)
				t_sprites[s.c].ficha = s.spr_ataq[5]
				s.prev = true
			end
		end
	end
	
	t:init()
	return t
end

function t_ballesta(casilla)
	local t=t_trampa(casilla)
	t.spr_idle=43
	t.spr_idle_pared=59
	t.spr_ataq={27,28,29,28,27}
	t.danAtaq=3
	t.dirx=0
	t.diry=0
	
	t.accion=function(s)
		local x=nf%nc
		local y=nf-x
		y=y/nc
		repeat
			x+=s.dirx
			y+=z.diry
			if hayFicha(y*nc+x) then
				p_casillas=y*nc+x
				if t_casillas[y*nc+x].ficha:dano(self.danAtaq) then
					t_casillas[y*nc+x].ficha=0
				end
			end
		until t_casillas[y*nc+x]==1
	end
	t:init()
	return t	
end

function m_casilla(posX, posY)
	local c ={
		x=posX,
		y=posY,
		ficha=0
	}
	return c
end

-->8
--juego
function moveCasillas(dirX, dirY)
	local y = 0--1
	local x = 0
	local xI = 0
	local fY = nf
	local fX = nc
	local fyy = -1
	local fxx = -1
	local count = 1
	if(dirY == -1) then
		fyy = 0
	elseif(dirX == -1) then
		fxx = 0
	elseif(dirY == 1) then
		y = nf-1
		x = nc-1
		xI = nc-1
		fY = -1
		fX = -1
		fyy = nf-1
		count = -1
	elseif(dirX == 1) then
		y = nf-1
		x = nc-1
		xI = nc-1
		fY = -1
		fX = -1
		fxx = nc
		count = -1
	end

	while y != fY do
		while x != fX do
			if hayFicha(y*nc+x) then--t_casillas[y*nc+x].ficha != 0 and t_casillas[y*nc+x].ficha != 1 then
				xx = x
				yy = y
				if yy!=fyy and xx!=fxx and moverFicha(y*nc+x, (yy+dirY)*nc+(xx+dirX)) then
				--if moverFicha(y*nc+x, (yy+dirY)*nc+(xx+dirX)) then
					repeat
						xx += dirX
						yy += dirY
					until yy==fyy or xx==fxx or not moverFicha(y*nc+x, (yy+dirY)*nc+(xx+dirX))
					if t_casillas[y*nc+x].ficha != 0 then
						t_casillas[yy*nc+xx].ficha = t_casillas[y*nc+x].ficha
						t_casillas[y*nc+x].ficha = 0
					end
				end
				if t_casillas[yy*nc+xx].ficha != 0 then
					t_casillas[yy*nc+xx].ficha.x = t_casillas[y*nc+x].x
					t_casillas[yy*nc+xx].ficha.y = t_casillas[y*nc+x].y
				end
			end
			x += count
		end
		x = xI
		y += count
	end
	y=0
end

function accionarTrampas()
	for i=0, n_trampas-1 do
		t_trampas[i]:accion()
	end
end

-- Todas las acciones entre fichas
function moverFicha(origen, destino)
	if t_casillas[destino].ficha == 0 then
		return true
	elseif t_casillas[destino].ficha == 1 then
		return false
	end
	p_casillas = destino
	r = t_casillas[origen].ficha:accion(t_casillas[destino].ficha)
	if r and t_casillas[origen].ficha.tipo==2 then
		t_casillas[origen].ficha = 0;
		r = false;
	end
	return r;
end

-- Mira si hay una ficha en esa posicion
function hayFicha(pos)
	return t_casillas[pos].ficha!=0 and t_casillas[pos].ficha != 1
end

function CrearTScriptes()
	local suelo={16,32,48}
	local suelomuro={17,33,49}
	for y=0,nf-1 do
		for x=0,nc-1 do
			-- 0=fuera, 1=bloque, 2=suelo
			local u=2
			local ur=2
			local ul=2
			local d=2
			local dr=2
			local dl=2
			local r=2
			local l=2
			--	Ariba
			if y-1<0 then
				u=0
				ur=0
				ul=0
			elseif t_casillas[(y-1)*nc+x].ficha==1 then u=1
			end
			--	Abajo
			if y+1==nf then
				d=0
				dr=0
				dl=0
			elseif t_casillas[(y+1)*nc+x].ficha==1 then d=1
			end
			--	Izquierda
			if x-1<0 then
				l=0
				ul=0
				dl=0
			elseif t_casillas[y*nc+(x-1)].ficha==1 then l=1
			end
			--	Derecha
			if x+1==nc then
				r=0
				ur=0
				dr=0
			elseif t_casillas[y*nc+(x+1)].ficha==1 then r=1
			end
			
			if ul!=0 and t_casillas[(y-1)*nc+(x-1)].ficha==1 then ul=1
			end
			if ur!=0 and t_casillas[(y-1)*nc+(x+1)].ficha==1 then ur=1
			end
			if dl!=0 and t_casillas[(y+1)*nc+(x-1)].ficha==1 then dl=1
			end
			if dr!=0 and t_casillas[(y+1)*nc+(x+1)].ficha==1 then dr=1
			end
			
			t_sprites[y*nc+x]=m_casilla(x*8+64-(nc*4), y*8+64-(nf*4))
			if t_casillas[y*nc+x].ficha==1 then -- casillas muro
				if u==0 then
					if d!=2 and l!=2 and r!=2 and dr!=2 and dl!=2 and ur!=2 and ul!=2 then
						t_sprites[y*nc+x].ficha=6
						--	Finales
					elseif d==2 and l==1 and r==1 and ur!=2 and ul!=2 then
						t_sprites[y*nc+x].ficha=19
						--	Final Esquina
					elseif d==1 and l!=2 and r==1 and dr==2 and dl!=2 and ur!=2 and ul!=2 then
						t_sprites[y*nc+x].ficha=18
					elseif d==1 and l==1 and r!=2 and dr!=2 and dl==2 and ur!=2 and ul!=2 then
						t_sprites[y*nc+x].ficha=20
						-- Linea Entrada
					elseif d==1 and l==1 and r==1 and dr==2 and dl==2 and ur!=2 and ul!=2 then
						t_sprites[y*nc+x].ficha=26
					else
						FaltaFicha(x,y,ul,u,ur,l,r,dl,d,dr)
					end
				elseif u==1 then
					if d==0 then
						if l!=2 and r!=2 and dr!=2 and dl!=2 and ur!=2 and ul!=2 then
							t_sprites[y*nc+x].ficha=6
							-- Final esquina
						elseif l!=2 and r==1 and dr!=2 and dl!=2 and ur==2 and ul!=2 then
							t_sprites[y*nc+x].ficha=50
						elseif l==1 and r!=2 and dr!=2 and dl!=2 and ur!=2 and ul==2 then
							t_sprites[y*nc+x].ficha=52
							-- Linea entrada
						elseif l==1 and r==1 and dr!=2 and dl!=2 and ur==2 and ul==2 then
							t_sprites[y*nc+x].ficha=25
						else
							FaltaFicha(x,y,ul,u,ur,l,r,dl,d,dr)
						end
					elseif d==1 then
						if l!=2 and r!=2 and dr!=2 and dl!=2 and ur!=2 and ul!=2 then
							t_sprites[y*nc+x].ficha=6
							-- Finales
						elseif l!=2 and r==2 and ul!=2 and dl!=2 then
							t_sprites[y*nc+x].ficha=34
						elseif l==2 and r!=2 and ur!=2 and dr!=2 then
							t_sprites[y*nc+x].ficha=36
							--	Final Esquina
						elseif l!=2 and r==1 and dr==2 and dl!=2 and ur!=2 and ul!=2 then
							t_sprites[y*nc+x].ficha=18
						elseif l==1 and r!=2 and dr!=2 and dl==2 and ur!=2 and ul!=2 then
							t_sprites[y*nc+x].ficha=20
						elseif l!=2 and r==1 and dr!=2 and dl!=2 and ur==2 and ul!=2 then
							t_sprites[y*nc+x].ficha=50
						elseif l==1 and r!=2 and dr!=2 and dl!=2 and ur!=2 and ul==2 then
							t_sprites[y*nc+x].ficha=52
							--	Linea Recta
						elseif l==2 and r==2 then
							t_sprites[y*nc+x].ficha=53
							--	Linea entrada
						elseif l!=2 and r==1 and dr==2 and dl!=2 and ur==2 and ul!=2 then
							t_sprites[y*nc+x].ficha=23
						elseif l==1 and r!=2 and dr!=2 and dl==2 and ur!=2 and ul==2 then
							t_sprites[y*nc+x].ficha=24
						elseif l==1 and r==1 and dr!=2 and dl!=2 and ur==2 and ul==2 then
							t_sprites[y*nc+x].ficha=25
						elseif l==1 and r==1 and dr==2 and dl==2 and ur!=2 and ul!=2 then
							t_sprites[y*nc+x].ficha=26
						else
							FaltaFicha(x,y,ul,u,ur,l,r,dl,d,dr)
						end
					elseif d==2 then
							-- Finales
						if l==1 and r==1 and ur!=2 and ul!=2 then
							t_sprites[y*nc+x].ficha=19
							-- Linea Final
						elseif l==2 and r==2 then
							t_sprites[y*nc+x].ficha=37
							--	Mordiscos
						elseif l==2 and r==1 and ur!=2 then
							t_sprites[y*nc+x].ficha=55
						elseif l==1 and r==2 and ul!=2 then
							t_sprites[y*nc+x].ficha=56
							-- Linea giros
						elseif l==2 and r==1 and ur==2 then
							t_sprites[y*nc+x].ficha=57          
						elseif l==1 and r==2 and ul==2 then
							t_sprites[y*nc+x].ficha=58
						else
							FaltaFicha(x,y,ul,u,ur,l,r,dl,d,dr)
						end
					else
						FaltaFicha(x,y,ul,u,ur,l,r,dl,d,dr)
					end
				elseif u==2 then
					-- Finales
					if d!=2 and l==1 and r==1 and dr!=2 and dl!=2 then
						t_sprites[y*nc+x].ficha=51
						--	Linea Final
					elseif d==2 and l==2 and r==1 then	
						t_sprites[y*nc+x].ficha=21
					elseif d==1 and l==2 and r==2 then
						t_sprites[y*nc+x].ficha=22
					elseif d==2 and l==1 and r==2 then
						t_sprites[y*nc+x].ficha=38
						-- Linea recta
					elseif d==2 and l==1 and r==1 then
						t_sprites[y*nc+x].ficha=54
						--	Mordiscos
					elseif d==1 and l==2 and r==1 and dr!=2 then
						t_sprites[y*nc+x].ficha=39
					elseif d==1 and l==1 and r==2 and dl!=2 then
						t_sprites[y*nc+x].ficha=40
						--	Linea giros
					elseif d==1 and l==2 and r==1 and dr==2 then
						t_sprites[y*nc+x].ficha=41          
					elseif d==1 and l==1 and r==2 and dl==2 then
						t_sprites[y*nc+x].ficha=42
					elseif d==2 and l==2 and r==2 then
						t_sprites[y*nc+x].ficha=35
					else
						FaltaFicha(x,y,ul,u,ur,l,r,dl,d,dr)
					end
				else
					FaltaFicha(x,y,ul,u,ur,l,r,dl,d,dr)
				end
			else
				if t_casillas[(y-1)*nc+x].ficha == 1 then
					t_sprites[y*nc+x].ficha=rnd(suelomuro)
				else
					t_sprites[y*nc+x].ficha=rnd(suelo)
				end
			end
		end
	end
end
__gfx__
0000000005cc55700c55c570055cc5500555555005555550000000000000000000000000000000001288e000000000000000000000000000cc00000000000000
000000005cccc5755cccc56755cccc555cccccc55dd555550000000000000000000000000000000015d670000000000000000000cc0cc000cc0cc00000000000
007007005555c56555c5c567555555555c5555c5dccddddd000000000000000000000000000000001244f00000000000cc0cc0cccc0cc0cccc0cc0cc00000000
000770005c5cc5655ccc556755c88c555cddddc5c55ccccc0000000000000000000000000000000053ba7000cc0cc0cccc0cc0cccc0cc0cc000cc0cc00000000
0007700055555565555555675c8c88c55cccccc5cddc5c5c000000000000000000000000000000001dc67000cc0cc0cccc0cc0cc000000cccc0000cc00000000
00700700c5ccc5c5c5ccc5c55c8888c5555555555cc55c5c00000000000000000000000000000000249a7000cc0cc0cc00000000cc0cc000cc0cc00000000000
0000000055ccc56555ccc56555cccc555cccccc555555555000000000000000000000000000000009af4700000000000cc0cc0cccc0cc0cccc0cc0cc00000000
0000000005c5c56005c5c55005555550055555500555555000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666066600000000000000000000000000666666606666660000556066066550060656606000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000006000000060000006005566000065500000665600000000000000000000000000000070000000000000000000
00000000606660660000005005050505505000006066666660666606000555666656550066556566050005050000000000000000000760070000000000000000
00000000000000000000555555555555555500006065565660655606000056565655500065655565555055550000000000007007700760760000000000000000
00000000000000000005556565656565656550006065656560656606000555656565000055550555565556560000000770076076670760760000000000000000
50500000505000000055666666666666666550006066666660665606005565666655500050500050665655667000707667076076670760760000000000000000
00000000000000000005560000000000006655006000000060656606000556000066550000000000006566006707600067076000670760000000000000000000
50500000505000000055660666666666606550006666666660665606005566066065500000000000606656060007600000076000000760000000000000000000
00000000666066600005560606666660606655006065660666666660066666666666666000666666666666000000000000000000000000000000000000000000
00000000000000000055660660000006606550006066560600000006600000000000000606000000000000600000000000000000000000000000000000000000
00000000606660660005560660666606606655006065660666666606606666666666660660066666666660060000000000000000000000000000000000000000
00000000000000000055660660655606606550006066560656565606606556565656560660665656565656060000000000000000000000000000000000000000
00000000000000000005560660655606606655006065560665655606606655555555560660656565656566060000000055055055000000000000000000000000
55050000550500000055660660666606606550006066660666666606606550050505660660665666666656060000005555055055000000000000000000000000
00000000000000000005560660000006606655006000000600000006606655000005560660656600006566065500000055055055000000000000000000000000
50550000505500000055660666666666606550006666666666666666606550000055660660665606606656060005500000000000000000000000000000000000
00000000666066600005560666666666606655006065660666666666606655000005560660656606606566066660666066606660000000000000000000000000
00000000000000000055660000000000006550006066560600000000606550000055660660665600006656060000000000000000000000000000000000000000
00000000606660660005566666666666666655006065660666666666606650505005560660656666666566066066606660666066000000000000000000000000
00000000000000000005565656565656565550006066560656565656606555555555660660665656565656060000000000000000000000000000000000000000
50500000505000000000555555555555555500006065660665656565606565656565560660656565656566060000000055055055000000000000000000000000
50000000500000000000050505050505050000006066560666666666606666666666660660666666666666060000005555055055000000000000000000000000
00500000005000000000000000000000000000006065660600000000600000000000000660000000000000065500000055055055000000000000000000000000
50500000505000000000000000000000000000006066560666666666066666666666666066666666666666660005500000000000000000000000000000000000
__map__
1213131400000000001010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2221212412131313131a13131314000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2210103738113b11113511111124000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2210101111101023103510161024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2210102733281010102510251024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2210102410323328101110111024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2210103713131338101536261024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2210101111111111101111111024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3233333333333333333333333334000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
