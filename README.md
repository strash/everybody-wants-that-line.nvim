# Everybody wants that line
Minimalistic, informative and elegant statusline for neovim.

## Screenshots
### Examples
![screenshot](https://i.ibb.co/3ym5jsb/Group-14.png)

### What is what
![screenshot](https://i.ibb.co/GtLSRQg/Group-14-2.png)

## Features
- Adaptive colors
- Current buffer number and buffer modified flag
- LSP diagnostics
- Current git branch and git status (additions and deletions throughout current project)
- Current filename
- Clean ruler
- Global statusline or in each window
- Support for Quickfix List, Location List, Help
- Plugins:
	- Telescope,
	- Neogit,
	- Fugitive,
	- NvimTree
	- Packer,

## Installation
### [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use "strash/everybody-wants-that-line.nvim"
```
### [vim-plug](https://github.com/junegunn/vim-plug)
```lua
Plug "strash/everybody-wants-that-line.nvim"
```

## Configuration
These are the defaults.
```lua
-- if you ok with defaults
require("everybody-wants-that-line").setup()

-- if you hate defaults
require("everybody-wants-that-line").setup({
	buffer = {
		prefix = "b",
		-- symbol before buffer number, e.g. 00011.
		-- if you don't want additional symbols to be displayed, set "max_symbols" to 0
		symbol = "0",
		-- maximum number of symbols including buffer number
		max_symbols = 5,
	},
	-- a separator between blocks,
	-- e.g. ` b+ 00001 │ 0, 0, 0 │ main README.md │ ↓87%, →58, 47LOC `
	separator = "│",

})
```

## Contribution
If you found a bug please [open an issue](https://github.com/strash/everybody-wants-that-line.nvim/issues/new?assignees=&labels=bug&template=bug_report.md&title=) or [request a feature](https://github.com/strash/everybody-wants-that-line.nvim/issues/new?assignees=&labels=enhancement&template=feature_request.md&title=). All contributions are welcome! Just open a PR.

