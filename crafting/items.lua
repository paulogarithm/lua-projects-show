--!strict

local Items = {}
local __Meta_Items = { __index = Items }

Items.List = {}

function __Meta_Items:__tostring()
	return self.Name
end

-- Create a new item
local function New(name, profile, receipe)
	local self = setmetatable({}, __Meta_Items)
	self.Stackable = profile.Stackable
	self.Rarity = profile.Rarity
	self.Name = name
	Items.List[name] = self

	self.Pattern = {}
	if receipe.Template == "" then return end
	for n, line in pairs(string.split(receipe.Template, "/")) do
		local t = {}
		for index, char in pairs(string.split(line, "")) do
			assert(type(index) == "number")
			local itemIndex = string.byte(char) - string.byte("a") + 1
			t[index] = receipe.Ingredients[itemIndex]
		end
		self.Pattern[n] = t
	end
	self.Count = receipe.Count
end

-- Profile for a common stackable item
local DEFAULT_PROFILE = setmetatable({}, {
	__index = {
		Rarity = "common",
		Stackable = true,
		Count = 1,
	},
	__call = function (self, n)
		self.Count = n
		return self
	end
})

-- Profile for a Common tool
local TOOL_PROFILE = {
	Rarity = "common",
	Stackable = false
}

-- Profile for impossible
local FOO_PROFILE = {
	Rarity = "foo",
	Stackable = false
}

-- The receipe with 'template' and 'items required'
local function Receipe(count, template, ...)
	local self = {}
	self.Template = template
	self.Count = count
	self.Ingredients = { ... }
	return self
end

-- The receipe for an uncraftable item
local NO_RECEIPE = { Template = "", Ingredients = {}, Count = 0 }

-- The meta class
local Class = setmetatable(Items.List, {
	__call = function(_, itemName)
		assert(Items.List[itemName], "[x] Item doesnt exist.")
		return Items.List[itemName]
	end,
})

-- The items (do snake case)
New("air", FOO_PROFILE, NO_RECEIPE)
New("oak_log", DEFAULT_PROFILE, NO_RECEIPE)
New("oak_planks", DEFAULT_PROFILE,
	Receipe(4, "a", "oak_log")
)
New("stick", DEFAULT_PROFILE,
	Receipe(4, "a/a", "oak_planks")
)
New("wooden_pickaxe", TOOL_PROFILE,
	Receipe(1, "aaa/.b./.b.", "oak_planks", "stick")
)

return Class