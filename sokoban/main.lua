local Calcifer = require "../calcifer"
import = Calcifer.import
local game
--=============================================================================
function love.load()
	local Game = import "game"
	game = Game.getInstance()
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
