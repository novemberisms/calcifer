local TitleState = import "sokoban/titlestate"
local PlayState = import "sokoban/playstate"
--=============================================================================
final_class "Game"
--=============================================================================
-- using the singleton pattern to ensure there is only one game instance
static { instance }
static { getInstance = function()
	if instance then return instance end
	instance = Game()
	return instance
end }

--=============================================================================
-- the current state of the game
private { state_object }
-- map of state names to the state objects
private { state_map = {} }
-- the name of the current state
private { state_name }


--=============================================================================
-- a private function so we can't directly instantiate it unless we use getInstance
private { new = function()
	state_map = {
		titlescreen = TitleState(),
		play = PlayState(),
	}
	setState("titlescreen")
end }


--=============================================================================
-- public callback functions
public { update = function(dt)
	state_object.update(dt)
end }

public { draw = function() 
	state_object.draw()
end }

public { keypressed = function(key)
	state_object.keypressed(key)
end }

--=============================================================================
-- getters and setters
public { getStateName = function() return state_name end }
public { getState = function() return state_object end }

public { setState = function(new_state_name)
	local new_state = state_map[new_state_name]
	if not new_state then
		error("Invalid state name " .. new_state_name, 2)
	end
	local old_state_name = state_name or ""
	-- if we have an existing state, call onExit
	if state_object then
		state_object.onExit(new_state_name)
	end
	-- set the new state object and name
	state_name = new_state_name
	state_object = new_state
	-- call onEnter with the old state name
	new_state.onEnter(old_state_name)
end }

