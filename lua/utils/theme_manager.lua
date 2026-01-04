local M = {}

-- 取得主題設定檔路徑
local function get_theme_file()
    local data_path = vim.fn.stdpath('data')
    return data_path .. '/last_colorscheme.txt'
end

-- 儲存主題選擇
function M.save_theme(colorscheme)
    local file = get_theme_file()
    local f = io.open(file, 'w')
    if f then
        f:write(colorscheme)
        f:close()
    end
end

-- 讀取上次的主題選擇
function M.load_theme()
    local file = get_theme_file()
    local f = io.open(file, 'r')
    if f then
        local colorscheme = f:read('*line')
        f:close()
        return colorscheme
    end
    -- 如果檔案不存在,返回預設主題
    return 'gruvbox'
end

-- 設定主題並儲存
function M.set_theme(colorscheme)
    -- 嘗試設定主題
    local ok, err = pcall(vim.cmd, 'colorscheme ' .. colorscheme)
    if ok then
        -- 成功則儲存
        M.save_theme(colorscheme)
    else
        vim.notify('Failed to load colorscheme: ' .. colorscheme, vim.log.levels.ERROR)
    end
end

-- 載入並應用上次的主題
function M.apply_last_theme()
    local last_theme = M.load_theme()
    local ok, err = pcall(vim.cmd, 'colorscheme ' .. last_theme)
    if not ok then
        -- 如果上次的主題載入失敗,使用預設主題
        vim.cmd('colorscheme gruvbox')
    end
end

-- 設定自動儲存主題變更
function M.setup_auto_save()
    -- 建立 autocmd 來監聽主題變更
    vim.api.nvim_create_autocmd('ColorScheme', {
        pattern = '*',
        callback = function()
            -- 取得當前主題名稱
            local colorscheme = vim.g.colors_name
            if colorscheme then
                M.save_theme(colorscheme)
            end
        end,
    })
end

return M
