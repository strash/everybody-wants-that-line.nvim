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
- Support for Quickfix List, Location List, Help
- Support for Telescope, Packer, Fugitive, NvimTree
- Support for global and multiple StatusLines

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
local that_line = require("everybody-wants-that-line")

that_line.setup({
	buffer = {
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

