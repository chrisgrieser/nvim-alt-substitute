local M = {}
--------------------------------------------------------------------------------

---function performing a search
---@param str string the string to search in
---@param toSearch string *pattern* to search for
---@param fromIdx integer perform find starting from this index
---@nodiscard
---@return integer startPos of match, nil if no match
---@return integer endPos of match, nil if no match
function M.find(str, toSearch, fromIdx)
	local startPos, endPos = str:find(toSearch, fromIdx)
	return startPos, endPos
end

---function performing the actual string substitution
---@param str string the string to search in
---@param toSearch string *pattern* to search for
---@param toReplace string replacement value
---@param numOfReplacements integer|nil how many occurrences should be replaced. 
---nil will perform all replacements
---@nodiscard
---@return string strWithReplacement
---@return integer total number of replacements made (for notification)
function M.replace(str, toSearch, toReplace, numOfReplacements)
	local strWithReplacement, count = str:gsub(toSearch, toReplace, numOfReplacements)
	return strWithReplacement, count
end

--------------------------------------------------------------------------------
return M
