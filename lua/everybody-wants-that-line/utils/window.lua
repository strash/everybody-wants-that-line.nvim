local Window = {}

Window.prefix = "EverybodyWantsThatLine"

---Static. Check if statusline on focused window
---@return boolean
function Window.is_focused()
    if Window.laststatus() == 3 then
        return true
    end
    return tonumber(vim.g.actual_curwin) == tonumber(vim.api.nvim_get_current_win())
end

---Static. Returns current buffer number
---@return integer
function Window.get_bufnr()
    local bufnr = 0
    if Window.laststatus() == 3 then
        bufnr = tonumber(vim.api.nvim_get_current_buf()) or 0
    else
        if Window.is_focused() then
            bufnr = tonumber(vim.g.actual_curbuf) or 0
        else
            bufnr = tonumber(vim.api.nvim_get_current_buf()) or 0
        end
    end
    return bufnr
end

---Static. Check if window valid
---@param win_id integer
---@return boolean
function Window.is_win_valid(win_id)
    return win_id ~= nil and vim.api.nvim_win_is_valid(win_id)
end

---@alias laststatus
---| 0 #never
---| 1 #only if there are at least two windows
---| 2 #always
---| 3 #always and ONLY the last window

---Static. Returns `laststatus`
---@return laststatus
function Window.laststatus()
    return vim.o.laststatus
end

---@alias vim_wintype
---| ""         # normal window (or NvimTree)
---| "autocmd"  # autocommand window. Temporary window used to execute autocommands
---| "command"  # command-line window `cmdwin`
---| "loclist"  # `location-list-window`
---| "popup"    # popup window `popup`
---| "preview"  # preview window `preview-window`
---| "quickfix" # `quickfix-window`
---| "unknown"  # window `{nr}` not found

---@alias vim_buftype
---| ""         # normal buffer
---| "acwrite"  # buffer will always be written with `BufWriteCmd`s
---| "help"     # help buffer (do not set this manually)
---| "nofile"   # buffer is not related to a file, will not be written (NvimTree)
---| "nowrite"  # buffer will not be written
---| "prompt"   # buffer where only the last line can be edited, meant to be used by a plugin, see `prompt-buffer`
---| "quickfix" # list of errors `:cwindow` or locations `:lwindow`
---| "terminal" # `terminal-emulator` buffer

---@alias wintype
---| "unknown"
---| "normal"
---| "loclist"
---| "quickfix"
---| "preview"
---| "help"
---| "netrw"
---| "lazy"           # folke/lazy.nvim
---| "packer"         # wbthomason/packer.nvim
---| "neogit"         # TimUntersberger/neogit
---| "fugitive"       # tpope/vim-fugitive
---| "telescope"      # nvim-telescope/telescope.nvim
---| "buffer_manager" # j-morano/buffer_manager.nvim
---| "nvimtree"       # nvim-tree/nvim-tree.lua
---| "neo-tree"       # nvim-neo-tree/neo-tree.nvim
---| "dirbuf"         # elihunter173/dirbuf.nvim

---Static. Returns window type
---@param win_id integer|nil
---@return wintype enum
function Window.get_wintype(win_id)
    win_id = win_id or (tonumber(vim.fn.win_getid()) or 0)
    ---@type vim_wintype
    local vim_wintype = vim.fn.win_gettype(win_id)
    ---@type vim_buftype
    local buftype = vim.o.buftype
    ---@type string
    local filetype = vim.o.filetype

    ---@type wintype
    local wintype = "unknown"

    if vim_wintype == "" or vim_wintype == "popup" then
        if buftype == "" then
            if filetype == "netrw" then
                wintype = "netrw"
            else
                wintype = "normal"
            end
        elseif buftype == "nofile" then
            if filetype == "NvimTree" then
                wintype = "nvimtree"
            elseif filetype == "neo-tree" then
                wintype = "neo-tree"
            elseif filetype == "packer" then
                wintype = "packer"
            elseif filetype:find("Neogit") ~= nil then
                wintype = "neogit"
            elseif filetype == "lazy" then
                wintype = "lazy"
            else
                wintype = "unknown"
            end
        elseif buftype == "prompt" then
            if filetype:find("Telescope") ~= nil then
                wintype = "telescope"
            end
        elseif buftype == "nowrite" then
            if filetype == "fugitive" then
                wintype = "fugitive"
            end
        elseif buftype == "help" then
            wintype = "help"
        elseif buftype == "acwrite" then
            if filetype == "dirbuf" then
                wintype = "dirbuf"
            elseif filetype == "buffer_manager" then
                wintype = "buffer_manager"
            end
        end
    elseif vim_wintype == "loclist" then
        wintype = "loclist"
    elseif vim_wintype == "quickfix" then
        wintype = "quickfix"
    elseif vim_wintype == "preview" then
        wintype = "preview"
    end

    -- for debug
    --vim.api.nvim_notify(
    --	"vim wintype '" .. vim_wintype ..
    --	"', buftype '" .. buftype ..
    --	"', filetype '" .. filetype ..
    --	"', wintype '" .. wintype .. "'",
    --	vim.log.levels.INFO,
    --{})
    return wintype
end

return Window
