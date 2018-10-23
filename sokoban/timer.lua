final_class { Timer }
--=============================================================================
private { time = 0 }
private { mode = "oneshot" }

--=============================================================================
public { period = 1 }
public { running = true }

--=============================================================================
public { new = function(period, mode) 
	self.period = period or self.period
	self.mode = mode or self.mode
end }

--=============================================================================
public { start = function(new_period) 
	period = new_period or period
	running = true
end }

--=============================================================================
public { update = function(dt) 
	local has_timed_out = false
	if not running then return has_timed_out end
	time = time + dt
	if time > period then
		has_timed_out = true
		if mode == "oneshot" then
			running = false
		elseif mode == "periodic" then
			time = 0
		end
	end
	return has_timed_out
end }

--=============================================================================
public { getCompletion = function() 
	return math.min(1, time / period)
end }

public { getRemaining = function()
	return 1 - getCompletion()
end }