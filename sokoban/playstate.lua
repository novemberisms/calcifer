local GameState = import "sokoban/gamestate"
local FadeEffect = import "sokoban/fade_effect"
local graphics = love.graphics

--=============================================================================
final_class { PlayState = GameState }

--=============================================================================
private { fade_effect }
private { level_number = 1 }
--=============================================================================
public { new = function() 
	fade_effect = FadeEffect()
end }

--=============================================================================
public_override { onEnter = function()
	graphics.setBackgroundColor(0.9, 0.9, 1)
	fade_effect.fadeIn(1.5, {0, 0, 0})
end }

public_override { onExit = function() 

end }

--=============================================================================
public_override { update = function(dt) 
	if fade_effect.isOngoing() then
		fade_effect.update(dt)
		return
	end
end }

--=============================================================================
public_override { draw = function()
	if fade_effect.isOngoing() then
		fade_effect.draw()
	end
end }

--=============================================================================
public_override { keypressed = function(key) 
	if key == "escape" then 
		love.event.quit() 
	end
end }