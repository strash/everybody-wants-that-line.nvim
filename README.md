# Everybody wants that line
Minimalistic, informative and elegant statusline for neovim.
Plugin uses colors from your current colorscheme, so it looks natural.
It adapts if you change colorscheme or switch to a light or a dark theme.

https://user-images.githubusercontent.com/14233263/206051953-92085da0-a77d-4169-a087-d7d4e9837961.mp4

## Features
- Zero dependencies, lightweight and fast
- Adaptive colors
- Current buffer number and buffer modified flag
- LSP diagnostics
- Git branch and git status
- Filename
- Clean ruler
- Global statusline or per window
- Support: Netrw, Quickfix List, Location List (soon) and Help
- Basic support: Telescope, Neogit, Fugitive, Neo-tree, NvimTree, Buffer Manager, Lazy, Packer

## Installation
Neovim v0.7.0 and newer.

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
		show = true,
		prefix = "B:",
		-- Symbol before buffer number, e.g. "0000.".
		-- If you don't want additional symbols to be displayed, set `buffer.max_symbols = 0`.
		symbol = "0",
		-- Maximum number of symbols including buffer number.
		max_symbols = 5,
	},
	filepath = {
		-- `path` can be one of these:
		-- "tail" - file name only
		-- "relative" - relative to working directory
		-- "full" - full path to the file
		path = "relative",
		-- If `true` the path will be shortened, e.g. "/a/b/c/filename.lua".
		-- It only works if `path` is "relative" or "full".
		shorten = false,
	},
	filesize = {
		-- `metric` can be:
		-- "decimal" - 1000 bytes == 1 kilobyte
		-- "binary" - 1024 bytes == 1 kibibyte
		metric = "decimal"
	},
	-- Separator between blocks, e.g. " ... │ ... │ ... "
	separator = "│",
})
```

## Contribution
If you found a bug please [open an issue](https://github.com/strash/everybody-wants-that-line.nvim/issues/new?assignees=&labels=bug&template=bug_report.md&title=) or [request a feature](https://github.com/strash/everybody-wants-that-line.nvim/issues/new?assignees=&labels=enhancement&template=feature_request.md&title=). All contributions are welcome.

