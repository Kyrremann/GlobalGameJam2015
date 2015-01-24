local class = require "middleclass"

local Player = class('Player')

Player.static.JUMP = 1
Player.static.DUCK = 2
Player.static.UNDUCK = 3

local state = 'idle' -- player state
local rec = nil -- playback record
local playt = 0 -- time since playback started

function Player:initialize(name, x, y, imagePath)
   self.name = name
   self.image = gr.newImage("images/idle.png")
   self.jump = gr.newImage("images/jump.png")
   self.duckImage = gr.newImage("images/duck.png")
   self.x = x
   self.y = y
   self.w = self.image:getWidth()
   self.h = self.image:getHeight()
   self.speed = 0
   self.velocity = { x = 1, y = 0 }
   self.duck = false
   
   world:add(self, self.x, self.y, self.w, self.h)
end

function Player:update(dt)
   if state == 'playing' then
      playt = playt + dt

      if #rec > 0 then
         local event = rec[1]

         if event.at <= playt then
            if event.action == 'jump' then
               self:action(Player.JUMP)
            elseif event.action == 'duck' then
               self:action(Player.DUCK)
            elseif event.action == 'unduck' then
               self:action(Player.UNDUCK)
            elseif event.action == 'stop' then
               self.speed = 0
               state = 'idle'
            end

            table.remove(rec, 1)
         end
      end
   end

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

   if self.duck then
      self.w = self.image:getWidth()
      self.h = self.duckImage:getHeight()
      gr.draw(self.duckImage,
              self.x, self.y)
   elseif not ground then
      self.w = self.jump:getWidth()
      self.h = self.jump:getHeight()
      gr.draw(self.jump,
              self.x, self.y)
   else
      self.w = self.image:getWidth()
      self.h = self.image:getHeight()
      world:update(self, self.x, self.y, self.w, self.h)
      gr.draw(self.image,
              self.x, self.y)
   end
   world:update(self, self.x, self.y, self.w, self.h)
end

function Player:action(action)
   if Player.JUMP == action then
      if ground then
         self.velocity.y = jump_height
         ground = false
      end
   elseif Player.DUCK == action then
      self.duck = true
   elseif Player.UNDUCK == action then
      self.duck = false
   end
end

-- play off the moves stored in record
function Player:playitoff(record)
   self.speed = 250
   rec = record
   playt = 0
   state = 'playing'
end

return Player
