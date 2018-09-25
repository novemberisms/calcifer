local Calcifer = require "calcifer"
import = Calcifer.import

local Dog = import "samples/dog"
local d = Dog("Spot")

d.playSound()

-- require "sokoban/sokoban_main"