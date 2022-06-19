# Everybody wants that line
Actually minimalistic statusline for neovim

## Screenshots
![screenshot](https://i.ibb.co/MPvs5wL/Screen-Shot-2022-06-17-at-10-05-12.png)
Theme [zenbones.nvim](https://github.com/mcchrish/zenbones.nvim). Font **SF Mono**

![screenshot](https://i.ibb.co/p4d7zh2/Screen-Shot-2022-06-17-at-10-05-59.png)
Diagnostics in action. From left to right:
+ Errors count (first error line),
+ Warnings count (first warning line),
+ Infos and Hints count (first info or hint line)

![screenshot](https://i.ibb.co/LRSdFP5/Screen-Shot-2022-06-17-at-10-22-30.png)
Theme [vscode.nvim](https://github.com/Mofiqul/vscode.nvim)

![screenshot](https://i.ibb.co/ysZCjN3/Screen-Shot-2022-06-17-at-10-23-02.png)
Help

## Features
- [x] Adaptive colors
- [x] Current buffer number and buffer modified flag
- [x] LSP diagnostics
- [x] Current git branch
- [x] Current file
- [x] Clean ruller
- [x] Support for NvimTree, Help, Packer, Fugitive
- [ ] Support for Quickfix List, Location List, Prompt

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
require("everybody-wants-that-line").setup({
	buffer_number_symbol_count = 5,
	separator = "│",
})
```

