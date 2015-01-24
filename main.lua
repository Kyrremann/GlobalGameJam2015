function love.load()
   require "setup"

   -- fonts
   amaticRegular64 = gr.newFont("fonts/AmaticSC-Regular.ttf", 64)
   amaticBold64 = gr.newFont("fonts/Amatic-Bold.ttf", 64)
   amaticBold128 = gr.newFont("fonts/Amatic-Bold.ttf", 128)

   -- sounds
   soundJump = au.newSource("sounds/jump.wav")

   local bump = require "bump"
   world = bump.newWorld(100)

   gravity = 1500
   jump_height = 600
   ground = false
   zero_ground = false

   Player = require "player"
   p = Player:new('Sjiraff', 100, 100)
   
   MENU = 0
   GAME = 1
   END = 2

   gameMode = MENU

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
      elseif (key == 'd' or key == 'right') and not isrepeat then
         if not p.playing then
            tl.startrecord()
         end
      elseif (key == 'w' or key == 'up') and not isrepeat then
         tl.event('jump')
      elseif (key == 's' or key == 'down') and not isrepeat then
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
      if key == 'd' or key == 'right' then
         if not p.playing then
            p:playitoff(tl.rec)
            tl.playback()
            tl.endrecord()
         end
      elseif key == 's' or key == 'down' then
         tl.event('unduck')
      elseif key == 'r' then
         resetLevel()
      end
   elseif gameMode == END then
   end
end

function drawBackground()
end

function drawTitle()
   gr.setColor(255, 255, 255)
   gr.setFont(amaticBold128)
   gr.printf("Some peoples",
             0, gr.getHeight() / 15, gr.getWidth(), "center")
   gr.setFont(amaticBold64)
   gr.printf("contribution to",
             0, gr.getHeight() / 3.7, gr.getWidth(), "center")
   gr.setFont(amaticBold128)
   gr.printf("Game Jam 2015",
             0, gr.getHeight() / 2.5, gr.getWidth(), "center")
   gr.setFont(amaticRegular64)
end

function resetLevel()
   ground = false
   zero_ground = false

   tl.reset()
   p:init(100, 100)
   mapengine:start(1)
end
