require 'firework.class'
Firework=require 'firework.Firework'

local M=class(function(self)
  self.Fireworks={}
end)

function M:update(dt)
  for k=#self.Fireworks,1,-1 do
    local f=self.Fireworks[k]
    if f:isDead() then
      table.remove(self.Fireworks, k)
    else
      f:update(dt)
    end
  end
end

function M:draw()
  for k,v in ipairs(self.Fireworks) do
    v:draw()
  end
  love.graphics.setColor(255,255,255,255)
end

function M:addFirework(x, y)
  table.insert(self.Fireworks, Firework(x, y))
end

function M:clear()
   self.Fireworks = {}
end

return M

