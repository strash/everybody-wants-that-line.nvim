# Everybody wants that line
Minimalistic, informative and elegant statusline for neovim.
Plugin uses colors from your current colorscheme, so it looks natural.
It adapts if you change colorscheme or switch to a light or a dark theme.

https://user-images.githubusercontent.com/14233263/214998937-5f960f9a-3528-4ced-ab92-f16bee654400.mov

## Table of content
- [Features](#features)
- [Installation](#installation)
- [Configuration](#configuration)
- [Breaking changes](#breaking-changes)
- [Contribution](#contribution)

## Features
- Zero dependencies, lightweight and fast
- Adaptive colors
- Neat winbar
- Buffer number and modified flag
- LSP diagnostics
- Git branch and git status
- Filename
- Clean ruler
- Global statusline or per window
- Support: Netrw, Quickfix List, Location List (soon) and Help
- Plugin support:
	- [Telescope](https://github.com/nvim-telescope/telescope.nvim),
	- [Neogit](https://github.com/TimUntersberger/neogit),
	- [Fugitive](https://github.com/tpope/vim-fugitive),
	- [Neo-tree](https://github.com/nvim-neo-tree/neo-tree.nvim),
	- [NvimTree](https://github.com/nvim-tree/nvim-tree.lua),
	- [Buffer Manager](https://github.com/j-morano/buffer_manager.nvim),
	- [Dirbuf](https://github.com/elihunter173/dirbuf.nvim),
	- [Lazy](https://github.com/folke/lazy.nvim),
	- [Packer](https://github.com/wbthomason/packer.nvim)
	- If there is a plugin you'd like to see support for, please [request a feature](https://github.com/strash/everybody-wants-that-line.nvim/issues/new?assignees=&labels=enhancement&template=feature_request.md&title=)

## Installation
Neovim v0.7.0 and newer.

### [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
	"strash/everybody-wants-that-line.nvim",
	config = function()
		[your configuration here]
	end
}
```
### [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use "strash/everybody-wants-that-line.nvim"
```
### [vim-plug](https://github.com/junegunn/vim-plug)
```lua
Plug "strash/everybody-wants-that-line.nvim"
```

## Configuration
```lua
-- You can omit the config table
require("everybody-wants-that-line").setup()

-- or you can add it
require("everybody-wants-that-line").setup({
	buffer = {
		enabled = true,
		prefix = "B:",
		-- Placeholder before buffer number, e.g. "00001".
		-- If you don't want additional symbols to be displayed,
		-- set `symbol = ""` or `max_symbols = 0`.
		symbol = "0",
		-- Maximum number of symbols including buffer number.
		max_symbols = 5,
	},
	diagnostics = {
		enabled = true,
	},
	quickfix_list = {
		enabled = true,
	},
	git_status = {
		enabled = true,
	},
	filepath = {
		enabled = true,
		-- `path` can be one of these:
		-- "tail" - file name only
		-- "relative" - relative to working directory
		-- "full" - full path to the file
		path = "relative",
		-- If `true` a path will be shortened, e.g. "/a/b/c/filename.lua".
		-- It only works if `path` is "relative" or "full".
		shorten = false,
	},
	filesize = {
		enabled = true,
		-- `metric` can be:
		-- "decimal" - 1000 bytes == 1 kilobyte
		-- "binary" - 1024 bytes == 1 kibibyte
		metric = "decimal"
	},
	ruller = {
		enabled = true,
	},
	-- Filename is a separate widget that is located in the upper right corner
	of each open window.
	filename = {
		enabled = true,
	},
	-- Separator between components, e.g. " ... │ ... │ ... "
	separator = "│",
})
```

## Breaking changes
- [413944b](https://github.com/strash/everybody-wants-that-line.nvim/commit/413944baa987d129b9616bf4b75a766020b92678) 
`opts.buffer.show` is deprecated. Use `opts.buffer.enabled` instead.

## Contribution
If you found a bug please [open an issue](https://github.com/strash/everybody-wants-that-line.nvim/issues/new?assignees=&labels=bug&template=bug_report.md&title=) or [request a feature](https://github.com/strash/everybody-wants-that-line.nvim/issues/new?assignees=&labels=enhancement&template=feature_request.md&title=). All contributions are welcome.

