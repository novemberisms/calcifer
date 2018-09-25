
local Animal = import "samples/animal"

class { Dog = Animal }

public { new = function(name)
	super.new(name)
	sound = "Bark bark!"
end }





