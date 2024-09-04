-- colors
local C      = require("everybody-wants-that-line.colors")
-- components
local CB     = require("everybody-wants-that-line.components.buffer")
local CD     = require("everybody-wants-that-line.components.diagnostics")
local CE     = require("everybody-wants-that-line.components.elements")
local CG     = require("everybody-wants-that-line.components.git")
local CN     = require("everybody-wants-that-line.components.filename")
local CP     = require("everybody-wants-that-line.components.filepath")
local CQ     = require("everybody-wants-that-line.components.qflist")
-- settings
local S      = require("everybody-wants-that-line.settings")
-- utils
local Math   = require("everybody-wants-that-line.utils.math")
local String = require("everybody-wants-that-line.utils.string")
local Window = require("everybody-wants-that-line.utils.window")

local M      = {}

---Returns separator
---@return string
function M.separator()
    return CE.get_separator(CE.with_offset(S.opt.separator))
end

---Returns styled text
---@param text string
---@return string
function M.title(text)
    return C.highlight_text(text, C.group_names.fg_60_bold)
end

---Returns bold text
---@param text string
---@return string
function M.bold(text)
    return C.highlight_text(text, C.group_names.fg_bold)
end

---Returns buffer
---@return string
function M.get_buffer()
    local buffer = ""
    if S.opt.buffer.enabled == true then
        local bufnr_item = CB.get_buf_nr(S.opt.buffer)
        buffer = CB.get_buffer_symbol(S.opt.buffer.prefix) .. bufnr_item.result .. CB.get_buf_modflag()
    end
    return buffer
end

---comment
---@param diagnostic_object diagnostic_object
---@param count_group_name string
---@param arrow_group_name string
---@param lnum_group_name string
---@return string
local function highlight_diagnostic(diagnostic_object, count_group_name, arrow_group_name, lnum_group_name)
    local row = vim.api.nvim_win_get_cursor(vim.fn.win_getid())[1]
    local arrow = CE.el.arrow_down
    if row > diagnostic_object.first_lnum then
        arrow = CE.el.arrow_up
    elseif row == diagnostic_object.first_lnum then
        arrow = CE.el.arrow_right
    end
    return table.concat({
        C.highlight_text(tostring(diagnostic_object.count), count_group_name),
        C.highlight_text(arrow, arrow_group_name),
        C.highlight_text(tostring(diagnostic_object.first_lnum), lnum_group_name),
    })
end

---Returns diagnostics
---@return string
function M.get_diagnostics()
    local result = ""
    if S.opt.diagnostics.enabled == true then
        local diagnostics = CD.get_diagnostics()
        local err, warn, hint, info = "0", "0", "0", "0"
        if diagnostics.error.count > 0 then
            err = highlight_diagnostic(
                diagnostics.error,
                C.group_names.fg_error_bold,
                C.group_names.fg_error_50,
                C.group_names.fg_error
            )
        end
        if diagnostics.warn.count > 0 then
            warn = highlight_diagnostic(
                diagnostics.warn,
                C.group_names.fg_warn_bold,
                C.group_names.fg_warn_50,
                C.group_names.fg_warn
            )
        end
        if diagnostics.hint.count > 0 then
            hint = highlight_diagnostic(
                diagnostics.hint,
                C.group_names.fg_hint_bold,
                C.group_names.fg_hint_50,
                C.group_names.fg_hint
            )
        end
        if diagnostics.info.count > 0 then
            info = highlight_diagnostic(
                diagnostics.info,
                C.group_names.fg_info_bold,
                C.group_names.fg_info_50,
                C.group_names.fg_info
            )
        end
        result = String.join({ err, warn, hint, info }, CE.get_comma() .. CE.el.space)
    end
    return result
end

---Returns branch name
---@return string
function M.get_branch_name()
    local result = ""
    if S.opt.git_status.enabled == true then
        if #CG.cache.branch ~= 0 then
            result = CG.cache.branch
        end
    end
    return result
end

---Returns branch and git status
---@return string
function M.get_branch_status()
    local result = ""
    if S.opt.git_status.enabled == true then
        local insertions = ""
        local deletions = ""
        if CG.cache.diff_info.insertions ~= 0 then
            insertions = C.highlight_text(tostring(CG.cache.diff_info.insertions), C.group_names.fg_diff_add_bold) ..
                CE.get_plus("50")
        end
        if CG.cache.diff_info.deletions ~= 0 then
            deletions = C.highlight_text(tostring(CG.cache.diff_info.deletions), C.group_names.fg_diff_delete_bold) ..
                CE.get_minus("50")
        end
        result = String.join({ insertions, deletions }, CE.el.space)
    end
    return result
end

---Returns path to the file
---@return string
function M.get_filepath()
    local result = ""
    if S.opt.filepath.enabled == true then
        local path_parts = CP.get_filepath(vim.api.nvim_get_current_buf())
        result = "[No name]"
        if #path_parts.relative.path ~= 0 and #path_parts.full.path ~= 0 then
            local filename = M.bold(path_parts.relative.filename)
            if S.opt.filepath.path == "tail" then
                result = filename
            elseif S.opt.filepath.path == "relative" then
                local relative = S.opt.filepath.shorten and path_parts.relative.shorten or path_parts.relative.path
                result = C.highlight_text(relative, C.group_names.fg_60) .. filename
            elseif S.opt.filepath.path == "full" then
                local full = S.opt.filepath.shorten and path_parts.full.shorten or path_parts.full.path
                result = C.highlight_text(full, C.group_names.fg_60) .. filename
            end
        end
        result = CE.el.truncate .. result
    end
    return result
