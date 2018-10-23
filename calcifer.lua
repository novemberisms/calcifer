local Calcifer = {}
local Calcifer_mt = {}
local class_mt = {}

setmetatable(Calcifer, Calcifer_mt)

local UNDEFINED = {}
local VIRTUAL = {}

local CLASS_MEMO = {}

local extend_class
--=============================================================================
-- DEFINING A NEW CLASS
--=============================================================================

-- classes are written in a lua module and then required with Calcifer.import "path/to/classfile"
function Calcifer_mt:__call(path_to_class)
	-- classes are memoized by path
	if CLASS_MEMO[path_to_class] then
		return CLASS_MEMO[path_to_class]
	end
	-- this is the new created class itself
	local class = setmetatable({
		__name = "", -- needs a name
		__static = {}, -- static fields on the class object itself
		__private = {}, -- fields only accessible from within the class or a subclass (like in Haxe. no support for protected keyword)
		__public = {}, -- fields visible from anywhere
		__parent = UNDEFINED, -- handle to the parent class
		__subclasses = {}, -- array of subclasses. this is mainly here for easy reflection / debugging of user code. this library doesn't use this field but it's nice to have
		__final = false, -- a class tagged as final cannot be extended
		__abstract = false, -- a class tagged as abstract cannot be instantiated
	}, class_mt)

	-- memoize so that subsequent calls to Calcifer "path/to/class"
	-- will return the exact same table created here
	CLASS_MEMO[path_to_class] = class

	-- this is the environment for the required class file
	-- it has a special anonymous metatable
	local require_environment = setmetatable({}, {
		-- global lookups inside the required file will reroute here
		__index = function(t, k)
			-- for stuff like ipairs and string
			if rawget(_G, k) then return rawget(_G, k) end
			-- defining a class
			if k == "class" or k == "final_class" or k == "abstract_class" then
				-- class "Greeter" or
				-- class {Greeter} will work
				return function(class_dec)
					if class.__name ~= "" then
						error("Only one class allowed per file. Sorry", 2)
					end
					-- this only works because of the line at the end `return k`
						-- any unidentified token in the module is rerouted to this __index lookup
						-- because of setfenv
					if type(class_dec) == "table" then
						-- either of the form class {Object}
						if class_dec[1] then
							class.__name = class_dec[1]
						-- of the form class {Child = Parent}
						else
							local class_name, parent = next(class_dec)
							class.__name = class_name
							-- extend the class
							extend_class(class, parent)
						end
					else
						-- class "Object"
						local class_name = t[class_dec]
						class.__name = class_name
					end
					if k == "final_class" then class.__final = true end
					if k == "abstract_class" then class.__abstract = true end
				end
			-- private fields only accessible from within that class or descendants
			elseif k == "private" then
				-- why return a function? well how else would you make it such that writing
				-- private {x = 1}
				-- can be valid lua code in the required file?
				-- here, 'a' is the table {x = 1}
				return function(a)
					-- private {some_var_with_no_initial_value}
					if a[1] then
						-- this only works because of the line at the end `return k`
						local varname = a[1]
						if varname == "new" then error("Must provide a constructor implementation", 2) end
						if class.__private[varname] ~= nil or class.__public[varname] ~= nil then	
							error("Cannot redefine field '" .. varname .. "' as it is already defined here or in a parent. Use private_override {}", 2)
						end
						class.__private[varname] = UNDEFINED
						return
					end
					-- private {a = 1, b = 2}
					for k, v in pairs(a) do
						if class.__private[k] ~= nil or class.__public[k] ~= nil then
							if k ~= "new" then
								error("Cannot redefine field '" .. k .. "' as it is already defined here or in a parent. Use private_override {}", 2)
							end
						end
						class.__private[k] = v
					end
				end
			-- public fields available outside
			elseif k == "public" then
				return function(a)
					-- public {some_var_with_no_initial_value}
					if a[1] then
						-- this only works because of the line at the end `return k`
						local varname = a[1] 
						if varname == "new" then error("Must provide a constructor implementation", 2) end
						if class.__private[varname] ~= nil or class.__public[varname] ~= nil then
							error("Cannot redefine field '" .. varname .. "' as it is already defined here or in a parent. Use public_override {}", 2)
						end
						class.__public[varname] = UNDEFINED                
						return                                                     
					end
					-- public {a = 1, b = 2}
					for k, v in pairs(a) do
						if class.__private[k] ~= nil or class.__public[k] ~= nil then
							if k ~= "new" then
								error("Cannot redefine field '" .. k .. "' as it is already defined here or in a parent. Use public_override {}", 2)
							end
						end
						class.__public[k] = v
					end
				end
			-- fields only available to the capital C Class itself
			elseif k == "static" then
				return function(a)
					if a[1] then
						local varname = a[1]
						class.__static[varname] = UNDEFINED
						-- error("Must provide an initial value for static field: " .. a[1], 2)
					end
					for k, v in pairs(a) do
						class.__static[k] = v
					end
				end
			-- overriding a public field that already exists in a parent
			elseif k == "public_override" then
				return function(a)
					-- of the case public_override {uninitialized}
					if a[1] then
						local varname = a[1]
						-- you do not need to specify overriding new ( and you can't uninitialize new anyways )
						if varname == "new" then error("No need to use override for constructor (this is a special case)", 2) end
						-- are you accidentally overriding a private field as public?
						if class.__private[varname] ~= nil then
							-- you can override a private field as public
							class.__public[varname] = UNDEFINED
							class.__private[varname] = nil
						end
						-- does it even exist?
						if class.__public[varname] == nil then
							error("Trying to override field " .. varname .. " that does not exist in a superclass", 2)
						end
						class.__public[varname] = UNDEFINED
						return
					end
					-- of the case public_override {a = 1, b = 2}
					for k, v in pairs(a) do
						-- you do not need to specify overriding new
						if k == "new" then error("No need to use override for constructor (this is a special case)", 2) end
						-- are you accidentally overriding a private field as public?
						if class.__private[k] ~= nil then
							-- you can override a private field as public
							class.__public[k] = v
							class.__private[k] = nil
						end
						-- does it even exist?
						if class.__public[k] == nil then
							error("Trying to override field " .. k .. " that does not exist in a superclass", 2)
						end
						class.__public[k] = v
					end

				end
			-- overriding a private field that already exists in a parent
			elseif k == "private_override" then
				return function(a)
					-- of the case private_override {uninitialized}
					if a[1] then
						local varname = a[1]
						-- you do not need to specify overriding new ( and you can't uninitialize new anyways )
						if varname == "new" then error("No need to use override for constructor (this is a special case)", 2) end
						-- are you accidentally overriding a public field as private?
						if class.__public[varname] ~= nil then
							error("Cannot override a public field as private [" .. varname .. "]", 2)
						end
						-- does it even exist?
						if class.__private[varname] == nil then
							error("Trying to override field " .. varname .. " that does not exist in a superclass", 2)
						end
						class.__private[varname] = UNDEFINED
						return
					end
					-- of the case private_override {a = 1, b = 2}
					for k, v in pairs(a) do
						-- you do not need to specify overriding new
						if k == "new" then error("No need to use override for constructor (this is a special case)", 2) end
						-- are you accidentally overriding a public field as private?
						if class.__public[k] ~= nil then
							error("Cannot override a public field as private [" .. k .. "]", 2)
						end
						-- does it even exist?
						if class.__private[k] == nil then
							error("Trying to override field " .. k .. " that does not exist in a superclass", 2)
						end
						class.__private[k] = v
					end

				end
			elseif k == "public_abstract" then
				if not class.__abstract then
					error("Abstract fields can only exist on abstract classes. Use abstract_class instead of class", 2)
				end
				return function(a)
					-- must not have an implementaion
					if not a[1] then
						error("Abstract fields must not have an implementation", 2)
					end
					local varname = a[1]
					-- abstract fields cannot override
					if class.__public[varname] ~= nil or class.__private[varname] ~= nil then
						error("Cannot make field '" .. varname .. "' abstract as it is already defined here or in a superclass", 2)
					end
					-- mark it as a special VIRTUAL value
					class.__public[varname] = VIRTUAL
				end
			elseif k == "private_abstract" then
				if not class.__abstract then
					error("Abstract fields can only exist on abstract classes. Use abstract_class instead of class", 2)
				end
				return function(a)
					-- must not have an implementaion
					if not a[1] then
						error("Abstract fields must not have an implementation", 2)
					end
					local varname = a[1]
					-- abstract fields cannot override
					if class.__public[varname] ~= nil or class.__private[varname] ~= nil then
						error("Cannot make field '" .. varname .. "' abstract as it is already defined here or in a superclass", 2)
					end
					-- mark it as a special VIRTUAL value
					class.__private[varname] = VIRTUAL
				end
			elseif k == "interface" then
				return function(interface_name)
					print("declaring interface " .. interface_name)
					return function(t)
						for k, v in pairs(t) do
							print(k, v)
						end
					end
				end
			end

			return k -- return the key as a string
		end, -- end of __index function

		-- when within the required class file, toplevel code like 'hi = 123' will not work
		-- but you can still use toplevel local vars like 'local hi = 123' 
		__newindex = function(class, k, v)
			error("Use [private | public | static] {" .. k .. " = " .. tostring(v) .. "} to declare", 2)
		end
	})
	setfenv(0, require_environment)
	require(path_to_class)
	setfenv(0, _G)

	-- checking for errors

	-- if we forgot to give the class a name
	if class.__name == "" then
		error(
			"Class in path '" .. path_to_class .. "' needs a name!\n" ..
			"write 'class \"ClassName\"' or 'class { ClassName }' in the beginning of the file", 2
		)
	end

	-- if the class is not abstract and we forgot to override and virtual inherited fields
	if not class.__abstract then
		for varname, value in pairs(class.__public) do
			if value == VIRTUAL then
				error("You forgot to override the virtual field '" .. varname .. "' on " .. class.__name)
			end
		end
		for varname, value in pairs(class.__private) do
			if value == VIRTUAL then
				error("You forgot to override the virtual field '" .. varname .. "' on " .. class.__name)
			end
		end
	end

	-- all good
	return class
end
--=============================================================================
-- ACCESSING AND SETTING STATIC MEMBERS
--=============================================================================
-- when the class itself is indexed, like MyClass.mystaticfield

function class_mt.__index(class, k)
	if class.__static[k] ~= nil then
		-- if invoking a static function, we need to modify the environment so
		-- global calls will defer to static properties or methods
		-- while still allowing direct access to _G
		if type(class.__static[k]) == "function" then
			local env = setmetatable({}, {
				__index = function(env, k)
					-- this is used so that you can access a private constructor from a static function
					if k == "__is_static_env" then return true end
					-- so that you can reference the class itself from within a static function
					if k == class.__name then return class end
					-- so that you can use global stuff as well
					if _G[k] then return _G[k] end
					-- default to the class_mt __index. this will error if no static member can be found
					return class[k]
				end,
				__newindex = class_mt.__newindex
			})
			return setfenv(class.__static[k], env)
		end
		-- if it was not defined
		if class.__static[k] == UNDEFINED then
			return nil
		end
		-- else, we're just getting a static member
		return class.__static[k]
	end
	error("No static field called '" .. k .. "' on " .. class.__name, 2)
end

function class_mt.__newindex(class, k, v)
	if class.__static[k] ~= nil then
		class.__static[k] = v
		return
	end
	error("No static field called '" .. k .. "' on " .. class.__name, 2)
end
--=============================================================================
-- EXTENDING A CLASS
--=============================================================================

-- extend_class is a previously declared local variable now defined as function
function extend_class(class, parent)
	if parent.__final then 
		error(class.__name .. " cannot extend " .. parent.__name .. " because it is declared final", 3)
	end
	class.__parent = parent
	table.insert(parent.__subclasses, class)

	-- insert all private and public fields into the class

	for k, v in pairs(parent.__private) do
		class.__private[k] = v
	end

	for k, v in pairs(parent.__public) do
		class.__public[k] = v
	end

end


--=============================================================================
-- INSTANTIATING A CLASS
--=============================================================================

local function inst_method_call(fn, inst, previous_mt, internal_mt)
	return function(...)
		local oldfenv = getfenv(fn)
		-- change the metatable so that we can access private methods now
		setmetatable(inst, internal_mt)
		-- set the fenv to the instance, so any global lookups will go through the __index metamethod of internal_mt
		setfenv(fn, inst)
		local a, b, c, d, e, f = fn(...)
		setfenv(fn, oldfenv)
		setmetatable(inst, previous_mt)
		return a, b, c, d, e, f -- i wonder if there's a better way to do this. there has to be, right?
	end
end

-- create new instance
function class_mt.__call(class, ...)
	if class.__abstract then
		error("Cannot instantiate abstract class " .. class.__name, 2)
	end
	local inst_mt, internal_inst_mt
	-- metatable used when instance is being indexed or newindexed externally
	inst_mt = {
		__public = {},
		__private = {},
		__class = class,
		__internal_mt = nil, -- to be assigned shortly
	}
	inst_mt.__index = function(inst, k)
		-- cannot access instance.self or instance.super externally
		if class.__public[k] ~= nil then 
			-- if it's a function, we need to modify the fenv so that global lookups will refer to the instance vars
			if type(inst_mt.__public[k]) == "function" then
				return inst_method_call(inst_mt.__public[k], inst, inst_mt, internal_inst_mt)
			end
			-- else just return it
			return inst_mt.__public[k]
		elseif class.__private[k] ~= nil then
			-- cannot access private fields externally
			error("Cannot get private field '" .. k .. "' of instance " .. class.__name, 2)
		end

		error("No field called '" .. k .. "' in instance " .. class.__name, 2)
	end
	inst_mt.__newindex = function(inst, k, v)
		if class.__public[k] ~= nil then
			-- I don't know how this behaves when you assign a function?
			inst_mt.__public[k] = v
			return
		elseif class.__private[k] ~= nil then
			error("Cannot set private field '" .. k .. "' of instance " .. class.__name, 2)
		end
		error("No field called '" .. k .. "' in instance " .. class.__name, 2)
	end

	-- the metatable used for functions within the instance 
	internal_inst_mt = {}
	inst_mt.__internal_mt = internal_inst_mt
	internal_inst_mt.__index = function(inst, k)
		if k == "self" then
			return inst
		end
		if k == "super" then
			-- super.new(bla)
			-- [self].super is an anonymous table that redirects any indexes
			-- to the private or public methods of the parent class
			return setmetatable({}, {
				-- any calls like super.field will activate
				-- the __index of the metatable of this anonymous table
				__index = function(_, field)
					local p = class.__parent
					local super_f 
					if p.__private[field] ~= nil then
						super_f = p.__private[field] 
					elseif p.__public[field] ~= nil then
						super_f = p.__public[field]
					end
					if super_f == nil then error("No field called " .. field .. " defined on super for " .. class.__name) end
					if type(super_f) == "function" then
						-- note that we use two internal_inst_mt's here
						-- because when the super function is done, we do not want
						-- the fenv to be the external inst_mt, but rather still the internal one
						-- since super.new() is commonly called in the beginning of inside an internal function
						return inst_method_call(super_f, inst, internal_inst_mt, internal_inst_mt)
					end
					if super_f == UNDEFINED then return nil end
					return super_f
				end
			})
		end
		if k == class.__name then
			return class
		end
		if class.__public[k] ~= nil then
			-- same as in inst_mt for functions. still need to modify the environment
			if type(inst_mt.__public[k]) == "function" then
				return inst_method_call(inst_mt.__public[k], inst, internal_inst_mt, internal_inst_mt)
			end
			return inst_mt.__public[k]
		elseif class.__private[k] ~= nil then
			-- the difference between internal and external is that we can access and modify private stuff
			if type(inst_mt.__private[k]) == "function" then
				return inst_method_call(inst_mt.__private[k], inst, internal_inst_mt, internal_inst_mt)
			end
			return inst_mt.__private[k]
		-- this allows us to use 'string', 'math', or 'ipairs' in the instance methods
		elseif rawget(_G, k) ~= nil then
			return rawget(_G, k)
		-- if not a global or a field, then error!
		else
			error("No field called " .. k .. " in instance " .. class.__name, 2)
		end
	end
	internal_inst_mt.__newindex = function(inst, k, v)
		-- allow both public and private access
		if class.__public[k] ~= nil then
			inst_mt.__public[k] = v
			return
		elseif class.__private[k] ~= nil then
			inst_mt.__private[k] = v
			return
		end
		-- cannot create dynamic fields!
		-- cannot set global variables!
		error("No field called " .. k .. " in instance " .. class.__name, 2)
	end

	local inst = setmetatable({}, inst_mt)
	-- inject default initial values
	for k, v in pairs(class.__public) do
		-- check if UNDEFINED, and so, inject nil
		if v == UNDEFINED then v = nil end
		inst_mt.__public[k] = v
	end
	for k, v in pairs(class.__private) do
		if v == UNDEFINED then v = nil end
		inst_mt.__private[k] = v
	end

	if class.__public.new then
		local constructor = class.__public.new
		inst_method_call(constructor, inst, inst_mt, internal_inst_mt)(...)
	elseif class.__private.new then
		-- special exception in the case that we're calling a private constructor from a static method on the
		-- same class
		if getfenv(2).__is_static_env then
			local constructor = class.__private.new
			inst_method_call(constructor, inst, inst_mt, internal_inst_mt)(...)
		else
			error("Cannot instantiate " .. class.__name .. " because its constructor is private", 2)
		end
	else
		error("Cannot instantiate " .. class.__name .. " because it does not have a public constructor", 2)
	end

	return inst
end
--=============================================================================
-- LIBRARY FUNCTIONS
--=============================================================================
function Calcifer.getClass(instance)
	return getmetatable(instance).__class
end

function Calcifer.is(instance, class)
	local current = Calcifer.getClass(instance)
	repeat
		if current == class then return true end
		current = current.__parent
	until current == UNDEFINED
	return false
end

function Calcifer.import(path)
	return Calcifer(path)
end

--=============================================================================
-- DEBUG FUNCTIONS
-- TODO: TEST THESE
--=============================================================================
-- accesses a private member from anywhere. use this for unit testing private functions
-- or for debugging
function Calcifer.getPrivateMember(inst, fieldname)
	local val = getmetatable(inst).__private[fieldname]
	if type(val) == "function" then
		error("Use Calcifer.callPrivateMethod(instance, methodname) to call methods", 2)
	end
	return val
end

-- calls an instance's private method.
function Calcifer.callPrivateMethod(inst, methodname, ...)
	local inst_mt = getmetatable(inst)
	local fn = inst_mt.__private[methodname]
	if type(fn) ~= "function" then
		error(inst .. "." .. methodname .. " is not a private method", 2)
	end
	return inst_method_call(fn, inst, inst_mt, inst_mt.__internal_mt)(...)
end
--=============================================================================
return Calcifer