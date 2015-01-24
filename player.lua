local class = require "middleclass"

local Player = class('Player')

function Player:initialize(name, x, y, imagePath)
   self.name = name
   self.x = x
   self.y = y
   self.w = 82
   self.h = 150
   self.speed = 250
   self.velocity = { x = 50, y = 0 }
   self.image = gr.newImage(imagePath)
   self.jump = gr.newImage("images/jump.png")
   
   world:add(self, self.x, self.y, self.w, self.h)
end

function Player:update(dt)
   if self.speed ~= 0 then
      local dx = self.speed * dt

      if dx ~= 0 then
         dx = dx + self.x
         self.x, self.y = world:move(self, dx, self.y)
      end

      if dx < self.x then
         self.x = dx
         world:update(self, self.x, self.y)
         self.speed = 0
      elseif dx ~= self.x then
         self.speed = 0
      end
   end
   
   if not zero_ground then
      dy = self.y - self.velocity.y * dt
      self.x, self.y = world:move(self, self.x, dy)
      self.velocity.y = self.velocity.y - gravity * dt
      if self.y ~= dy then
         ground = true
      end
   end
end

function Player:draw()
   gr.setColor(255, 255, 255)
   if debug then
      gr.rectangle("line",
                   self.x, self.y,
                   self.w, self.h)
   end
   if ground then
      gr.draw(self.image,
              self.x, self.y)
   else
      gr.draw(self.jump,
              self.x, self.y)
   end
end

return Player
