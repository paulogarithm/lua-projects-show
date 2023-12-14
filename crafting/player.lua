--!strict

local System = require("./system")
local Items = require("./items")

local Class = {}

local Player = {}
local __Meta_Player = { __index = Player }

-- Give 'count' 'items' to the player
-- Returns false if there is no places left
function Player:Give(item, count)
	assert(type(count) == "number", "Count needs to be a number")
	if item == Items("air") then return end
	local emptyIndex = 0
	for i = 1, self.InventoryLen do
		if self.Inventory[i] == System.Enum.EmptyContent
			and emptyIndex == 0 then 
			emptyIndex = i
		end
		if self.Inventory[i].Item == item then
			self.Inventory[i].Count = self.Inventory[i].Count + count
			return true
		end
	end
	if emptyIndex ~= 0 then
		self.Inventory[emptyIndex] = { Item = item, Count = count }
		self.ItemList[item.Name] = self.Inventory[emptyIndex]
		return true
	end
	self.ItemList[item.Name] = nil
	warn("[!] No places left in inventory.")
	return false
end

function Player:UpdateInventory()
	for index, item in pairs(self.Inventory) do
		if item ~= System.Enum.EmptyContent and item.Count <= 0 then
			self.Inventory[index] = System.Enum.EmptyContent
		end
	end
end

function Player:HasItem(item)
	return self.ItemList[item.Name] ~= nil
		and self.ItemList[item.Name].Count > 0
end

-- Create a new player
function Class.new(player)
	local self = setmetatable({}, __Meta_Player)
	self.RobloxPlayer = player
	self.Inventory = setmetatable({}, {
		__index = {},
		__tostring = function(t)
			local str = ""
			for _, stuff in pairs(t) do
				if stuff.Item ~= Items("air") then
					str = str .. "["
						.. stuff.Item.Name .. ": " .. tostring(stuff.Count)
						.. "]" .. " "
				end
			end
			return str
		end
	})
	self.InventoryLen = System.Enum.InventorySlots
	self.ItemList = {}
	for i = 1, self.InventoryLen do
		self.Inventory[i] = System.Enum.EmptyContent
	end
	self.GameMode = "survival"
	return self
end

return Class