end

---Returns netrw directory
---@param name string
---@return string
function M.get_treedir(name)
    return CE.spaced_text(
        String.join({
            M.title(name),
            vim.api.nvim_buf_get_name(0)
        }, CE.el.space)
    )
end

---Returns quickfix list
---@return string
function M.get_quickfix()
    local result = ""
    local idx = M.bold(tostring(CQ.get_qflist_idx()))
    local entries_count = CQ.get_entries_count()
    local files_count = CQ.get_files_w_entries_count()
    if tonumber(CQ.get_qflist_winid()) == tonumber(vim.api.nvim_get_current_win()) then
        local text_in = C.highlight_text("in", C.group_names.fg_60)
        local text_file = C.highlight_text(files_count > 1 and "files" or "file", C.group_names.fg_60)
        local text_of = C.highlight_text("of", C.group_names.fg_60)
        result = CE.spaced_text(String.join({
            M.title("Quickfix List"),
            idx,
            text_of,
            entries_count,
            (files_count ~= 0 and String.join({ text_in, files_count, text_file }, CE.el.space) or ""),
        }, CE.el.space))
    else
        if S.opt.quickfix_list.enabled == true then
            if Window.laststatus() == 3 and not CQ.is_qflist_empty() then
                local text_slash = C.highlight_text("/", C.group_names.fg_60)
                result = M.title("QF: ") .. idx .. text_slash .. entries_count
            end
        end
    end
    return result
end

---Returns help filename
---@return string
function M.get_help()
    local help = M.title("Help")
    ---@type string
    local buff_name = vim.api.nvim_buf_get_name(0)
    return CE.spaced_text({
        help,
        CE.el.space,
        buff_name:match("[%s%w_]-%.%w-$")
    })
end

---Returns file size
---@return string
function M.get_filesize()
    local result = ""
    if S.opt.filesize.enabled == true then
        ---@type file_size
        local size
        if S.opt.filesize.metric == "decimal" then
            size = Math.decimal_file_size()
        elseif S.opt.filesize.metric == "binary" then
            size = Math.binary_file_size()
        end
        result = size.size .. C.highlight_text(size.suffix, C.group_names.fg_50)
    end
    return result
end

---Returns ruller
---@param show_ln boolean
---@param show_col boolean
---@param show_loc boolean
---@return string
function M.get_ruller(show_ln, show_col, show_loc)
    local result = ""
    if S.opt.ruller.enabled == true then
        local comma_space = CE.get_comma() .. CE.el.space
        result = table.concat({
            show_ln and CE.get_ln() .. comma_space or "",
            show_col and CE.get_col() .. comma_space or "",
            show_loc and CE.get_loc() or "",
        })
    end
    return result
end

---Helper. Creates auto command
---@param events string[]
---@param group string
---@param callback function
local function create_autocmd(events, group, callback)
    vim.api.nvim_create_autocmd(events, {
        pattern = "*",
        callback = callback,
        group = group,
    })
end

---Helper. Creates user auto command
---@param event string
---@param group string
---@param callback function
local function create_user_autocmd(event, group, callback)
    vim.api.nvim_create_autocmd('User', {
        pattern = event,
        callback = callback,
        group = group,
    })
end

---@class event_args
---@field buf number
---@field event string
---@field file string
---@field group number
---@field id number
---@field match string

---Sets auto commands
---@param cb function
local function setup_autocmd(cb)
    ---@type string
    local autocmd_group = vim.api.nvim_create_augroup(Window.prefix .. "Group", { clear = true })

    -- colors
    create_autocmd({ "ColorScheme" }, autocmd_group, function()
        C.init()
        cb()
    end)

    -- file name
    create_autocmd({
        "BufWinEnter",
        "VimResized",
        "WinClosed",
        "WinLeave",
        "WinScrolled",
    }, autocmd_group, function(args)
        if S.opt.filename.enabled == true then
            CN.set_filename(args)
        end
    end)

    --create_autocmd({
    --	"ModeChanged",
    --}, autocmd_group, function(args)
    --	vim.pretty_print(args)
    --end)

    -- buffer number
    -- buffer modified flag
    -- diagnostics
    create_autocmd({
        "BufAdd",
        "BufModifiedSet",
        "CursorMoved",
        "DiagnosticChanged",
    }, autocmd_group, function()
        cb()
    end)

    -- buffer number
    -- branch name
    create_autocmd({
        "BufEnter",
        "BufWinEnter",
    }, autocmd_group, function()
        CG.set_git_branch()
        CQ.set_qflist()
        cb()
    end)

    -- diff info
    create_autocmd({
        "BufReadPost",
        "BufWritePost",
    }, autocmd_group, function()
        CG.set_diff_info()
        cb()
    end)

    -- branch name
    -- diff info
    create_autocmd({
        "FocusGained",
        "VimEnter",
    }, autocmd_group, function()
        CG.set_git_branch()
        CG.set_diff_info()
        cb()
    end)

    -- quickfix list
    create_autocmd({
        "QuickFixCmdPost",
    }, autocmd_group, function()
        CQ.set_qflist()
        cb()
    end)

    -- neogit commit complete
    create_user_autocmd("NeogitCommitComplete", autocmd_group, function()
        CG.set_diff_info()
        cb()
    end)

    -- neogit push complete
    create_user_autocmd("NeogitPushComplete", autocmd_group, function()
        CG.set_diff_info()
        cb()
    end)
end

---Init controller
---@param opts opts
---@param cb function
function M.init(opts, cb)
    S.setup(opts)
    C.init()
    setup_autocmd(cb)
    cb()
end

return M
