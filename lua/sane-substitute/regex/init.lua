local M = {}
--------------------------------------------------------------------------------

---function performing the actual string substitution
---@param inputLines string[]
---@param toSearch string
---@param toReplace string
---@param numOfReplacements integer|nil nil will perform all replacements
---@param language "lua"|"javascript"
---@nodiscard
---@return string[] outputLines
---@return integer total number of replacements mode (for notification)
function M.replace(inputLines, toSearch, toReplace, numOfReplacements, language)
	local outputLines = {}
	local totalReplacementCount = 0
	for _, line in pairs(inputLines) do
		local newLine, replMade
		if language == "lua" then
			newLine, replMade = line:gsub(toSearch, toReplace, numOfReplacements)
		elseif language == "javascript" then
		end
		totalReplacementCount = totalReplacementCount + replMade
		table.insert(outputLines, newLine)
	end
	return outputLines, totalReplacementCount
end

---function performing a search
---@param str string
---@param toSearch string
---@param fromIdx integer perform find from this index
---@param language "lua"|"javascript"
---@nodiscard
---@return integer startPos of match, nil if no match
---@return integer endPos of match, nil if no match
function M.find(str, toSearch, fromIdx, language)
	local startPos, endPos
	if language == "lua" then
		startPos, endPos = str:find(toSearch, fromIdx)
	elseif language == "javascript" then
	end
	return startPos, endPos
end

--------------------------------------------------------------------------------
return M
