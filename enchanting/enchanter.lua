--| https://minecraft.fandom.com/wiki/Enchanting_mechanics

local Enchantments = require("Enchantments")

local ORDER = { "Top", "Middle", "Bottom" }
local FORMAT = { "I", "II", "III", "IV", "V" }

function tableFind(t, value)
	for i, v in ipairs(t) do
		if v == value then
			return i
		end
	end
	return -1
end

function tableJoin(arr, sep)
	local result = ""
	for i, value in ipairs(arr) do
		if i > 1 then
			result = result .. sep
		end
		result = result .. tostring(value)
	end
	return result
end

function tablePick(t)
	return t[math.random(1, #t)]
end

function mathWithin(num, lower, upper)
	assert(type(lower) == "number")
	assert(lower <= upper)
	return num >= lower and num <= upper
end

function stringSplit(inputstr, sep)
	local s, fields = sep or " ", {}
	local pattern = string.format("([^%s]+)", s)
	inputstr:gsub(pattern, function(c)
		fields[#fields + 1] = c
	end)
	return fields
end

function SnakeToPascal(snake)
    local s = string.gsub(snake, "_(%w)", function(match)
        return string.upper(match)
    end)
    return string.upper(string.sub(s, 1, 1)) .. string.sub(s, 2)
end

-- Get the base value from the number fo bookshelves (1 to 30)
local function GetBaseByBookshelves(nBookshelves)
    assert(type(nBookshelves) == "number")
    assert(nBookshelves >= 0)
    local b = math.min(nBookshelves, 15)
    return math.random(1, 8) + math.floor(b / 2) + math.random(0, b)
end

-- Get all levels randomly generated (top, middle, bottom)
local function GetLevelsByBase(base, nBookshelves)
    assert(type(nBookshelves) == "number" and type(base) == "number")
    assert(nBookshelves >= 0 and base >= 0)
    local b = math.min(nBookshelves, 15)
    local levels = {}
    levels.Bottom = math.floor(math.max(base, b * 2))
    levels.Middle = math.floor(((base * 2) / 3) + 1)
    levels.Top = math.floor(math.max(base / 3, 1))
    return setmetatable(levels, {
        __tostring = function(self)
            return tostring(self.Top) .. ", " .. tostring(self.Middle) .. ", " .. tostring(self.Bottom)
        end
    })
end

-- Get the power by applying modifiers
local function GetEnchantementPower(enchantability, base)
	assert(type(enchantability) == "number")
	assert(type(base) == "number")
	local randEnchantability = math.random(0, math.floor(enchantability / 4))
		+ math.random(0, math.floor(enchantability / 4)) + 1
	local enchantLevel = base + randEnchantability
	local randomBonusPercent = 1 + (math.random() + math.random() - 1) * .15
	local finalLevel = math.floor((enchantLevel * randomBonusPercent) + .5)
	return math.max(finalLevel, 1)
end

-- Get a list of all possible enchantments
local function GetAllPossibleEnchantments(power)
    local list = {}
    local index = 1
    for name, range in pairs(Enchantments.Powers) do
        for level, powerRange in ipairs(range) do
            if mathWithin(power, powerRange[1], powerRange[2]) and
                tableFind(Enchantments.IsTreasure, name) == -1 then
                if list[index - 1] and
                    list[index - 1].Level < level and
                    list[index - 1].Name == name then
                    list[index - 1].Level = level
                else
                    table.insert(list, { Name = name, Level = level })
                    index = index + 1
                end
            end
        end
    end
    return setmetatable(list, {
        __tostring = function(self)
            local buf = "-- LIST --\n"
            for _, item in ipairs(self) do
                buf = buf .. SnakeToPascal(item.Name) .. " " .. tostring(FORMAT[item.Level]) .. "\n"
            end
            return string.sub(buf, 1, #buf - 1)
        end
    })
end

-- Get the enchant proba
local function GetProbabilityOfEnchantment(possible)
    local list = {}
    for key, enchant in ipairs(possible) do
        local weight = assert(Enchantments.Weights[enchant.Name])
        for _ = 1, weight do
            table.insert(list, key)
        end
    end
    return list
end

-- Main Enchant
local function EnchantProfile(bookshelvesAround)
    local base = GetBaseByBookshelves(bookshelvesAround)
    local levels = GetLevelsByBase(base, bookshelvesAround)
    print(tostring(bookshelvesAround) .. " books: " .. tostring(levels))

    local alreadyUsed = {}
    for _, value in ipairs(ORDER) do
        local power = GetEnchantementPower(1, levels[value])
        local possibleEnchants = GetAllPossibleEnchantments(power)
        local probaEnchants = GetProbabilityOfEnchantment(possibleEnchants)
        local selected
        repeat
            selected = possibleEnchants[tablePick(probaEnchants)]
        until tableFind(alreadyUsed, selected.Name) == -1
        table.insert(alreadyUsed, selected.Name)
        print(SnakeToPascal(selected.Name) .. " " .. tostring(FORMAT[selected.Level]))
    end
end

local seed = tonumber(string.sub(tostring({}), #("table: ") + 1), 16)
math.randomseed(seed)
EnchantProfile(15)
