local t = 0 -- time since start
local tl = {} -- timeline namespace

local dots = {} -- dots to draw
local dtloc = 0 -- how much time has passed
local ptime = nil -- playback time

local jumptimer = 0 -- jump timer (0 is grounded)
local state = 'running' -- player state
local maxtime = 12
local dotfreq = 0.025 -- dot draw frequency
local weight = 5 -- timeline weight
local margin = 50 -- margin to timeline dots

tl.start = nil -- start time
tl.rec = {} -- event record

local function timedt()
   return ti.getTime() - tl.start
end

-- Map t from range (a1, a2) into (b1, b2)
local function lmap(t, a1, a2, b1, b2)
   return b1 + (((t - a1) / (a2 - a1)) * (b2 - b1))
end

function tl.reset()
   dots = {}
   dtloc = 0
   ptime = nil
   jumptimer = 0
   state = 'running'
   tl.rec = {}
   tl.start = 0
end

function tl.startrecord()
   if debug then
      print('start recording')
   end
   tl.reset()
   tl.start = ti.getTime()
end

function tl.endrecord()
   table.insert(tl.rec, {at=timedt(), action='stop'})
   tl.start = nil
   if debug then
      print('end recording')
      for k, v in pairs(tl.rec) do
         print(k, v.at, v.action)
      end
   end
end

function tl.playback()
   ptime = 0
end

function tl.event(event)
   local JUMPDURATION = 0.6

   if tl.start and not (state == 'jumping') then
      if debug then
         print(event, ' at ', timedt())
      end
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

   -- we are in playback
   if ptime then
      ptime = ptime + dt
   end

   if tl.start then

      local OFFSET = 15

      if dtloc >= dotfreq then
         dtloc = dtloc - dotfreq

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

function drawdots(lim)
   for i=1,lim do
      gr.circle(
         'fill',
         lmap(dots[i].x, 0, maxtime, margin, gr.getWidth() - margin),
         margin + dots[i].y,
         weight
      )
      gr.line(
         lmap(dots[i].x, 0, maxtime, margin, gr.getWidth() - margin),
         margin + dots[i].y,
         lmap(dots[i+1].x, 0, maxtime, margin, gr.getWidth() - margin),
         margin + dots[i+1].y
      )
   end
end

function drawhelpers()
   gr.setColor(90, 90, 90)

   for x=margin,gr.getWidth() - margin,100 do
      gr.line(x, margin - 10, x, margin + 10)
   end
end

function tl.draw()
   drawhelpers()

   gr.setColor(255, 255, 255)
   gr.setLineWidth(weight * 2)

   drawdots(#dots-1)

   if ptime then
      gr.setColor(255, 0, 0)
      drawdots(math.min(#dots-1, math.floor(ptime / dotfreq)))
   end
end

return tl
