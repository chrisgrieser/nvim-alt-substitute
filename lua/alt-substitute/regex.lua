local M = {}
--------------------------------------------------------------------------------

---converts string into a lua pattern that matches letters ignoring casing https://stackoverflow.com/a/11402486
---@param pattern string
---@return string lua pattern
local function caseInsensitivePattern(pattern)
	-- find an optional '%' (group 1) followed by any character (group 2)
	local p = pattern:gsub("(%%?)(.)", function(percent, letter)
		if percent ~= "" or not letter:match("%a") then
			-- if the '%' matched, or `letter` is not a letter, return "as is"
			return percent .. letter
		else
			-- else, return a case-insensitive character class of the matched letter
			return string.format("[%s%s]", letter:lower(), letter:upper())
		end
	end)

	return p
end

--------------------------------------------------------------------------------

---function performing a search and returning the *first* match
---@param str string
---@param toSearch string *pattern* to search for
---@param fromIdx integer perform find from this index
---@param flags string
---@param language string -- the regex flavor to use
---@nodiscard
---@return integer? **one-based** startPos of match, nil if no match
---@return integer? **one-based** endPos of match, nil if no match
function M.find(str, toSearch, fromIdx, flags, language)
	local startPos, endPos
	local plain = false

	-- flags
	-- NOTE g-flag irrelevant here, since function only needs to return one match
	if flags:find("f") then
		plain = true
	elseif flags:find("i") then
		toSearch = caseInsensitivePattern(toSearch)
	end

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
---@param flags string NOTE g-flag is ignored when numOfRepls is not nil
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

	-- flags
	if flags:find("f") then
		-- escape all lua magic chars -> effectively fixed strings
		-- (since `:gsub` has no option for "plain" strings like `:find`)
		toSearch = vim.pesc(toSearch)
		toReplace = vim.pesc(toReplace)
	elseif flags:find("i") then
		toSearch = caseInsensitivePattern(toSearch)
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
