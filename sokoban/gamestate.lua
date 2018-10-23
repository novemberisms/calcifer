-- abstract classes cannot be instantiated,
-- but they can be extended.
abstract_class { GameState }
--=============================================================================
public { onEnter = function(previous_state_name) end }
public { onExit = function(next_state_name) end }
public { update = function(dt) end }
public { draw = function() end }
public { keypressed = function(key) end }
