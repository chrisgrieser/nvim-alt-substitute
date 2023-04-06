# nvim-alt-substitute
A substitute of vim's ":substitute" that uses alternative regex flavors like lua or javascript instead of vim regex. Supports ranges and incremental preview.

<!-- vale Microsoft.Adverbs = NO --><!-- vale RedHat.Contractions = NO -->
Since you really don't want to learn a whole new flavor of regex, *just* to be able to make search-and-replace operations in your editor.

> __Note__  
> The plugin is still WIP and not fully usable yet.

<!--toc:start-->
- [Motivation](#motivation)
- [Features](#features)
- [Installation](#installation)
- [Configuration](#configuration)
- [Supported Regex Flavors](#supported-regex-flavors)
- [Limitations](#limitations)
- [Other Search-and-Replace Plugins](#other-search-and-replace-plugins)
- [Credits](#credits)
<!--toc:end-->

## Motivation
<!-- vale Google.FirstPerson = NO -->
Many people like me have only started (neo)vim after the introduction of lua of configuration language. While pretty much everything about neovim can be done with lua by now, search-and-replace-operations `:substitute` are one of few areas remaining where you still have to use vimscript. 

Regardless whether you like vimscript or not, learning vim's flavor of regex *just* for search-and-replace-operations feels somewhat unproductive and frustrating. So why not work with a regex flavor you are already familiar with instead?

## Features
- Use `:AltSubstitute` or the short form `:S` to do perform search-and-replace
  operations, in lua patterns or javascript regex.
- Supports ranges, if no range is given works on the entire buffer (`%` as range)
- The `g` flag is supported. Without the `g` flag, only the first match in a line is replaced, like `:substitute`.
- Incremental preview of the substitution.
- Support for more flavors is easy to add. [Pull Requests adding more regex flavors are welcome.](#supported-regex-flavors)

```lua
foo -> bar                      -- intended replacement
:%s /foo/bar/                   -- :substitute
:S /foo/bar/                    -- nvim-alt-substitute

deviceModel2020 -> deviceModel  -- intended replacement
:%s /\(\w\+\)\d\+/\1/g          -- :substitute
:S /(%w+)%d+/%1/g               -- nvim-alt-substitute (using lua flavor)
```

## Installation

```lua
-- packer
use {
	"chrisgrieser/nvim-alt-substitute",
	config = function() require("alt-substitute").setup({}) end,
}

-- lazy.nvim
{
	"chrisgrieser/nvim-alt-substitute",
	cmd = {"S", "AltSubstitute"},
  opts = true,
},
```

## Configuration

```lua
-- default values
opts = {
	regexFlavor = "lua", -- see below for supported flavors
	showNotification = true, -- whether to show the "x replacements made" notification
}
```

Note that any regex flavor other than `"lua"` requires the respective language support to be installed on your machine. `"javascript"`, for instance, requires `node`.

## Supported Regex Flavors

| flavor          | requirements |
|-----------------|--------------|
| `lua` (default) | \-           |
| `javascript`    | `node`       |

__Add Support for more flavors__  
The plugin has been specifically build with easy extensibility in mind. It should take no more than ~10 LoC to add support for more regex flavors. Have a look at [how javascript regex is supported](./lua/alt-substitute/regex/javascript.lua). [There is also a template you should use.](./lua/alt-substitute/regex/template.lua)

## Limitations
- Only the `g` flag is supported.
- Does not support `inccommand=split`. Please use `inccommand=unsplit` instead.

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
