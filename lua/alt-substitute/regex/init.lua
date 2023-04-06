local M = {}
--------------------------------------------------------------------------------

---function performing a search
---@param str string
---@param toSearch string
---@param fromIdx integer perform find from this index
---@param language string
---@nodiscard
---@return integer startPos of match, nil if no match
---@return integer endPos of match, nil if no match
function M.find(str, toSearch, fromIdx, language)
	local flavor = require("alt-substitute.regex." .. language)
	local startPos, endPos = flavor.find(str, toSearch, fromIdx)
	return startPos, endPos
end

---function performing the actual string substitution
---@param inputLines string[]
---@param toSearch string
---@param toReplace string
---@param numOfReplacements integer|nil how many occurrences should be replaced;
---nil will perform all replacements
---@param language string
---@nodiscard
---@return string[] outputLines
---@return integer total number of replacements made (for notification)
function M.replace(inputLines, toSearch, toReplace, numOfReplacements, language)
	local outputLines = {}
	local totalReplCount = 0
	local flavor = require("alt-substitute.regex." .. language)
	for _, line in pairs(inputLines) do
		local newLine, numOfReplMade = flavor.replace(line, toSearch, toReplace, numOfReplacements)
		totalReplCount = totalReplCount + numOfReplMade
		table.insert(outputLines, newLine)
	end
	return outputLines, totalReplCount
end

--------------------------------------------------------------------------------
return M
