local function is_diagnostic_float(winid)
    local buf = vim.api.nvim_win_get_buf(winid)
    local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
    local config = vim.api.nvim_win_get_config(winid)
    -- print(buftype, config.relative, config.style, config.title)

    return buftype == "nofile" and config.relative == 'win'
end

local function close_float_windows()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if is_diagnostic_float(win) then
            vim.api.nvim_win_close(win, true)
        end
    end
end



vim.api.nvim_create_autocmd('BufLeave', {
    callback = function()
        -- prevent diagnostic float window stuck after switch buffer
        close_float_windows()
    end
})
