
local Entity = import "entity"
local Animation = import "animation"

class { Player = Entity }

	private { x = 0, y = 0 }
	private { width = 32, height = 64 }
	private { xvel = 0, yvel = 0 }
	private { animation }

	static { spritesheet = love.graphics.newImage("assets/player_spritesheet.png") }

	public { new = function(_x, _y) 
		x, y = _x, _y
		animation = Animation(x, y, width, height, Player.spritesheet)
	end }

	public { setVelocity = function(_xvel, _yvel) 
		xvel, yvel = _xvel, _yvel
	end }

	public { getVelocity = function() 
		return xvel, yvel
	end }



