
local Animal = import "samples/animal"

class { Dog = Animal }

private_override { sound = "bark bark" }
public { legs = 4 }

public { new = function(name)
	super.new(name)
end }





