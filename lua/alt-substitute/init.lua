local M = {}
local warn = vim.log.levels.WARN
local hlgroup = "Substitute"
local regexFlavor, showNotification

local regex = require("alt-substitute.regex")
local parameters = require("alt-substitute.process-parameters")

--------------------------------------------------------------------------------

---more complicated than just running gsub on each line, since the shift in
---length needs to be determined for each substitution, for the preview highlight
---@param opts table
---@param ns integer namespace id to use for highlights
---@param curBufNum integer buffer id
local function previewAndHighlightReplacements(opts, ns, curBufNum)
	local line1, line2, bufferLines, toSearch, toReplace, flags = parameters.process(opts, curBufNum)
	if not toReplace then return end

	-- PREVIEW CHANGES
	local newBufferLines = regex.replace(bufferLines, toSearch, toReplace, nil, flags, regexFlavor)
	vim.api.nvim_buf_set_lines(curBufNum, line1 - 1, line2, false, newBufferLines)

	-- ADD HIGHLIGHTS
	-- iterate lines in range
	for i, line in ipairs(bufferLines) do
		local lineIdx = line1 + i - 2

		-- find all matches in the line
		local startPositions = {}
		local start = 0
		while true do
			start, _ = regex.find(line, toSearch, start + 1, flags, regexFlavor)
			if not start then break end -- no more matches found
			table.insert(startPositions, start)
			if not (flags:find("g")) then break end
		end

		-- iterate matches
		local previousShift = 0
		for ii, startPos in ipairs(startPositions) do
			local _, endPos = regex.find(line, toSearch, startPos, flags, regexFlavor)
			local lineWithSomeSubs = (regex.replace({ line }, toSearch, toReplace, ii, flags, regexFlavor))[1]
			local diff = (#lineWithSomeSubs - #line)
			startPos = startPos + previousShift
			endPos = endPos + diff
			previousShift = diff 

			vim.api.nvim_buf_add_highlight(curBufNum, ns, hlgroup, lineIdx, startPos - 1, endPos)
		end
	end
end

---@param opts table
---@param ns integer namespace id to use for highlights
---@param curBufNum integer buffer id
local function highlightSearches(opts, ns, curBufNum)
	local line1, _, bufferLines, toSearch, _, flags = parameters.process(opts, curBufNum)
	for i, line in ipairs(bufferLines) do
		-- only highlighting first match, since the g-flag can only be entered
		-- when there is a substitution value
		local startPos, endPos = regex.find(line, toSearch, 1, flags, regexFlavor)
		if startPos then
			vim.api.nvim_buf_add_highlight(0, ns, hlgroup, line1 + i - 2, startPos - 1, endPos)
		end
	end
end

--------------------------------------------------------------------------------

---the substitution to perform when the commandline is confirmed with <CR>
---@param opts table
local function confirmSubstitution(opts)
	local curBufNum = vim.api.nvim_get_current_buf()
	local line1, line2, bufferLines, toSearch, toReplace, flags = parameters.process(opts, curBufNum)

	if not toReplace then
		vim.notify("No replacement value given, cannot perform substitution.", warn)
		return
	end

	local newBufferLines, totalReplacementCount =
		regex.replace(bufferLines, toSearch, toReplace, nil, flags, regexFlavor)
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
		vim.notify_once("'inccommand=split' is not supported. Please use 'inccommand=unsplit' instead.", warn)
		return
	end
	local curBufNum = vim.api.nvim_get_current_buf()

	local params = parameters.splitByUnescapedSlash(opts.args)
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
	regexFlavor = "lua" -- for now only lua is supported
	showNotification = opts.showNotification or true

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
