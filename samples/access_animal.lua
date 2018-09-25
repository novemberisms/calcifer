
local Animal = import "samples/animal"

-- instantiate Animal
local jeff = Animal("Jeff the Animal")
-- we can access 'name' because it was declared public
print( jeff.name ) -- prints "Jeff the Animal"

print( jeff.sound )





