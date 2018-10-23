local Game = import "game"
local GameState = import "gamestate"
local FadeEffect = import "fade_effect"
local graphics = love.graphics

--=============================================================================
final_class { TitleState = GameState }

--=============================================================================
private { title_font }
private { menu_font }
private { title_y }
private { fade_effect }
--=============================================================================
public { new = function() 
	title_font = graphics.newFont(32)
	menu_font = graphics.newFont(16)
	title_y = graphics.getHeight() / 2 - 48
	fade_effect = FadeEffect()
end }

--=============================================================================
public_override { onEnter = function()
	graphics.setBackgroundColor(0, 0, 0)
end }

public_override { onExit = function() 

end }

--=============================================================================
public_override { update = function(dt) 
	if fade_effect.update(dt) then
		Game.getInstance().setState("play")
	end
end }

--=============================================================================
public_override { draw = function()
	graphics.setFont(title_font)
	graphics.printf("SOKOBAN", 0, title_y, graphics.getWidth(), "center")
	graphics.setFont(menu_font)
	graphics.printf("PRESS SPACE", 0, title_y + 48, graphics.getWidth(), "center")
	fade_effect.draw()
end }

--=============================================================================
public_override { keypressed = function(key)
	if key == "space" then 
		fade_effect.fadeOut(1.5, {0, 0, 0})
	elseif key == "escape" then
		love.event.quit()
	end
end }