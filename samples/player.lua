
local Entity = import "entity"
local Animation = import "animation"

-- declare a new class Player that extends Entity
class { Player = Entity }

-- these properties are only accessible within this class or any subclass
private { x = 0, y = 0 }
private { width = 32, height = 64}
private { xvel = 0, yvel = 0 }
private { animation }

-- this is a static property that belongs to the Player class itself
static { spritesheet = love.graphics.newImage("assets/player_spritesheet.png") }

-- this is a public constructor
public { new = function(_x, _y) 
	x, y = _x, _y
	animation = Animation(x, y, width, height, Player.spritesheet)
end }

-- use explicit getters and setters for proper encapsulation of data
public { setVelocity = function(_xvel, _yvel) 
	xvel, yvel = _xvel, _yvel
end }





