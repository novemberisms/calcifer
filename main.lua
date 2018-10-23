local Calcifer = require "calcifer"
import = Calcifer.import

local Animal = import "samples/animal"
local a = Animal("george")
a.playSound()
