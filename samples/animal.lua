
class { Animal }

public { name }
private { sound }

public { new = function(new_name)
	-- this works fine because we've declared that 
	-- Animal has a field called 'name'
	name = new_name
	-- simulating a typo
	sound = "Generic Animal Sound"
end }

public { playSound = function() print(sound) end }
