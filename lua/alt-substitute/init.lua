local M = {}
local warn = vim.log.levels.WARN
local hlgroup = "Substitute"
local regexFlavor, showNotification

local regex = require("alt-substitute.regex")

--------------------------------------------------------------------------------

---@param str string string to split
---@return string[]
local function splitByUnescapedSlash(str)
	local splitStr = {}
	local input = str .. "/" -- so the pattern also matches end of the str

	-- path/tomy/file
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
local function processParameters(opts, curBufNum)
	-- split by slashes ("/"), but ignore escaped slashes ("\/")
	local params = splitByUnescapedSlash(opts.args)

	local toSearch, toReplace, flags = params[1], params[2], params[3]
	local singleRepl = (flags and flags:find("g")) == nil

	local line1, line2 = opts.line1, opts.line2 -- range of the command
	local bufferLines = vim.api.nvim_buf_get_lines(curBufNum, line1 - 1, line2, false)

	return line1, line2, bufferLines, toSearch, toReplace, singleRepl
end

--------------------------------------------------------------------------------

---more complicated than just running gsub on each line, since the shift in
---length needs to be determined for each substitution, for the preview highlight
---@param opts table
---@param ns integer namespace id to use for highlights
---@param curBufNum integer buffer id
local function previewAndHighlightReplacements(opts, ns, curBufNum)
	local line1, line2, bufferLines, toSearch, toReplace, singleRepl = processParameters(opts, curBufNum)
	if not toReplace then return end

	-- PREVIEW CHANGES
	local numOfReplacement = singleRepl and 1 or nil
	local newBufferLines = regex.replace(bufferLines, toSearch, toReplace, numOfReplacement, regexFlavor)
	vim.api.nvim_buf_set_lines(curBufNum, line1 - 1, line2, false, newBufferLines)

	-- ADD HIGHLIGHTS
	-- iterate lines in range
	for i, line in ipairs(bufferLines) do
		local lineIdx = line1 + i - 2

		-- find all matches in the line
		local startPositions = {}
		local start = 0
		while true do
			start, _ = regex.find(line, toSearch, start + 1, regexFlavor)
			if not start then break end -- no more matches found
			table.insert(startPositions, start)
			if singleRepl then break end -- only one match needed
		end

		-- iterate matches
		local previousShift = 0
		for ii, startPos in ipairs(startPositions) do
			local _, endPos = regex.find(line, toSearch, startPos, regexFlavor)
			local lineWithSomeSubs = (regex.replace({ line }, toSearch, toReplace, ii, regexFlavor))[1]
			local diff = (#lineWithSomeSubs - #line)
			startPos = startPos + previousShift
			endPos = endPos + diff -- shift of end position due to replacement
			previousShift = previousShift + diff -- remember shift for next iteration

			vim.api.nvim_buf_add_highlight(curBufNum, ns, hlgroup, lineIdx, startPos - 1, endPos)
		end
	end
end

---@param opts table
---@param ns integer namespace id to use for highlights
---@param curBufNum integer buffer id
local function highlightSearches(opts, ns, curBufNum)
	local line1, _, bufferLines, toSearch, _, _ = processParameters(opts, curBufNum)
	for i, line in ipairs(bufferLines) do
		-- only highlighting first match, since the g-flag can only be entered
		-- when there is a substitution value
		local startPos, endPos = regex.find(line, toSearch, 1, regexFlavor)
		if startPos and endPos then
			vim.api.nvim_buf_add_highlight(0, ns, hlgroup, line1 + i - 2, startPos - 1, endPos)
		end
	end
end

--------------------------------------------------------------------------------

---the substitution to perform when the commandline is confirmed with <CR>
---@param opts table
local function confirmSubstitution(opts)
	local curBufNum = vim.api.nvim_get_current_buf()
	local line1, line2, bufferLines, toSearch, toReplace, singleRepl = processParameters(opts, curBufNum)

	if not toReplace then
		vim.notify("No replacement value given, cannot perform substitution.", warn)
		return
	end

	local numOfReplacement = singleRepl and 1 or nil
	local newBufferLines, totalReplacementCount =
		regex.replace(bufferLines, toSearch, toReplace, numOfReplacement, regexFlavor)
	vim.api.nvim_buf_set_lines(curBufNum, line1 - 1, line2, false, newBufferLines)
	if showNotification then
		vim.notify("Replaced " .. tostring(totalReplacementCount) .. " instances.")
	end
end

-- https://neovim.io/doc/user/map.html#%3Acommand-preview
---@param opts table
---@param ns number namespace for the highlight
---@param preview_buf boolean true if inccommand=split. (Not implemented yet.)
---@return integer? -- value of preview type
local function previewSubstitution(opts, ns, preview_buf)
	if preview_buf then
		-- stylua: ignore
		vim.notify_once("'inccommand=split' is not supported yet. Please use 'inccommand=unsplit' instead.", warn)
		return
	end
	local curBufNum = vim.api.nvim_get_current_buf()

	local params = splitByUnescapedSlash(opts.args)
	local toReplace = params[2]

	if not toReplace or toReplace == "" then
		highlightSearches(opts, ns, curBufNum)
	else
		previewAndHighlightReplacements(opts, ns, curBufNum)
	end

	return 2 -- return the value of the preview type
end

--------------------------------------------------------------------------------

---@class config table containing the options for the plugin
---@field regexFlavor string default: lua
---@field showNotification boolean whether to show the "x replacements made" notice, default: true

---@param opts? config
function M.setup(opts)
	-- default values
	if not opts then opts = {} end
	regexFlavor = opts.regexFlavor or "lua"
	showNotification = opts.showNotification or true

	-- validation that regex module exists
	local available, _ = pcall(require, "alt-substitute.regex." .. regexFlavor)
	if not available then
		vim.notify(regexFlavor .. " is not yet supported as regex flavor.", warn)
		return
	end

	-- setup user commands
	local commands = { "S", "AltSubstition" }
	for _, cmd in pairs(commands) do
		vim.api.nvim_create_user_command(cmd, confirmSubstitution, {
			nargs = "?",
			range = "%", -- defaults to whole buffer
			addr = "lines",
			preview = previewSubstitution,
		})
	end
end

--------------------------------------------------------------------------------

return M
