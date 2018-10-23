local Calcifer = require "calcifer"
import = Calcifer.import

local Secret = import "samples/secret"

local s = Secret()

print(Calcifer.getPrivateMember(s, "secret"))
Calcifer.callPrivateMethod(s, "method")
