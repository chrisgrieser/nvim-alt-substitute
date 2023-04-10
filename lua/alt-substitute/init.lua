local M = {}
--------------------------------------------------------------------------------

---@class config table containing the options for the plugin
---@field showNotification boolean whether to show the "x replacements made" notice, default: true

---@param config? config
function M.setup(config)
	-- default values
	if not config then config = {} end
	local regexFlavor = "lua" -- in case other regex flavors get added later
	local showNotification = config.showNotification or true
	local substitution = require("alt-substitute.substitution")

	-- setup user commands
	local commands = { "S", "AltSubstitute" }
	for _, exCmd in pairs(commands) do
		vim.api.nvim_create_user_command(
			exCmd,
			function(opts) substitution.confirm(opts, showNotification, regexFlavor) end,
			{
				nargs = "?",
				range = "%", -- defaults to whole buffer
				addr = "lines",
				preview = function(opts, ns, _) return substitution.preview(opts, ns, regexFlavor) end,
			}
		)
	end
end

--------------------------------------------------------------------------------
return M
