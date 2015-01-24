function love.load()
   require "setup"

   local bump = require "bump"
   world = bump.newWorld(100)

   gravity = 400
   jump_height = 300
   ground = false
   zero_ground = false

   Player = require "player"
   p = Player:new('Sjiraff', 100, 100, "images/idle.png")
   
   MENU = 0
   GAME = 1
   END = 2

   gameMode = GAME

   MapEngine = require "mapengine"
   mapengine = MapEngine:new("levels")
   mapengine:start(1)
end

function love.update(dt)
   if gameMode == MENU then
   elseif gameMode == GAME then
      mapengine:update(dt)
      p:update(dt)
      tl.update(dt)
   elseif gameMode == END then
   end
end

function love.draw()
   drawBackground()
   if gameMode == MENU then
      drawTitle()
   elseif gameMode == GAME then
      mapengine:draw()
      p:draw()
      tl.draw()
   elseif gameMode == END then
   end
end

function love.keypressed(key, isrepeat)
   if gameMode == MENU then
      if key == "escape" then
         love.event.push('quit')
         return
      elseif key == "return" then
         gameMode = GAME
         return
      elseif key == 'f9' then
         debug = not debug
         return
      end

   elseif gameMode == GAME then
      if key == "escape" then
         gameMode = END
         return
      elseif key == 'f9' then
         debug = not debug
         return
      elseif key == " " then
         p:action(Player.JUMP)
      elseif key == "down" then
         p:action(Player.DUCK)
      elseif key == 'd' and not isrepeat then
         tl.startrecord()
      elseif key == 'w' and not isrepeat then
         tl.event('jump')
      elseif key == 's' and not isrepeat then
         tl.event('duck')
      end

   elseif gameMode == END then
      if key == "escape" then
         gameMode = MENU
      elseif key == 'return' then
         gameMode = MENU
      end
   end
end

function love.keyreleased(key)
   if gameMode == MENU then
   elseif gameMode == GAME then
      if key == 'd' then
         tl.endrecord()
      elseif key == 'down' then
         p.duck = false
      elseif key == 's' then
         tl.event('unduck')
      end
   elseif gameMode == END then
   end
end

function drawBackground()
end

function drawTitle()
   gr.printf("Game Jam 2015",
             0, gr.getHeight() / 10, gr.getWidth(), "center")
end
