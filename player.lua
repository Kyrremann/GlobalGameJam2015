local class = require "middleclass"

local Player = class('Player')

function Player:initialize(name, x, y, imagePath)
   self.name = name
   self.x = x
   self.y = y
   self.w = 82
   self.h = 150
   self.speed = 250
   self.velocity = { x = 0, y = 0 }
   self.image = gr.newImage(imagePath)
   
   world:add(self, self.x, self.y, self.w, self.h)
end

function Player:update(dt)
   local dx, dy = 0, 0
   if love.keyboard.isDown('right') then
      dx = self.speed * dt
   elseif love.keyboard.isDown('left') then
      dx = -self.speed * dt
   end

   if dx ~= 0 or dy ~= 0 then
      self.x, self.y = world:move(self, self.x + dx, self.y + dy)
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
   gr.draw(self.image,
           self.x, self.y)
end

return Player
