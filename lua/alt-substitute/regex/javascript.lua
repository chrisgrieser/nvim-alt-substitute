local M = {}
--------------------------------------------------------------------------------

---function performing a search
---@param str string the string to search in
---@param toSearch string pattern to search for
---@param fromIdx integer perform find starting from this index
---@nodiscard
---@return integer startPos of match, nil if no match
---@return integer endPos of match, nil if no match
function M.find(str, toSearch, fromIdx)
	-- TODO perform search here
	local startPos, endPos
	return startPos, endPos
end

---function performing the actual string substitution
---@param str string the string to search in
---@param toSearch string pattern to search for
---@param toReplace string replacement value
---@param numOfReplacements integer|nil how many occurrences should be replaced.
---nil will perform all replacements
---@nodiscard
---@return string strWithReplacement
---@return integer total number of replacements made (for notification)
function M.replace(str, toSearch, toReplace, numOfReplacements)
	-- TODO perform search here
	local strWithReplacement, count
	return strWithReplacement, count
end

--------------------------------------------------------------------------------
return M
