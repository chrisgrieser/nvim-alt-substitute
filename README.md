# nvim-sane-substitute 😌
A substitute of vim's :substitute that uses lua pattern or javascript regex instead of vim regex. Supports ranges and incremental preview.

<!-- vale Microsoft.Adverbs = NO --><!-- vale RedHat.Contractions = NO -->
Since you really don't want to learn a whole new flavor of regex, *just* to be able to make search-and-replace operations in your editor.

> __Note__  
> The plugin is still WIP and not fully usable yet.

<!--toc:start-->
- [Features](#features)
- [Installation](#installation)
- [Configuration](#configuration)
- [Supported Regex Flavors](#supported-regex-flavors)
- [Limitations](#limitations)
- [Credits](#credits)
<!--toc:end-->

## Features
- Use `:SaneSubstitute` or the short form `:S` to do perform search-and-replace
  operations, in lua patterns or javascript regex.
- Supports ranges, if no range is given works on the entire buffer (`%` as range)
- The `g` flag is supported. Without the `g` flag, only the first match in a line is replaced, like `:substitute`.
- Incremental preview of the substitution.
- Support for more flavors is easy to add. [Pull Requests adding more regex flavors are welcome.](#supported-regex-flavors)

```lua
foo -> bar                      -- intended replacement
:%s /foo/bar/                   -- :substitute
:S foo/bar                      -- nvim-sane-substitute

deviceModel2020 -> deviceModel  -- intended replacement
:%s /\(\w\+\)\d\+/\1/g          -- :substitute
:S (%w+)%d+/%1/g                -- nvim-sane-substitute (using lua flavor)
```

## Installation

```lua
-- packer
use {
	"chrisgrieser/nvim-sane-substitute",
	config = function() require("sane-substitute").setup({}) end,
}

-- lazy.nvim
{
	"chrisgrieser/nvim-sane-substitute",
	cmd = {"S", "SaneSubstitute"},
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
The plugin has been specifically build with easy extensibility in mind. It should take no more than ~10 LoC to add support for more regex flavors. Have a look at [how javascript regex is supported](./lua/sane-substitute/regex/javascript.lua). [There is also a template you should use.](./lua/sane-substitute/regex/template.lua)

## Limitations
- Only the `g` flag is supported.
- Does not support `inccommand=split`. Please use `inccommand=unsplit` instead.

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
