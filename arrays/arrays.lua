--!strict
--!native

local Class, Array = {}, {}
local __MetaArray = { __index = Array }
local __MetaClass = {}

-- Local stuff

local MODE = { strict = 1, nonstrict = 2 }

local SIZE = {
	float = 8,
	long = 8,
	int = 4,
	short = 2,
	char = 1,
}

local LIMITS = {
	u32 = 4294967295, 	-- uint
	i32 = 2147483647, 	-- int
	u16 = 65535, 		-- ushort
	i16 = 32767, 		-- short
	u8 = 255,			-- uchar
	i8 = 127,			-- char
}

local LIMIT_N = {
	{Size = 8, Name = "char"},
	{Size = 16, Name = "short"},
	{Size = 32, Name = "int"},
}

-- Size of number
local function sizeof(number)
	local packString = string.pack("n", number)
	return #packString
end

-- Returns true if its a float
local function isfloat(number)
	assert(type(number) == "number")
	return number % 1 ~= 0
end

-- Checks if there is at least one float in the number array
local function IsThereAFloat(self)
	assert(type(self.Length) == "number")
	for n = 0, self.Length - 1 do
		if isfloat(self[n]) then return true end
	end
	return false
end

-- Check if there is a negative number in array
local function IsThereSigned(self)
	assert(type(self.Length) == "number")
	for n = 0, self.Length - 1 do
		if self[n] < 0 then return true end
	end
	return false
end

-- Handles the number
local function HandleNumber(self)
	assert(type(self.Max) == "function")
	assert(type(self.Min) == "function")
	if IsThereAFloat(self) then
		return SIZE.float * self.Length, "f64"
	end
	local max = self:Max()
	local min = self:Min()
	local s = IsThereSigned(self) and "i" or "u"
	for _, keyDict in pairs(LIMIT_N) do
		local key = s .. tostring(keyDict.Size)
		local dataType = keyDict.Name
		local limit = assert(LIMITS[key])
		local size = assert(SIZE[dataType])
		if max <= limit and math.abs(min) <= limit then
			return size * self.Length, key
		end
	end
	return SIZE.long, s .. "64"
end

local sizeTreat = {
	-- Handles booleans
	boolean = function(self)
		return 1, "u8"
	end,

	-- Handles any numbers
	number = HandleNumber,

	-- Handles other stuff
	string = function(self)
		assert(type(self.Length) == "number")
		local total = 0
		for n = 0, self.Length - 1 do
			total = total + #self[n] + 1
		end
		return 1, "str"
	end
}

local function GetSize(self)
	assert(sizeTreat[self.Type])
	return sizeTreat[self.Type](self)
end

local function TypeChecking(self, element)
	if type(element) == nil then return true end
	if self.Length == 0 and self.Mode == MODE.strict then
		self.Type = type(element)
	elseif self.Mode == MODE.strict then
		assert(type(element) == self.Type,
			"[Push: Types Missmatch, this is a "
				.. self.Type .. " array]")
	end
	return false
end

-- Meta Methods

function __MetaArray:__len()
	return self.Length
end

