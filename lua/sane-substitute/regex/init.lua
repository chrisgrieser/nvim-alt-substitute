local M = {}
local error = vim.log.levels.ERROR
--------------------------------------------------------------------------------

---function performing a search
---@param str string
---@param toSearch string
---@param fromIdx integer perform find from this index
---@param language string
---@nodiscard
---@return integer? startPos of match, nil if no match
---@return integer? endPos of match, nil if no match
function M.find(str, toSearch, fromIdx, language)
	local flavor = require("sane-substitute.regex." .. language)
	if not flavor then
		vim.notify(language .. " is not supported yet as regex flavor.", error)
		return
	end
	local startPos, endPos = flavor.find(str, toSearch, fromIdx)
	return startPos, endPos
end

---function performing the actual string substitution
---@param inputLines string[]
---@param toSearch string
---@param toReplace string
---@param numOfReplacements integer|nil how many occurrences should be replaced. 
---nil will perform all replacements
---@param language string
---@nodiscard
---@return string[]? outputLines
---@return integer? total number of replacements mode (for notification)
function M.replace(inputLines, toSearch, toReplace, numOfReplacements, language)
	local outputLines = {}
	local totalReplacementCount = 0
	for _, line in pairs(inputLines) do
		local flavor = require("sane-substitute.regex." .. language)
		if not flavor then
			vim.notify(language .. " is not supported yet as regex flavor.", error)
			return
		end
		local newLine, numOfReplMade = flavor.replace(line, toSearch, toReplace, numOfReplacements)
		totalReplacementCount = totalReplacementCount + numOfReplMade
		table.insert(outputLines, newLine)
	end
	return outputLines, totalReplacementCount
end

--------------------------------------------------------------------------------
return M
