gr = love.graphics
ke = love.keyboard

ti = love.timer
im = love.image
ev = love.event
so = love.sound
au = love.audio

tl = require 'timeline'
Player = require "player"
MapEngine = require "mapengine"
fw = require 'firework.FireworkEngine'()

require "math"

ke.setKeyRepeat(.01, .01)

debug = false
GRID_SIZE = 100
