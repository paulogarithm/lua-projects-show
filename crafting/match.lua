-- Compare a matrix
local function CmpMatrix(receipe, content, linOff, colOff)
	for lineN, line in pairs(receipe) do
		assert(type(lineN) == "number")
		for objN, obj in pairs(line) do
			assert(type(objN) == "number")
			local o = content[lineN + linOff - 1][objN + colOff - 1]
			if o.Count ~= 0  and o.Item.Name == obj then return true end
		end
	end
	return false
end

-- Check how many items they are
local function HowManyIn(matrix)
	local n = 0
	for _, line in pairs(matrix) do
		for index, char in pairs(line) do
			if char then
				if not char.Count or char.Count > 0 then
					n = n + 1
				 end
			end
		end
	end
	return n
end

-- Check if matrix is is matrix
local function Match(receipe, content)
	if HowManyIn(receipe) ~= HowManyIn(content) then return false end
	local endRow = #content - #receipe + 1
	local endCol = #content[1] - #receipe[1] + 1
	for r = 1, endRow do
		for c = 1, endCol do
			if CmpMatrix(receipe, content, r, c) then return true end
		end
	end
	return false
end

return Match
