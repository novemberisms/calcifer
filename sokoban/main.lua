local Calcifer = require "../calcifer"
import = Calcifer.import
--=============================================================================
local Game = import "game"
local game = Game.getInstance()
--=============================================================================
function love.load()
	
end
--=============================================================================
function love.update(dt)
	game.update(dt)
end
--=============================================================================
function love.draw()
	game.draw()
end
--=============================================================================
function love.keypressed(key)
	game.keypressed(key)
end
--=============================================================================
