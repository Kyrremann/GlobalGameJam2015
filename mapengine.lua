local class = require "middleclass"

local Engine = class('MapEngine')

function Engine:initialize(path)
   self.map = require(tostring(path))
   self.level = 1
   self.shapes = {}
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
               if debug then
                  gr.rectangle("line",
                               shape.x, shape.y,
                               shape.w, shape.h)
               end
               gr.draw(shape.image, shape.x, shape.y)
            end
         end
      end
   end
   drawFrame()
   gr.setColor(255, 255, 255)
   gr.setFont(amaticRegular64)
   gr.printf(cl.goal,
             0, 100, gr.getWidth(), "center")
end

function Engine:removeShapes()
   local cl = self.map[self.level]
   local m = cl.map
   
   for y=1, #m do
      for x=1, #m[y] do
	 gr.setColor(250, 250, 250)
         local shape = self.shapes[y][x]
         if shape then
            world:remove(shape)
         end
      end
   end   
end

function Engine:start(level)
   if self.shapes and #self.shapes > 0 then
      self:removeShapes()
   end
   self.shapes = {}
   self.level = level

   local cl = self.map[level]
   local m = cl.map

   for y, vy in ipairs(m) do
      self.shapes[y] = {}
      for x, vx in ipairs(vy) do
         if vx >= 1 then
            local shape = { 
               x = x * GRID_SIZE, y = y * GRID_SIZE, 
               w = GRID_SIZE, h = GRID_SIZE
            }

            if vx == 1 then
               shape.image = gr.newImage("images/grass.png")
            elseif vx == 3 then
               shape.image = gr.newImage("images/elementWood017.png")
            end
            
            self.shapes[y][x] = shape
            world:add(shape, shape.x, shape.y, shape.w, shape.h)
         end
      end
   end
end

return Engine
