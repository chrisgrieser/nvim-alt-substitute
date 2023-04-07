local M = {}
--------------------------------------------------------------------------------

---@param str string string to split
---@return string[]
function M.splitByUnescapedSlash(str)
	local splitStr = {}
	local input = str .. "/" -- so the pattern also matches end of the str

	for match in input:gmatch("(.-[^\\]?)/") do
		match = match:gsub("\\/", "/")
		table.insert(splitStr, match)	
	end

	-- trim the array from empty strings at start and end
	if splitStr[1] == "" then table.remove(splitStr, 1) end	
	if splitStr[#splitStr] == "" then table.remove(splitStr) end	

	return splitStr
end

---process the parameters given in the user command (ranges, args, etc.)
---@param opts table
---@param curBufNum integer
---@nodiscard
---@return integer start line of range
---@return integer end line of range
---@return string[] buffer lines
---@return string term to search
---@return string|nil replacement
---@return boolean whether to search first or all occurrences in line
function M.process(opts, curBufNum)
	-- split by slashes ("/"), but ignore escaped slashes ("\/")
	local params = M.splitByUnescapedSlash(opts.args)

	local toSearch, toReplace, flags = params[1], params[2], params[3]
	local singleRepl = (flags and flags:find("g")) == nil

	local line1, line2 = opts.line1, opts.line2 -- range of the command
	local bufferLines = vim.api.nvim_buf_get_lines(curBufNum, line1 - 1, line2, false)

	return line1, line2, bufferLines, toSearch, toReplace, singleRepl
end

--------------------------------------------------------------------------------
return M
