local t = 0 -- time since start
local tl = {} -- timeline namespace

local dots = {} -- dots to draw
local start = nil -- start time
local dtloc = 0 -- how much time has passed

local jumptimer = 0 -- jump timer (0 is grounded)
local state = 'running' -- player state
local maxtime = 12

tl.rec = {} -- event record

local function timedt()
   return ti.getTime() - start
end

-- Map t from range (a1, a2) into (b1, b2)
local function lmap(t, a1, a2, b1, b2)
   return b1 + (((t - a1) / (a2 - a1)) * (b2 - b1))
end

function tl.startrecord()
   print('start recording')
   start = ti.getTime()
end

function tl.reset()
   dots = {}
   dtloc = 0
   jumptimer = 0
   state = 'running'
end

function tl.endrecord()
   print('end recording')
   table.insert(tl.rec, {at=timedt(), action='stop'})
   for k, v in pairs(tl.rec) do
      print(k, v.at, v.action)
   end
   start = nil
end

function tl.event(event)
   local JUMPDURATION = 0.3

   if start and not (state == 'jumping') then
      print(event, ' at ', timedt())
      table.insert(tl.rec, {at=timedt(), action=event})

      if event == 'duck' then
         state = 'ducking'
      elseif event == 'unduck' then
         state = 'running'
      elseif event == 'jump' then
         state = 'jumping'
         jumptimer = JUMPDURATION
      end
   end
end

function tl.update(dt)
   t = t + dt
   dtloc = dtloc + dt

   -- we are airborne
   if not (jumptimer == 0) then
      jumptimer = jumptimer - dt

      if jumptimer < 0 then
         jumptimer = 0
         state = 'running'
      end
   end

   if start then
      local FREQ = 0.025
      local OFFSET = 15

      if dtloc >= FREQ then
         dtloc = dtloc - FREQ

         local dot = {x=timedt(),y=0}

         if state == 'ducking' then
            dot.y = OFFSET
         elseif state == 'jumping' then
            dot.y = -OFFSET
         end

         table.insert(dots, dot)
      end

      -- time is up
      if timedt() >= maxtime then
         tl.endrecord()
      end
   end
end

function tl.draw()
   local OFFSET = 50
   local WEIGHT = 5

   gr.setLineWidth(WEIGHT * 2)

   for i=1,#dots-1 do
      gr.circle(
         'fill',
         lmap(dots[i].x, 0, maxtime, OFFSET, gr.getWidth() - OFFSET),
         OFFSET + dots[i].y,
         WEIGHT
      )
      gr.line(
         lmap(dots[i].x, 0, maxtime, OFFSET, gr.getWidth() - OFFSET),
         OFFSET + dots[i].y,
         lmap(dots[i+1].x, 0, maxtime, OFFSET, gr.getWidth() - OFFSET),
         OFFSET + dots[i+1].y
      )
   end
end

return tl
