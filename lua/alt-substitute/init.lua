local M = {}
local warn = vim.log.levels.WARN
local hlgroup = "Substitute"
local regexFlavor, showNotification

local parameters = require("alt-substitute.process-parameters")
local regex = require("alt-substitute.regex")

--------------------------------------------------------------------------------

---the substitution to perform when the commandline is confirmed with <CR>
---@param opts table
local function confirmSubstitution(opts)
	local curBufNum = vim.api.nvim_get_current_buf()
	local line1, line2, bufferLines, toSearch, toReplace, flags = parameters.process(opts, curBufNum)
	local validFlags = "gfi"
	local invalidFlagsUsed = flags:find("[^"..validFlags.."]")

	if not toReplace then
		vim.notify("No replacement value given, cannot perform substitution.", warn)
		return
	elseif toReplace:find("%%$") then
		-- stylua: ignore
		vim.notify('A single "%" cannot be used as replacement value in lua patterns. \n(A literal "%" must be escaped as "%%".)', warn)
		return
	elseif toSearch == "" then
		vim.notify('Search string is empty.', warn)
		return
	end
	if invalidFlagsUsed then
		vim.notify(('"%s" contains invalid flags, the only valid flags are "%s".\nInvalid flags have been ignored.'):format(flags, validFlags), warn)
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
---@param _ any unused, passed if inccommand=split
---@return integer? -- value of preview type
local function previewSubstitution(opts, ns, _)
	local curBufNum = vim.api.nvim_get_current_buf()
	local line1, line2, bufferLines, toSearch, toReplace, flags = parameters.process(opts, curBufNum)

	if toSearch == "" and toReplace == "" then return end -- flag only leads to errors

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
			startPos, endPos = regex.find(line, toSearch, endPos + 1, flags, regexFlavor)
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

	return 1 -- 1 = always act as if inccommand=unsplit
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
