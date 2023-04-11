# nvim-alt-substitute
<!-- vale Microsoft.Adverbs = NO --><!-- vale RedHat.Contractions = NO -->
A substitute of vim's `:substitute` that uses lua patterns instead of vim regex. Since you really don't want to learn a whole new flavor of regex just to be able to make search-and-replace operations in your editor.

https://user-images.githubusercontent.com/73286100/231134276-e33b4ee8-611c-4b27-9c57-031ae13fc268.mp4

*Colorscheme: dawnfox variant of nightfox.nvim*

<!--toc:start-->
- [Motivation](#motivation)
- [Features](#features)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Flags](#flags)
  - [Ranges](#ranges)
  - [Escaping](#escaping)
- [Advanced Usage](#advanced-usage)
  - [Lua Pattern Tricks](#lua-pattern-tricks)
  - [Appearance](#appearance)
  - [Command Line Completion](#command-line-completion)
- [Current Limitations](#current-limitations)
- [Add Support for more Regex Flavors](#add-support-for-more-regex-flavors)
- [Other Search-and-Replace Plugins](#other-search-and-replace-plugins)
- [Credits](#credits)
<!--toc:end-->

## Motivation
<!-- vale Google.FirstPerson = NO -->
Many people like me have only started using nvim after the introduction of lua as configuration language. While almost everything about neovim can be done with lua by now, search-and-replace via `:substitute` is one of few areas remaining where you still have to use vimscript. Regardless whether you like vimscript or not, learning vim's flavor of regex *just* for search-and-replace-operations feels somewhat unproductive. 

So for those of us who have never used neovim with anything other than lua, why not work with lua patterns for search-and-replace as well? While they are indeed lacking some features when compared to "real" regex, lua patterns do come with some quite handy items like the balanced match `%bxy` or the frontier pattern `%f[set]`.[^1] ([See the Lua Reference Manual on how to use them.](https://www.lua.org/manual/5.4/manual.html#6.4.1))

## Features
- Use `:AltSubstitute` (short form `:S`) to perform search-and-replace
  operations using lua patterns.
- Incremental preview of the substitution.
- Supports ranges, with `%` as default.
- The `g` flag is supported and works like with `:substitute`. 
- New flags: `i` for case-insensitive search and `f` for fixed strings (literal strings).

```text
:%s /\(\w\+\)\d\+/\1/g          -- :substitute
:S /(%w+)%d+/%1/g               -- :AltSubstitute
deviceModel2020 -> deviceModel  -- effect
```

## Installation

```lua
-- lazy.nvim
{
	"chrisgrieser/nvim-alt-substitute",
  opts = true,
  -- lazy-loading with `cmd =` does not work with incremental preview
  event = "CmdlineEnter",
},

-- packer
use {
	"chrisgrieser/nvim-alt-substitute",
	config = function() require("alt-substitute").setup({}) end,
}
```

> __Note__  
> This plugin requires at least __nvim 0.8__, which introduced the incremental
> command preview feature.

## Configuration

```lua
-- default values
opts = {
	showNotification = true, -- whether to show the "x replacements made" notification
}
```

The plugin uses ex-commands and comes without keymaps. You can set some of your own though. (Remember *not* to add `<CR>` at the end.)

```lua
-- prefill commandline with Substitution Syntax
vim.keymap.set({ "n", "x" }, "<leader>s", [[:S ///g<Left><Left><Left>]], { desc = "󱗘 :AltSubstitute" })

-- alternative: prefile commandline with word under cursor
vim.keymap.set({ "n", "x" }, "<leader>s", function()
	return ":S /" .. vim.fn.expand("<cword>") .. "//g<Left><Left>"
end, { desc = "󱗘 :AltSubstitute word under cursor", expr = true })
```

## Usage
The plugin registers the Ex-commands `:AltSubstitue` and `:S` as short form.

### Flags
- `g`: works the same as the `g` flag from `:substitute`: Without the `g` flag, only the first match in a line is replaced. With it, every occurrence in a line is replaced.
- `f`: the search query and replace value are treated as __fixed strings__,
  meaning lua magic characters are treated as literal strings.
- `i`: the search query is __case insensitive__. The `i` flag is ignored when the `f` flag is also used. (Also note that as opposed to `:substitute`, this plugin ignored the `ignorecase` and `smartcase` setting, so case sensitive is solely determined by whether this flag is present.)

### Ranges
- Ranges are line-based and work [like all other vim command](https://neovim.io/doc/user/cmdline.html#cmdline-ranges). 
- However, as opposed to `:substitute`, `:AltSubstitute` works on the whole buffer when no range is given. (In other words, `%` is the default range.)

### Escaping
- Like with `:substitute`, slashes (`/`) delimit search query, replace
  value, and flags. Therefore, to search for or replace a `/` you need to escape it with a backslash: `\/`. 

## Advanced Usage

### Lua Pattern Tricks
- `-` is lua's non-greedy quantifier. (`.-` is equivalent to `.*?` from
  javascript regex.)
- The frontier pattern`%f[set]`[^1] can be used as a replacement for `\b`:
  `%f[%w]`
- The balanced match `%bxy` can be used to deal with nested brackets.
- [Read more about lua patterns in the lua reference manual](https://www.lua.org/manual/5.4/manual.html#6.4.1).

### Appearance
The incremental preview uses the same highlight group as `:substitute`, namely `Substitition`.

### Command Line Completion
You can use [cmp-cmdline-history](https://github.com/dmitmel/cmp-cmdline-history) to get suggestions of previous substitutions you made. If you find them not helpful, and do not want the suggestions to obfuscate your view of the buffer, then you can disable command suggestions for this plugin:

```lua
cmp.setup.cmdline(":", {
	sources = { --[[ your sources ]]
	},
	enabled = function()
		-- Set of commands where cmp will be disabled
		local disabled = {
			AltSubstitute = true,
			S = true,
		}
		-- Get first word of cmdline
		local cmd = vim.fn.getcmdline():match("%S+")
		-- Return true if cmd isn't disabled
		-- else call/return cmp.close(), which returns false
		return not disabled[cmd] or cmp.close()
	end,
})
```

### Interactive Lua Pattern Evaluation
This was completely unintended, but I found this plugin's incremental preview to also be also useful for interactive testing of lua patterns. Without a replacement value, the plugin evaluates `string.find()` and with a replacement value, it evaluates `string.gsub()`.

## Current Limitations
- `:substitution` flags other than `g` are not supported.
- The `ignorecase` and the `smartcase` option are ignored, the search is always
  casesensitive.
- `inccommand=split` is not supported, please use `inccommand=unsplit` instead.
- Line breaks in the search or the replacement value are not supported.
- Delimiters other than `/` are not supported yet. (You can make a PR to add
  them, the relevant functions are in the [process-parameters module](./lua/alt-substitute/process-parameters.lua))

## Add Support for more Regex Flavors
PRs adding support for more regex flavors, like for example javascript regex, are welcome. The plugin has been specifically built with extensibility in mind, so other regex flavors by only adding one search and one replace function. However, the bridging to other languages necessasitates some tricky escaping and performance optimization. 

Have a look this plugin's [regex module](./lua/alt-substitute/regex.lua) to see want needs to be implemented.

## Other Search-and-Replace Plugins
- [nvim-spectre](https://github.com/windwp/nvim-spectre)
- [serch-replace.nvim](https://github.com/roobert/search-replace.nvim)
- [replacer.nvim](https://github.com/gabrielpoca/replacer.nvim)
- [nvim-search-and-replace](https://github.com/s1n7ax/nvim-search-and-replace)

## Credits
<!-- vale Google.FirstPerson = NO -->
__About Me__  
In my day job, I am a sociologist studying the social mechanisms underlying the digital economy. For my PhD project, I investigate the governance of the app economy and how software ecosystems manage the tension between innovation and compatibility. If you are interested in this subject, feel free to get in touch.

__Profiles__  
- [reddit](https://www.reddit.com/user/pseudometapseudo)
- [Discord](https://discordapp.com/users/462774483044794368/)
- [Academic Website](https://chris-grieser.de/)
- [Twitter](https://twitter.com/pseudo_meta)
- [ResearchGate](https://www.researchgate.net/profile/Christopher-Grieser)
- [LinkedIn](https://www.linkedin.com/in/christopher-grieser-ba693b17a/)

__Buy Me a Coffee__  
<br>
<a href='https://ko-fi.com/Y8Y86SQ91' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>

[^1]: Frontier patterns are not mentioned in [neovim's respective section for lua patterns](https://neovim.io/doc/user/luaref.html#luaref-patterns). This is likely due to neovim using LuaJit, which itself is based on Lua 5.1, where [frontier patterns were still an undocumented feature](http://lua-users.org/lists/lua-l/2006-12/msg00536.html). But since frontier patterns are [officially documented in the most recent lua version](https://www.lua.org/manual/5.4/manual.html#6.4.1), it should be safe to assume that they are here to stay, so using them should not be an issue.
