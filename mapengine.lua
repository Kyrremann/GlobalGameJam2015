local class = require "middleclass"

local Engine = class('MapEngine')

function Engine:initialize(path)
   self.map = require(tostring(path))
   self.level = 1
   self.shapes = {}
   self.camera = {
      x = 0,
      y = 0
   }
end

local function drawFrame()
   gr.setColor(40, 40, 40)
   gr.rectangle('fill',
                0, 0,
                GRID_SIZE, gr.getHeight())
   gr.rectangle('fill',
                0, 0,
                gr.getWidth(), GRID_SIZE)
   gr.rectangle('fill',
                0, gr.getHeight() - GRID_SIZE,
                gr.getWidth(), GRID_SIZE)
   gr.rectangle('fill',
                gr.getWidth() - GRID_SIZE, 0,
                GRID_SIZE, gr.getHeight())
end

function Engine:update(dt)
   if p.x > gr.getWidth() / 2 then
      p.x = gr.getWidth() / 2

      local cl = self.map[self.level]
      local m = cl.map
      
      for y=1, #m do
         for x=1, #m[y] do
            local shape = self.shapes[y][x]
            if shape then
               shape.x = shape.x - p.speed * dt
               world:update(shape, shape.x, shape.y)
            end
         end
      end
   end
end

function Engine:draw()
   gr.setLineWidth(1)
   local cl = self.map[self.level]
   local m = cl.map
   
   for y=1, #m do
      for x=1, #m[y] do
	 gr.setColor(250, 250, 250)
         local shape = self.shapes[y][x]
         if shape then
            if shape.x > gr.getWidth() then break end
            if shape.x > 0 then
               gr.rectangle("line",
                            shape.x, shape.y,
                            shape.w, shape.h)
            end
         end
      end
   end
   drawFrame()
end

function Engine:start(level)
   local cl = self.map[level]
   local m = cl.map
   self.shapes = {}

   for y, vy in ipairs(m) do
      self.shapes[y] = {}
      for x, vx in ipairs(vy) do
         if vx == 1 then
            local shape = { 
               x = x * GRID_SIZE, y = y * GRID_SIZE, 
               w = GRID_SIZE, h = GRID_SIZE
            }
            self.shapes[y][x] = shape
            world:add(shape, shape.x, shape.y, shape.w, shape.h)
         end
      end
   end
end

return Engine
