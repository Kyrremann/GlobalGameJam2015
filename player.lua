local class = require "middleclass"

local Player = class('Player')

Player.static.JUMP = 1
Player.static.DUCK = 2
Player.static.UNDUCK = 3

local state = 'idle' -- player state
local rec = nil -- playback record
local playt = 0 -- time since playback started

function Player:initialize(name, x, y)
   self.name = name
   self.idle = gr.newImage("images/idle2.png")
   self.run = {
      gr.newImage("images/run1.png"),
      gr.newImage("images/run2.png"),
      gr.newImage("images/run2.png")
   }
   self.jump = gr.newImage("images/jump2.png")
   self.duckImage = gr.newImage("images/duck2.png")
   self.anim = {
      tile = 1,
      duration = .4,
      timer = 0
   }

   world:add(self, x, y, 10, 10)
   self:init(x, y)
end

function Player:init(x, y)
   self.x = x
   self.y = y
   self.w = self.idle:getWidth()
   self.h = self.idle:getHeight()
   self.speed = 0
   self.velocity = { x = 1, y = 0 }
   self.duck = false
   self.playing = false
   world:update(self, self.x, self.y, self.w, self.h)
end

-- standing on a winning tile?
function Player:wintile()
   local underme1 = world:queryPoint(
      self.x,
      self.y + self.h + 1
   )
   local underme2 = world:queryPoint(
      self.x + self.w,
      self.y + self.h + 1
   )

   for k, v in pairs(underme1) do
      if v.win then
         return true
      end
   end
   for k, v in pairs(underme2) do
      if v.win then
         return true
      end
   end
   return false
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
               if self:wintile() then
                  completedLevel('win')
               else
                  completedLevel('lost')
               end
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

      self.anim.timer = self.anim.timer + dt
      if self.anim.timer > self.anim.duration then
         self.anim.tile = self.anim.tile + 1
         self.anim.timer = 0
         if self.anim.tile > 2 then
            self.anim.tile = 1
         end
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
      print(self.h, self.duckImage:getHeight())
      self.h = self.duckImage:getHeight()
      gr.draw(self.duckImage,
              self.x, self.y)
   elseif not ground then
      self.h = self.jump:getHeight()
      gr.draw(self.jump,
              self.x, self.y)
   elseif self.speed > 0 then
      local temp = self.h
      self.h = self.run[self.anim.tile]:getHeight()
      local diff = self.h - temp
      self.y = self.y - diff
      world:update(self, self.x, self.y, self.w, self.h)
      gr.draw(self.run[self.anim.tile],
              self.x, self.y)
   else
      local temp = self.h
      self.h = self.idle:getHeight()
      local diff = self.h - temp
      self.y = self.y - diff
      world:update(self, self.x, self.y, self.w, self.h)
      gr.draw(self.idle,
              self.x, self.y)
   end
   world:update(self, self.x, self.y, self.w, self.h)
end

function Player:action(action)
   if Player.JUMP == action then
      if ground then
         self.velocity.y = jump_height
         ground = false
         au.play(soundJump)
      end
   elseif Player.DUCK == action then
      self.duck = true
   elseif Player.UNDUCK == action then
      self.duck = false
   end
end

-- play off the moves stored in record
function Player:playitoff(record)
   self.playing = true
   self.speed = 250
   rec = record
   playt = 0
   state = 'playing'
end

return Player