function __MetaArray:__tostring()
	assert(type(self.Length) == "number")
	local buf = "["
	if #self == 0 then return buf .. "]" end
	for n = 0, self.Length - 1 do
		buf = buf .. tostring(self[n]) .. ", "
	end
	return string.sub(buf, 0, #buf - 2) .. "]"
end

function __MetaArray.__eq(a, b)
	assert(type(b) == "table")
	assert(type(a.Length) == "number")
	assert(type(b.Length) == "number")
	if a.Length ~= #b then return false end
	for n = 0, a.Length - 1 do
		if a[n] ~= b[n] then return false end
	end
	return true
end

function __MetaArray.__add(a, b)
	assert(Class.IsArray(a) and Class.IsArray(b))
	return Class.Cat(a, b)
end

function __MetaArray:__mul(num)
	assert(type(num) == "number")
	assert(num > 0)
	if num == 0 then return __MetaClass:__call({}) end
	local new = self:Clone()
	for n = 1, num - 1 do
		new = Class.Cat(new, self:Clone())
	end
	return new
end

function __MetaArray:__pairs()
	assert(type(self.Length) == "number")
	print("Foo")
	local i = 0
	return function()
		i = i + 1
		if i < self.Length - 1 then
			return i, self[i]
		end
		return 0, nil
	end
end


-- Array methods

-- Add an element at the end of the array
function Array:Push(element)
	assert(type(self.Length) == "number")
	if TypeChecking(self, element) then return end
	self[self.Length] = element
	self.Length = self.Length + 1
end

-- Add an element at the start of the array
function Array:UnShift(element)
	assert(type(self.Length) == "number")
	if TypeChecking(self, element) then return end
	for n = self.Length - 1, 0, -1 do
		self[n + 1] = self[n]
		self[0] = element
	end
	self.Length = self.Length + 1
end

-- Add an element at index defined
function Array:PushAt(index, element)
	assert(type(self.Length) == "number")
	if TypeChecking(self, element) then return end
	for n = self.Length - 1, index, -1 do
		self[n + 1] = self[n]
	end
	self[index] = element
	self.Length = self.Length + 1
end

-- Remove an element at the end
function Array:Pop()
	assert(type(self.Length) == "number")
	local old = self[self.Length]
	self[self.Length] = nil
	self.Length = self.Length - 1
	return old
end

-- Remove the first element
function Array:Shift()
	assert(type(self.Length) == "number")
	local old = self[0]
	for n = 0, self.Length - 1 do
		self[n - 1] = self[n]
	end
	self[self.Length] = nil
	self.Length = self.Length - 1
	return old
end

-- Remove an element at index defined
function Array:PopAt(index)
	assert(type(self.Length) == "number")
	assert(type(index) == "number")
	local old = self[index]
	for n = index + 1, self.Length - 1 do
		self[n - 1] = self[n]
	end
	self[self.Length] = nil
	self.Length = self.Length - 1
	return old
end

-- Get the max element
function Array:Max()
	assert(type(self.Length) == "number")
	if #self == 0 then return nil end
	if #self == 1 then return self[0] end
	local current = self[0]
	for n = 1, self.Length - 1 do
		if self[n] > current then current = self[n] end
	end
	return current
end

-- Get the minimum element
function Array:Min()
	assert(type(self.Length) == "number")
	if #self == 0 then return nil end
	if #self == 1 then return self[0] end
	local current = self[0]
	for n = 1, self.Length - 1 do
		if self[n] < current then current = self[n] end
	end
	return current
end

-- Removes element that the callback returns false
function Array:Filter(Callback)
	assert(type(Callback) == "function" and type(self.Length) == "number")
	assert(type(self.PopAt) == "function")
	local popped = 0
	for n = 0, self.Length - 1 do
		local val = self[n - popped]
		if val ~= nil and not Callback(val) then
			self:PopAt(n - popped)
			popped = popped + 1
		end
	end
	return self, popped - 1
end

-- Apply stuff to the map through callback
function Array:Map(Callback)
	assert(type(Callback) == "function")
	assert(type(self.Length) == "number")
	assert(type(self.Mode) == "number")
	assert(type(self.Type) == "string")
	local changedElement = 0
	for n = 0, self.Length - 1 do
		local val = Callback(self[n])
		if self.Mode == MODE.strict then
			assert(type(self[n]) == type(val),
				"[Map: Types Missmatch, this is a "
					.. self.Type .. " array]")
		end
		changedElement = (val == self[n])
			and changedElement + 1
			or changedElement
		self[n] = val
	end
	return self
end

-- Returns a string of each element joined
function Array:Join(separator)
	assert(type(separator) == "nil" or type(separator) == "string")
	assert(type(self.Length) == "number")
	local buf = ""
	local realsep = separator or ""
	for n = 0, self.Length - 1 do
		buf = buf .. tostring(self[n]) .. realsep
	end
	return string.sub(buf, 0, #buf - #realsep)
end

-- Swap 2 elements in array
function Array:Swap(a, b)
	local swap = self[a]
	self[a] = self[b]
	self[b] = swap
	return self
end

-- Reverse the array
function Array:Reverse()
	assert(type(self.Length) == "number")
	for n = 0, math.floor((self.Length - 1) / 2) do
		self:Swap(n, self.Length - n - 1)
	end
	return self
end

-- Sorts the array
function Array:BubbleSort()
	assert(type(self.Length) == "number")
	assert(self.Mode == MODE.strict, "[Bubble sort only works stricted]")
	assert(type(self.Swap) == "function")
	local len = self.Length - 1
	local swapped = false
	for i = 0, len - 1 do
		for j = 0, len - i - 1 do
			local a, b = self[j], self[j + 1]
			assert(type(a) == "number")
			if a > b then
				swapped = true
				self:Swap(j, j + 1)
			end
		end
		if not swapped then return self end
	end
	return self
end

-- Returns true or false if the array is sorted
function Array:IsSorted()
	assert(type(self.Length) == "number")
	local previous = nil
	for i = 0, self.Length - 1 do
		local e = self[i]
		assert(type(e) == "number")
		if previous ~= nil and e < previous then return false end
		previous = e
	end
	return true
end

-- Randomly shuffle the array elements
function Array:Shuffle()
	local currentIndex, randomIndex = self.Length, 0
	while currentIndex > 0 do
		randomIndex = math.floor(math.random() * currentIndex)
		currentIndex = currentIndex - 1
		self:Swap(currentIndex, randomIndex)
	end
end

-- Sort with bogo sort
function Array:BogoSort()
	while not self:IsSorted() do
		self:Shuffle()
	end
end

-- Extends a lua table to your array
function Array:Extends(t)
	assert(type(self.Length) == "number")
	assert(type(self.Type) == "string")
	for _, e in ipairs(t) do
		if self.Mode == MODE.strict and self.Type ~= "nil" then
			assert(self.Type == type(e),
				"[Extends: Types Missmatch, this is a "
					.. self.Type .. " array]")
		end
		self:Push(e)
	end
	return self
end

-- Converts an array to buffer
-- Returns the buffer and the ctype
function Array:ToBuffer()
	assert(buffer, "[Buffer class not founded]")
	assert(self.Type ~= "nil", "[Buffer requires strict typing]")
	assert(type(self.Length) == "number")

	local totalSize, ctype = GetSize(self)
	assert(type(ctype) == "string")
	local buf = buffer.create(totalSize)
	local off = Class.Buffer.Offset(ctype)
	assert(type(off) == "number")
	local Write = assert(buffer["write" .. ctype])
	for n = 0, self.Length - 1 do
		Write(buf, off * n, self[n])
	end
	return buf, ctype
end

-- Check if element is in the array
function Array:Includes(e)
	assert(type(self.Length) == "number")
	for i = 0, self.Length - 1 do
		if self[i] == e then return true end
	end
	return false
end

-- Check if the array is filled with element
function Array:IsArrayOf(e)
	assert(type(self.Length) == "number")
	for i = 0, self.Length - 1 do
		if self[i] ~= e then return false end
	end
	return true
end

-- Find the first index from value
function Array:IndexOf(e)
	assert(type(self.Length) == "number")
	for i = 0, self.Length - 1 do
		if self[i] == e then return i end
	end
	return -1
end

-- Find the last index from value
function Array:LastIndexOf(e)
	assert(type(self.Length) == "number")
	for i = self.Length - 1, 0, -1 do
		if self[i] == e then return i end
	end
	return -1
end

-- Duplicates an array
function Array:Clone()
	assert(type(self.Length) == "number")
	assert(type(self.Mode) == "number")
	local new = __MetaClass:__call{}
	for n = 0, self.Length - 1 do new:Push(self[n]) end
	if self.Mode == MODE.strict then new:Strict() end
	return new
end

-- Create a slice like cake from a to b
function Array:Slice(from, to)
	assert(type(from) == "number")
	assert(type(to) == "number")
	for _ = 1, from do self:Shift() end
	for _ = self.Length, to, -1 do self:Pop() end
	return self
end

-- Insert from a and removing b elements
function Array:Splice(from, remove, ...)
	for _ = 1, remove do self:PopAt(from) end
	for _, e in ipairs({ ... }) do self:PushAt(from, e) end
	return self
end

-- Set the array as strict
function Array:Strict()
	assert(type(self.Length) == "number")
	self.Mode = MODE.strict
	if self.Length == 0 then return self end
	self.Type = type(self[0])
	for n = 0, self.Length - 1 do
		assert(not TypeChecking(self, self[n]))
	end
	return self
end

-- function Array:Unique()

-- end

-- function Array:Find(Callback)

-- end

-- function Array:FindIndex(Callback)

-- end


-- Constructor metamethod

function __MetaClass.__call(_, t)
	local self = setmetatable({}, __MetaArray)
	self.Mode = MODE.nonstrict
	self.Length = 0
	self.Type = "nil"
	for _, stuff in ipairs(t) do self:Push(stuff) end
	return self
end

-- Constructor

Class.Buffer = {}

function Class.Buffer.Offset(typ)
	assert(buffer, "[Buffer class not founded]")
	assert(type(typ) == "string")
	return ((tonumber(string.sub(typ, 2, #typ))) or 8) / 8
end

function Class.Buffer.Function(typ)
	assert(buffer, "[Buffer class not founded]")
	assert(type(typ) == "string")
	return assert(buffer["read" .. typ],
		"[Buffer no read for this typ]")
end

function Class.Buffer.Read(buf, typ, index)
	assert(buffer, "[Buffer class not founded]")
	local off = Class.Buffer.Offset(typ) * index
	local success, ret = pcall(function()
		return Class.Buffer.Function(typ)(buf, off)
	end)
	assert(success, "[Buffer Overflow]")
	return ret
end

function Class.Cat(...)
	local self = __MetaClass:__call({})
	for _, e in ipairs({ ... }) do
		if self.Type == "nil" and e.Type ~= "nil" then
			self.Type = e.Type
		end
		if type(e.Length) == "number" then
			if e.Mode == MODE.strict then self.Mode = MODE.strict end
			for n = 0, e.Length - 1 do self:Push(e[n]) end
		end
	end
	return self
end

function Class.Strict(mode)
	local self = __MetaClass:__call({})
	self.Mode = assert(MODE[mode or "strict"],
		"[Invalid mode, expected 'strict' or 'nonstrict']")
	return self
end

function Class.Methods()
	local buf = "Array Methods:\n"
	for key in pairs(Array) do
		assert(type(key) == "string")
		buf = buf .. key .. ", "
	end
	buf = string.sub(buf, 0, #buf - 2)
	return buf
end

function Class.IsArray(array)
	for key in pairs(Array) do
		if not array[key] then return false end
	end
	if not array.Length then return false end
	return true
end

return setmetatable(Class, __MetaClass)
