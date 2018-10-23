local Timer = import "sokoban/timer"
local graphics = love.graphics

--=============================================================================
final_class "FadeEffect"
--=============================================================================
	private { active = false }
	private { mode = "fade_out" }
	private { color = {1, 1, 1} }
	private { timer }

--=============================================================================
	public { new = function() 
		timer = Timer(1, "oneshot")
	end }
--=============================================================================
	public { update = function(dt)
		if not active then return false end
		return timer.update(dt)
	end }

--=============================================================================
	public { draw = function()
		if not active then return end
		local r, g, b = unpack(color)
		local a
		if mode == "fade_out" then
			a = timer.getCompletion()
		elseif mode == "fade_in" then
			a = timer.getRemaining()
		end
		graphics.setColor(r, g, b, a)
		graphics.rectangle("fill", 0, 0, graphics.getDimensions())
		graphics.setColor(1, 1, 1, 1)
	end }

--=============================================================================
	public { isOngoing = function()	return active end }

	public { fadeOut = function(time, color)
		activate(time, color, "fade_out")
	end }

	public { fadeIn = function(time, color)
		activate(time, color, "fade_in")
	end }

	private { activate = function(time, _color, _mode)
		active = true
		mode = _mode
		color = _color
		timer.start(time)
	end }