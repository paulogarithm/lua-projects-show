--!strict

local Items = require("./items")
local Match = require("./match")
local System = require("./system")

local Class = {}

local Crafting = {}
local __Meta_Crafting = { __index = Crafting }

-- Count how many items are inside of the crafting table (#craftingTable)
function __Meta_Crafting:__len()
	local count = 0
	for i = 1, self.Range do
		for j = 1, self.Range do
			if self.Content[i][j] ~= System.Enum.EmptyContent then
				count = count + 1
			end
		end
	end
	return count
end

-- Display the crafting table
function __Meta_Crafting:__tostring()
	local buf = "\n"
	for i = 1, self.Range do
		for j = 1, self.Range do
			buf = buf .. "["
			buf = buf .. ((self.Content[j][i] == System.Enum.EmptyContent) and " " or "x")
			buf = buf .. "]"
		end
		buf = buf .. "\n"
	end
	return buf
end



-- Push an item in the crafting table at [x][y].
function Crafting:Push(item, x, y)
	local owner = assert(self.Owner,
		"[x] Missing an owner to the crafting table.")
	assert(owner:HasItem(item), "[x] Player doesnt have the item.")
	assert(type(x) == "number" and type(y) == "number")
	assert(x <= self.Range and x > 0,
		"[x] Value x needs to be between 1 and " .. tostring(self.Range) .. ".")
	assert(y <= self.Range and y > 0,
		"[x] Value y needs to be between 1 and " .. tostring(self.Range) .. ".")
	assert(type(self.Content[x][y].Count) == "number")
	
	if self.Content[x][y].Item == item then
		self.Content[x][y].Count = self.Content[x][y].Count + 1
	else
		if self.Content[x][y] ~= System.Enum.EmptyContent then
			warn("[!] Something is already at this position, swapping items...")
			self:Remove(x, y)
		end
		self.Content[x][y] = { Item = item, Count = 1 }
	end
	owner.ItemList[item.Name].Count = owner.ItemList[item.Name].Count - 1
	owner:UpdateInventory()
	return {
		Repeat = function(count)
			assert(type(count) == "number")
			for i = 1, count - 1 do self:Push(item, x, y) end
		end
	}
end

-- Remove an item from crafting table and putting it back in the player.
function Crafting:Remove(x, y)
	local owner = assert(self.Owner,
		"[x] Missing an owner to the crafting table.")
	assert(x <= self.Range and x > 0,
		"[x] Value x needs to be between 1 and " .. tostring(self.Range) .. ".")
	assert(y <= self.Range and y > 0,
		"[x] Value y needs to be between 1 and " .. tostring(self.Range) .. ".")
	local item = self.Content[x][y]
	if item == System.Enum.EmptyContent then return end
	self.Content[x][y] = System.Enum.EmptyContent
	owner:Give(item.Item, item.Count)
end

-- Craft an item and give it to the owner
function Crafting:Craft()
	local owner = assert(self.Owner,
		"[x] Missing an owner to the crafting table.")
	local item = self:Update()
	if item == nil then return end
	self:Clear(false)
	owner:Give(item.Item, item.Count)
end

-- Craft the max amount of item you can do in a row.
function Crafting:CraftMax()
	local REF_ITEM = self:Update()
	local previousItem = REF_ITEM
	if REF_ITEM == nil then return end
	while previousItem and previousItem.Item.Name == REF_ITEM.Item.Name do
		self:Craft()
		previousItem = self:Update()
	end
end

-- Clear the crafting table.
function Crafting:Clear(reset)
	for i = 1, self.Range do
		if reset then self.Content[i] = {} end
		for j = 1, self.Range do
			if reset == false
				and self.Content[i][j]
				and self.Content[i][j] ~= System.Enum.EmptyContent then
				
				self.Content[i][j].Count = self.Content[i][j].Count - 1
				if self.Content[i][j].Count == 0 then
					self.Content[i][j] = System.Enum.EmptyContent
				end
			elseif self.Content[i][j] ~= System.Enum.EmptyContent then
				self.Content[i][j] = System.Enum.EmptyContent
			end
		end
	end
end

-- Update the crafting table for craft receipes.
function Crafting:Update()
	local t = {}
	for _, item in pairs(Items) do
		if item.Pattern ~= nil and item.Pattern[1] ~= nil then
			if Match(item.Pattern, self.Content) then
				table.insert(t, { Item = item, Count = item.Count })
			end
		end
	end
	return t[1]
end

-- Disconnect the user that is using the crafting table
function Crafting:Disconnect()
	if self.Owner == nil then
		return warn("[!] No user is using the crafting table.")
	end
	self.Owner = nil
end

-- Connect a user to the crafting table.
function Crafting:Connect(player)
	if self.Owner ~= nil then
		return warn("[!] A user is already using the crafting table.")
	end
	self.Owner = player
end



-- Creates a new crafting table of nSlots by nSlots.
function Class.new(nSlots)
	assert(type(nSlots) == "number", "[x] The slots need to be a number.")
	assert(nSlots >= 0, "[x] The slots can't be negative.")

	local self = setmetatable({}, __Meta_Crafting)
	self.Content = {}
	self.Range = nSlots
	self.Size = nSlots * nSlots
	self.AutoUpdate = false
	self:Clear(true)
	return self
end

return Class