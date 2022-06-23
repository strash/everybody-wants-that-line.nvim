# Everybody wants that line
Actually minimalistic statusline for neovim

## Screenshots
![screenshot](https://i.ibb.co/tJpW79G/Screen-Shot-2022-06-19-at-20-32-59.png)
Theme [zenbones.nvim](https://github.com/mcchrish/zenbones.nvim). Font **SF Mono**

![screenshot](https://i.ibb.co/YpJCM1H/Screen-Shot-2022-06-19-at-20-33-26.png)
Diagnostics in action. From left to right:
+ Errors count (first error line),
+ Warnings count (first warning line),
+ Infos and Hints count (first info or hint line)

![screenshot](https://i.ibb.co/HH7T7GP/Screen-Shot-2022-06-19-at-20-34-29.png)
Theme [vscode.nvim](https://github.com/Mofiqul/vscode.nvim)

![screenshot](https://i.ibb.co/34NqFPb/Screen-Shot-2022-06-19-at-20-35-31.png)
Help

## Features
- [x] Adaptive colors
- [x] Current buffer number and buffer modified flag
- [x] LSP diagnostics
- [x] Current git branch
- [x] Current file
- [x] Clean ruler
- [x] Support for NvimTree, Help, Packer, Fugitive
- [ ] Support for Quickfix List, Location List, Prompt
- [ ] Support for StatusLineNC (if multiple statuslines)

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
```lua
local that_line = require("everybody-wants-that-line")

that_line.setup({
	buffer = {
		symbol = "0",
		max_symbols = 5,
	},
	separator = "│",
})
```

