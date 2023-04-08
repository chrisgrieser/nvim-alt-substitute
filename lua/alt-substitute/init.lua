local M = {}
local warn = vim.log.levels.WARN
local hlgroup = "Substitute"
local regexFlavor, showNotification

local regex = require("alt-substitute.regex")
local parameters = require("alt-substitute.process-parameters")

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
		vim.notify_once("'inccommand=split' is not supported. Please use 'inccommand=unsplit'.", warn)
		return
	end
	local curBufNum = vim.api.nvim_get_current_buf()
	local line1, line2, bufferLines, toSearch, toReplace, flags = parameters.process(opts, curBufNum)

	-- PREVIEW CHANGES
	if toReplace and toReplace ~= "" then
		local newBufferLines = regex.replace(bufferLines, toSearch, toReplace, nil, flags, regexFlavor)
		vim.api.nvim_buf_set_lines(curBufNum, line1 - 1, line2, false, newBufferLines)
	end

	-- ADD HIGHLIGHTS
	-- iterate lines
	for i, line in ipairs(bufferLines) do
		local lineIdx = line1 + i - 2

		-- search line for matches
		local matchesInLine = {}
		local startPos, endPos = 0, 0
		while true do
			startPos, endPos = regex.find(line, toSearch, startPos + 1, flags, regexFlavor)
			if not startPos then break end -- no more matches found
			table.insert(matchesInLine, { startPos = startPos, endPos = endPos })
			if not (flags:find("g")) then break end -- only one iteration when no `g` flag
		end

		-- iterate matches
		local previousShift = 0
		for ii, m in ipairs(matchesInLine) do
			-- if replacing, needs to recalculate the end position, also
			-- considering shifts for multiple matches in a line
			if toReplace and toReplace ~= "" then
				_, m.endPos = regex.find(line, toSearch, m.startPos, flags, regexFlavor)
				-- stylua: ignore
				local lineWithSomeSubs = (regex.replace({ line }, toSearch, toReplace, ii, flags, regexFlavor))[1]
				local diff = (#lineWithSomeSubs - #line)
				m.startPos = m.startPos + previousShift
				m.endPos = m.endPos + diff
				previousShift = diff
			end

			-- stylua: ignore
			vim.api.nvim_buf_add_highlight(curBufNum, ns, hlgroup, lineIdx, m.startPos - 1, m.endPos)
		end
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
	local commands = { "S", "AltSubstitute" }
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
