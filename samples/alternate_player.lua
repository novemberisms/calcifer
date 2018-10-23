local Entity = import "entity"
local Animation = import "animation"

class { Player = Entity }

private {
	x = 0, y = 0;
	width = 32, height = 64;
	xvel = 0,	yvel = 0;
	animation;
}

static {
	spritesheet = love.graphics.newImage "assets/player_spritesheet.png";
}

public {
	new = function(x, y)
		self.x = x
		self.y = y
		animation = Animation(x, y, width, height, Player.spritesheet)
	end;

	setVelocity = function(xvel, yvel)
		self.xvel = xvel
		self.yvel = yvel
	end;

	getVelocity = function()
		return xvel, yvel
	end;
}