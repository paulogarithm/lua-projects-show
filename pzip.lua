--!strict
--!native

--|
--| PZIP.luau, the luau-buffer lossless compression 💾
--|
--| This code cant be involved in nazi projects
--|

local HEADER_LEN = 5

local Pzip = {}

-- Get only occurences: (Helloooo) -> Helo
local function OnlyOccurences(self: {string}): {string}
	local t = {}
	local occurences = {}
	local index = 1
	for _, c in next, self do
		if t[c] then continue end
		t[c] = 42
		occurences[index] = c
		index += 1
	end
	return occurences
end

-- Split string to chunks: (Hello, 2) -> {He, ll, o}
local function SplitByChunk(text: string, chunkSize: number)
	local s = {}
	for i = 1, #text, chunkSize do
		s[#s + 1] = string.sub(text, i, i + chunkSize - 1)
	end
	return s
end

-- Converts bin strings to full byte: ("101") -> "00000101"
local function RegularByte(bin: string, bytes: number, mode: string?)
	local nZero = (bytes * 8) - #bin
	local str = string.rep("0", nZero)
	return if mode and mode:lower() == "left"
		then bin .. str
		else str .. bin
end


-- Converts a char to a bin: (9) -> "1001"
local function ToBits(num: number): string
	local s = ""
	local rest = 0
	while num > 0 do
		rest = math.fmod(num,2)
		s ..= tostring(rest)
		num = (num - rest) / 2
	end
	return s:reverse()
end

-- Get the max amount of bits for a number: (6) -> 110 -> 3
local function MaxBits(number)
	if number <= 0 then
		return 0
	end
	local bits = 0
	while number > 0 do
		number = math.floor(number / 2)
		bits = bits + 1
	end
	return bits
end

-- Apply stuff to a table to return a new table
local function TableMap<a, b>(t: {a}, func: (a) -> b)
	local new_tbl: {b} = {}
	for i, v in ipairs(t) do
		new_tbl[i] = func(v)
	end
	return new_tbl
end

-- Read actual bytes
local function ReadBytes(zip: buffer, offset: number, bytes: number)
	local lenStr = buffer.readstring(zip, offset, bytes)
	local lenNumList = TableMap(string.split(lenStr, ""), function(e)
		return string.byte(e)
	end)
	local len = 0
	for _, val in next, lenNumList do
		len = bit32.lshift(len, 8)
		len = bit32.bor(len, val)
	end
	return len
end

-- Returns a packed version of the buffer and if it succeed
function Pzip.Pack2(src: buffer): (buffer, boolean)
	local charMatrix = string.split(buffer.tostring(src), "")
	local occurences = OnlyOccurences(charMatrix)
	local maxBits = MaxBits(#occurences)
	local binaryString = ""

	-- Fill the binary string
	binaryString ..= RegularByte(ToBits(#occurences), 1)
	binaryString ..= RegularByte(ToBits(#charMatrix), 4)
	for _, char in next, occurences do
		binaryString ..= RegularByte(ToBits(string.byte(char)), 1)
	end
	for _, c in ipairs(charMatrix) do
		local index = assert(table.find(occurences, c))
		local bits = ToBits(index - 1)
		local str = RegularByte(bits, 2)
		binaryString ..= string.sub(str, #str - maxBits + 1, #str)
	end

	-- Create Chunks
	local chunks = SplitByChunk(binaryString, 8)
	chunks[#chunks] = RegularByte(chunks[#chunks], 1, "left")
	local numChunks = TableMap(chunks, function(e)
		return tonumber(e, 2) or 0
	end)
	print("[!] Compressing from "..tostring(#charMatrix).." bytes to "..tostring(#numChunks).." bytes")
	if #charMatrix <= #numChunks then
		print("[!] Not worth it")
		return src, false
	end

	-- Return the buffer
	print("[!] Worth it !")
	local dest = string.char(table.unpack(numChunks))
	return buffer.fromstring(dest), true
end

function Pzip.UnPack2(zip: buffer): buffer
	local occurences = buffer.readu8(zip, 0)
	local len = ReadBytes(zip, 1, 4)
	local characters = {}

	-- Fill the character table with avaible characters
	for i = HEADER_LEN, HEADER_LEN - 1 + occurences do
		local c = string.char(buffer.readu8(zip, i))
		table.insert(characters, c)
	end
	local maxBits = MaxBits(#characters)

	-- Fill the bin string with content
	local bin, str = "", ""
	for i = HEADER_LEN + occurences, #buffer.tostring(zip) - 1 do
		bin ..= RegularByte(ToBits(buffer.readu8(zip, i)), 1)
	end

	-- Create chunk of 'maxBits': (100010, 3) -> 100, 010
	local chunks = SplitByChunk(bin, maxBits)
	local index = 0
	for _, chunk in next, chunks do
		if index >= len then break end
		local n = tonumber(chunk, 2) or 0
		str ..= characters[math.min(n + 1, #characters)]
		index += 1
	end
	return buffer.fromstring(str)
end

return Pzip
