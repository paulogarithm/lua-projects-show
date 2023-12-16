local ArrayClass = require("./arrays")

local array = ArrayClass {1, 2, 3, 4}:Strict()
array:Shuffle()
print(array)
local t = os.clock()
array:BogoSort()
print(array, os.clock() - t)

print(ArrayClass.Methods())