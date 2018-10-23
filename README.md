# Calcifer

*An OOP library for lua with proper information hiding that lets you write lua as if it were an Object-Oriented language like Java, C#, or Haxe*

Come take a look!

![](assets/playersample.png)

That's all vanilla lua.

## No more accidental globals

Have you ever been annoyed by a hard-to-track bug in lua that was caused simply because you had a typo in your variable name?

Most of us have. And this is exacerbated in lua because it does not warn you if you type in a wrong name. It will simply create a new global variable called whatever the typo was.

But with **`Calcifer`**, it's impossible to accidentally declare global variables from within a class. It will raise an error if you're trying to use a variable you have not declared before.

![](assets/sample_animal_error.png)

It's still possible to declare a global variable if you *need* to, but you have to use the following syntax

```lua
_G.myGlobal = 42
```

this way, any globals have to be deliberately declared.

## Proper access modifiers

Similar to traditional OOP languages like Java or C#, you can specify the visibility of any method or property in a class. This controls how and where you can access them. **`Calcifer`** will raise an error if you try to access a private field from outside the class, and so gives you proper information hiding and encapsulation.

![](assets/animal_access_private.png)

# Installation

"Installation" (if you can even call it that) is super simple.

All you need is the file `calcifer.lua` file included with this repository along with its `CALCIFER-LICENSE`file 

You need the license file for legal reasons. But don't worry; Calcifer is MIT-Licensed. You can basically do anything you want with the code for any purpose. Personal or Commercial.

Copy and paste `calcifer.lua` and `CALCIFER-LICENSE` somewhere in your game directory. And then before you can load any classes, you have to write the following

```lua
local Calcifer = require "path/to/calcifer"
import = Calcifer.import
```

and that's it! We're basically declaring a global function called `import` for convenience. 

You can now start writing calcifer classes and instantiating them.

## Writing a Calcifer class

Make a file somewhere in your directory. You can call it anything you want. It does not need to have the same name as the class or anything. It can be anywhere you want.

You can write a basic class like so:

```lua
class { Dog } -- declares a class for this file called "Dog"

private { sound = "bark" } -- declares a member with a default value

public { new = function()
	-- this is the constructor
end }

public { makeSound = function() 
	print(sound) -- notice we don't need to type print(self.sound)
end }
```

## Instantiating a Calcifer class

```lua
-- import the class into the current scope
local Animal = import "path/to/animal"

-- instantiate the class
local instance = Animal()

-- do stuff with the class
instance.makeSound() -- prints "bark"
```

And if you don't want to use the word `import`, you can use any word you want. You don't even need to declare `import` as a global. But then in every file where you need to import a class to instantiate or extend, you'd need to do the following

```lua
local SomeClass = require("path/to/calcifer").import("path/to/someclass")
```

# Usage

TODO: go into detail about all the features of the library. Including

* visibility
* overriding
* static fields
* abstract classes and abstract fields
* final classes
* using super and self
* interfaces
* reflection and debug api

TODO: finish the sample sokoban game