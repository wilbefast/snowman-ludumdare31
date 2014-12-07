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

--[[------------------------------------------------------------
Defines
--]]--

local MAX_PICK_DIST2 = 24*24
local MAX_THROW_DIST2 = 1024*1024--256*256

--[[------------------------------------------------------------
Internal state
--]]--

local picked_human = nil
local t = 0
local wave = 0

current_temperature = 0
current_windspeed = 1

local day_night = 0
function isDaytime()
	return (day_night > 0)
end
function isLight()
	return (day_night > 0.2) and (day_night < 0.8) 
end



--[[------------------------------------------------------------
Gamestate navigation
--]]--

function state:init()
end


function state:enter()
	SHADOW_CANVAS:clear()

	-- reset darkness canvas
	useful.pushCanvas(DARKNESS_CANVAS)
		useful.bindBlack()
			love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)
		useful.bindWhite()
	useful.popCanvas()

	-- reset
	picked_human = nil
	day_night = 0
	wave = 1

	-- repopulate world
	-- ... fire
	local h
	GameObject.mapToType("Bonfire", function(o) h = o.heat o.purge = true end)
	Bonfire(WORLD_W*0.5, WORLD_H*0.5).heat = h
	-- ... people
	for i = 1, 6 do
		local angle = math.random()*math.pi*2
		local distance = 150*(1 + 0.1*math.random())
		Human(
			math.cos(angle)*distance + WORLD_W*0.5, 
			math.sin(angle)*distance + WORLD_H*0.5, 
			i < 4)
	end
	-- ... trees
	for i = 1, 8 do
		local angle = math.random()*math.pi*2
		local distance = WORLD_W*(0.3 + 0.2*(i - 1)/8)
		Tree(
			math.cos(angle)*distance + WORLD_W*0.5, 
			math.sin(angle)*distance + WORLD_H*0.5)
	end
end


function state:leave()
	GameObject.purgeAll()
	picked_human = nil
	SHADOW_CANVAS:clear()
end

--[[------------------------------------------------------------
Callbacks
--]]--

function state:keypressed(key, uni)
  if key == "escape" then
    gamestate.switch(title)
  end
end

function state:mousepressed(x, y)

	local pick, pick_dist2 = GameObject.getNearestOfType("Human", x, y)
	if pick_dist2 < MAX_PICK_DIST2 then
		picked_human = pick
		picked_human:pick()
	else
		local thrower = GameObject.getNearestOfType("Human", x, y, 
			function(human) return human:canThrow(x, y) 
		end)
		if thrower then
			thrower:throw(x, y)
		end
	end
end

function state:mousereleased()
	if picked_human then
		picked_human:unpick()
		picked_human = nil
	end
end	

function state:update(dt)

	local mx, my = love.mouse.getPosition()

	-- calculate time of day
	day_night = day_night + dt/60
	if day_night > 1 then
		-- night falls
		day_night = day_night - 2
		-- spawn monsters
		for i = 1, wave do
			local angle = math.pi*2*math.random()
			Monster(
				math.cos(angle)*WORLD_W*(1 + math.random()*3), 
				math.sin(angle)*WORLD_H*(1 + math.random()*3))
		end
		wave = wave + 1
	end

	-- temperature depends on time of day and wind
	current_temperature = math.sin(day_night*math.pi)*current_windspeed

	-- update all object
	GameObject.updateAll(dt, { oblique = VIEW_OBLIQUE })
end

function state:draw()

	WORLD_CANVAS:clear()

	-- calculate lightness based on time of day
	update_light(day_night)

	-- snow
	love.graphics.setColor(200, 200, 255)
		love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)
	useful.bindWhite()

	-- shadows
	GameObject.mapToAll(function(o) if o.antiShadow then o:antiShadow() end end)
	useful.bindBlack(128)
		love.graphics.draw(SHADOW_CANVAS)
	useful.bindWhite()
	SHADOW_CANVAS:clear()

	-- game objects
	GameObject.drawAll()

	-- light overlays
	bake_light()

	-- mouse
	useful.pushCanvas(UI_CANVAS)
		local mx, my = love.mouse.getPosition()
		love.graphics.circle("fill", mx, my, 6)
		love.graphics.setBlendMode("subtractive")
			love.graphics.circle("fill", mx, my, 4)
		love.graphics.setBlendMode("alpha")

		-- score
		if (day_night > 0.2) and (day_night < 0.4) then
			love.graphics.setFont(FONT_MEDIUM)
				love.graphics.printf("Day " .. tostring(wave),
				 WORLD_W*(0.5 - 0.2), WORLD_H*0.05, WORLD_W*0.4, "center")
		end

	useful.popCanvas()
	-- debug overlay
	if DEBUG then
		love.graphics.setFont(FONT_SMALL)
		love.graphics.print("time: " .. tostring(math.floor(day_night*10)/10), 64, 32)
		love.graphics.print("temperature: " .. tostring(math.floor(current_temperature*10)/10), 64, 64)
	end
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state