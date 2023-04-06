local M = {}

--------------------------------------------------------------------------------
-- INFO
-- To add a new flavor, you only need to bridge to your languages find/replace
-- operation, e.g. via `vim.fn.system` and fill them in below. 
-- - Remember to test for characters with escape sequences.
-- - If not already, use the Lua LSP for type safety of the parameters & returns
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- TODO Create a copy of file file and rename it to the regex flavor.
-- TODO Add info to this table in the README that the language is supported:
-- https://github.com/chrisgrieser/nvim-alt-substitute#supported-regex-flavors
--------------------------------------------------------------------------------

---function performing a search
---@param str string the string to search in
---@param toSearch string to string to search for
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
---@param toSearch string to string to search for
---@param toReplace string replacement string
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
