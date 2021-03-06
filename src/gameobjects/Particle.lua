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

local Particle = {
	type = GameObject.newType("Particle")
}

local n_particles = 0

--[[------------------------------------------------------------
Fire
--]]--

local Fire = Class
{
  type = Particle.type,

  FRICTION = 6,

  init = function(self, x, y, dx, dy, dz, sizeMult)
    GameObject.init(self, x, y, 0)
    self.dx, self.dy, self.dz = dx, dy, dz or 0
    self.z = 0
    self.t = 0
    self.red = 200 + math.random()*55
    self.green = 200 + math.random()*25
    self.blue = 10 + math.random()*5
    self.dieSpeed = 1.3 + 1.2*math.random()
    self.sizeMult = (sizeMult or 1)
    size = self.sizeMult*8
    self.size = size*(1 + 0.5*math.random())

    n_particles = n_particles + 1
  end,
}
Fire:include(GameObject)

function Fire:update(dt)
	self.t = self.t + self.dieSpeed*dt*(1 + n_particles/75)
	self.r = math.max(0, math.sin(self.t*math.pi)*self.size)
	if self.t > 1 then
		self.purge = true
	end

	GameObject.update(self, dt)
	self.z = self.z + self.dz*dt
end

function Fire:draw(x, y)
	x, y = self.x, self.y
	love.graphics.setColor(self.red, self.green, self.blue)
		useful.oval("fill", x, y - self.z, self.r, self.r)
	useful.bindWhite()
	light(x, y, self.z, (1 - self.t)*self.sizeMult)
	light(x, y - self.z, 0, (1 - self.t)*self.sizeMult)
end

function Fire:onPurge()
	n_particles = n_particles - 1
end

Particle.Fire = Fire

--[[------------------------------------------------------------
Smoke
--]]--

local Smoke = Class
{
  type = Particle.type,

  FRICTION = 100,

  init = function(self, x, y, dx, dy, dz, size)
    GameObject.init(self, x, y, 0)
    self.dx, self.dy, self.dz = dx, dy, dz or 0
    self.z = 0
    self.t = 0
    self.a = 50 + math.random()*55
    size = (size or 1)*10
    self.size = size*(1 + 0.5)*math.random()
    self.dieSpeed = 0.5 + math.random()*0.7

    n_particles = n_particles + 1
  end,
}
Smoke:include(GameObject)

function Smoke:update(dt)
	self.t = self.t + self.dieSpeed*dt*(1 + n_particles/75)
	self.r = math.max(1, math.sin(self.t*math.pi)*self.size)
	if self.t > 1 then
		self.purge = true
	end

	GameObject.update(self, dt)
	self.z = self.z + self.dz*dt
end

function Smoke:draw(x, y)
	local r = self.r
	local shad_r = math.min(r, 32*r/self.z)

	useful.pushCanvas(SHADOW_CANVAS)
		useful.oval("fill", x, y, shad_r, shad_r*VIEW_OBLIQUE)
	useful.popCanvas()

	love.graphics.setColor(self.a, self.a, self.a)
		useful.oval("fill", x, y - self.z, r, r)
	useful.bindWhite()
end


function Smoke:onPurge()
	n_particles = n_particles - 1
end

Particle.Smoke = Smoke

--[[------------------------------------------------------------
Export
--]]--

return Particle