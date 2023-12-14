--!strict

local Items = require("./items")
local System = {}

System.Lib = {}

function System.Lib.ReadOnly(t)
	local proxy = {}
	local mt = {
		__index = t,
		__newindex = function ()
			error("[x] Attempt to update a read-only table.", 2)
		end
	}
	setmetatable(proxy, mt)
	return proxy
end

System.Enum = System.Lib.ReadOnly {
	InventorySlots = 16,
	EmptyContent = { Item = Items("air"), Count = 0, }
}

return System
