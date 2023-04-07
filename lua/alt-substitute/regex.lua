local M = {}
--------------------------------------------------------------------------------

---function performing a search and returning the *first* match
---@param str string
---@param toSearch string *pattern* to search for
---@param fromIdx integer perform find from this index
---@param flags string NOTE g-flag is irrelevant here, since this function only needs to return one match
---@param language string -- the regex flavor to use
---@nodiscard
---@return integer **one-based** startPos of match, nil if no match
---@return integer **one-based** endPos of match, nil if no match
function M.find(str, toSearch, fromIdx, flags, language)
	local startPos, endPos

	-- f-flag
	local plain = flags:find("f") ~= nil

	if language == "lua" then
		startPos, endPos = str:find(toSearch, fromIdx, plain)
	end

	return startPos, endPos
end

---function performing the actual string substitution
---@param inputLines string[]
---@param toSearch string *pattern* to search for
---@param toReplace string replacement value
---@param numOfRepls? integer how often a replacement should be performed. only needed for the calculation of highlights in the incremental preview where this value can be different from "all" and 1. If the value is nil, will determine the number of replacements from from the presence of the g-flag
---@param flags string
---@param language string
---@nodiscard
---@return string[] output as array of lines
---@return integer total number of replacements made (for notification)
function M.replace(inputLines, toSearch, toReplace, numOfRepls, flags, language)
	local outputLines = {}
	local totalReplCount = 0

	if not numOfRepls and not (flags:find("g")) then
		numOfRepls = 1
	elseif not numOfRepls and flags:find("g") then
		numOfRepls = nil -- for :gsub, "nil" means "all"
	end

	-- f-flag: 
	-- escape all lua magic chars -> effectively fixed strings (since :gsub has no plain option)
	if flags:find("f") then
		toSearch = vim.pesc(toSearch)
		toReplace = vim.pesc(toReplace)
	end

	if language == "lua" then
		for _, line in pairs(inputLines) do
			local newLine, numOfReplMade = line:gsub(toSearch, toReplace, numOfRepls)
			totalReplCount = totalReplCount + numOfReplMade
			table.insert(outputLines, newLine)
		end
	end

	return outputLines, totalReplCount
end

--------------------------------------------------------------------------------
return M
