--[[
(C) Copyright 2014 William Dyce

All rights reserved. This program and the accompanying materials
are made available under the terms of the GNU Lesser General Public License
(LGPL) version 2.1 which accompanies this distribution, and is available at
http://www.gnu.org/licenses/lgpl-2.1.html

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
Lesser General Public License for more details.
--]]

local state = gamestate.new()

local t = nil

--[[------------------------------------------------------------
Gamestate navigation
--]]--

function state:init()
end

function state:enter()
	t = 0
	Bonfire(WORLD_W*0.5, WORLD_H*0.5)
end

function state:leave()
	GameObject.purgeAll()
end

--[[------------------------------------------------------------
Callbacks
--]]--

function state:keypressed(key, uni)
  if key=="escape" then
    love.event.push("quit")
  end
end

function state:mousepressed(x, y, button)
  gamestate.switch(game)
end

function state:update(dt)
	t = t + dt

	-- update all object
	GameObject.updateAll(dt, { oblique = VIEW_OBLIQUE })
end

function state:draw()
	WORLD_CANVAS:clear()

	-- calculate lightness based on time of day
	local day_night = 0.3
	local lightness = math.max(0, 4*(1 - day_night)*day_night)
	local r, g, b = useful.ktemp(useful.lerp(16000, 2000, day_night))
	useful.pushCanvas(COLOUR_CANVAS)
		love.graphics.setColor(r*lightness, g*lightness, b*lightness, 32)
			love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)
		useful.bindWhite()
	useful.popCanvas()

	useful.pushCanvas(ALPHA_CANVAS)
		useful.bindWhite(lightness*255)
			love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)
		useful.bindBlack((1 - lightness)*255)
			love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)
		useful.bindWhite()
	useful.popCanvas()

	-- snow
	love.graphics.setColor(200, 200, 255)
		love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)
	useful.bindWhite()

	-- lightness at center
	GameObject.drawAll()

	-- light overlays
	useful.pushCanvas(LIGHT_CANVAS)
		love.graphics.draw(COLOUR_CANVAS)
		love.graphics.setBlendMode("multiplicative")
			love.graphics.draw(ALPHA_CANVAS)
		love.graphics.setBlendMode("alpha")
	useful.popCanvas(LIGHT_CANVAS)
	love.graphics.setBlendMode("multiplicative")
		love.graphics.draw(LIGHT_CANVAS)
	love.graphics.setBlendMode("alpha")

	-- UI
	local offset = 8*math.sin(2*t)
	love.graphics.setFont(FONT_BIG)
	love.graphics.printf("Twilight of Humanity", 
		WORLD_W*(0.5 - 0.3), WORLD_H*0.01 + offset, WORLD_W*0.6, "center") 
	love.graphics.setFont(FONT_MEDIUM)
	love.graphics.printf("@wilbefast\n#LDJam #LudumDare31", 
		WORLD_W*(0.5 - 0.3), WORLD_H*0.7 + offset, WORLD_W*0.6, "center") 

	love.graphics.setFont(FONT_SMALL)
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state