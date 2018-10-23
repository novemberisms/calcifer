
class { Animal }

public { name }
private { sound = "Generic Animal Sound" }

public { 
	new = function(name)
		self.name = name
	end;

	playSound = function() 
		print(sound) 
	end 
}

-- public_abstract { legs }