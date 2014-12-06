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

--[[------------------------------------------------------------
Initialisation
--]]--

local Human = Class
{
  FRICTION = 100,

  type = GameObject.newType("Human"),

  init = function(self, x, y)
    GameObject.init(self, x, y, 5)
    self.t = math.random()
  end,
}
Human:include(GameObject)

--[[------------------------------------------------------------
Destruction
--]]--

function Human:onPurge()
end

--[[------------------------------------------------------------
States
--]]--

function Human:setState(newStateClass, ...)
  
  if self.state.class == newStateClass then
    return
  end
  local newState = newState(self, ...)
  newState.class = newStateClass

  local oldState = self.state
  if oldState.exitTo then
    oldState.exitTo(newState)
  end
  if newState.enterFrom then
    newState.enterFrom(oldState)
  end
  self.state = newState
end


--[[------------------------------------------------------------
Game loop
--]]--

function Human:update(dt)
  self.t = self.t + dt*0.3
  if self.t > 1 then
    self.t = self.t - 1
  end

  GameObject.update(self, dt)
end

function Human:draw(x, y)
  light(x, y, 64, 2)
end

function Human:draw_afterdark(x, y)
  love.graphics.setColor(255, 190, 187)
    love.graphics.rectangle("fill", self.x - 8, self.y - 32, 16, 32)
  useful.bindWhite()
end

--[[------------------------------------------------------------
Combat
--]]--

function Human:throw(x, y)
  local thrown = Torch(self.x, self.y, x, y)
end

--[[------------------------------------------------------------
Collisions
--]]--

function Human:eventCollision(other, dt)
  if other:isType("Human") then
    other:shoveAwayFrom(self, 100*dt)
  end
end


--[[------------------------------------------------------------
Export
--]]--

return Human