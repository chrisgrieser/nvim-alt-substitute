local M = {}
--------------------------------------------------------------------------------

-- split by slashes ("/"), but ignore escaped slashes ("\/")
---@param str string string to split
---@return string[]
function M.splitByUnescapedSlash(str)
	local splitStr = {}

	-- so the pattern also matches end of the string
	if not (vim.endswith(str, "/")) then str = str .. "/" end
	-- remove leading slash
	if vim.startswith(str, "/") then str = str:sub(2) end

	-- splitting
	for match in str:gmatch("(.-)/") do
		-- if previous match ends with backslash, append this match to it instead
		-- aof adding it as the next match
		local prevMatch = splitStr[#splitStr] or ""
		if vim.endswith(prevMatch, "\\") then
			splitStr[#splitStr] = prevMatch:sub(1, -2) .. "/" .. match
		else
			table.insert(splitStr, match)
		end
	end

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
---@return string flags
function M.process(opts, curBufNum)
	local params = M.splitByUnescapedSlash(opts.args)
	local toSearch = params[1] or ""
	local toReplace = params[2] or ""
	local flags = params[3] or ""

	local line1, line2 = opts.line1, opts.line2 -- range of the command
	local bufferLines = vim.api.nvim_buf_get_lines(curBufNum, line1 - 1, line2, false)

	return line1, line2, bufferLines, toSearch, toReplace, flags
end

--------------------------------------------------------------------------------
return M
