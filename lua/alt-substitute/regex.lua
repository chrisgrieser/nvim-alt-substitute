local M = {}
--------------------------------------------------------------------------------

---function performing a search
---@param str string
---@param toSearch string *pattern* to search for
---@param fromIdx integer perform find from this index
---@param language string
---@nodiscard
---@return integer **one-based** startPos of match, nil if no match
---@return integer **one-based** endPos of match, nil if no match
function M.find(str, toSearch, fromIdx, language)
	local startPos, endPos

	if language == "lua" then
		startPos, endPos = str:find(toSearch, fromIdx)
	end

	return startPos, endPos
end

---function performing the actual string substitution
---@param inputLines string[]
---@param toSearch string *pattern* to search for
---@param toReplace string replacement value
---@param numOfReplacements integer|"all"|nil how many occurrences should be replaced
---@param language string
---@nodiscard
---@return string[] output as array of lines
---@return integer total number of replacements made (for notification)
function M.replace(inputLines, toSearch, toReplace, numOfReplacements, language)
	local outputLines = {}
	local totalReplCount = 0
	if numOfReplacements == "all" then numOfReplacements = nil end

	if language == "lua" then
		for _, line in pairs(inputLines) do
			---@diagnostic disable-next-line: param-type-mismatch LSP error; already ensured "all" gets not assigned
			local newLine, numOfReplMade = line:gsub(toSearch, toReplace, numOfReplacements)
			totalReplCount = totalReplCount + numOfReplMade
			table.insert(outputLines, newLine)
		end
	end

	return outputLines, totalReplCount
end

--------------------------------------------------------------------------------
return M
