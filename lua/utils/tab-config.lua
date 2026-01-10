-- 自動檢測專案的 tab 配置並動態調整
local M = {}

-- 向上遍歷尋找配置文件
local function find_config_file(filenames)
    local current_dir = vim.fn.expand('%:p:h')

    for _, filename in ipairs(filenames) do
        local found = vim.fn.findfile(filename, current_dir .. ';')
        if found ~= '' then
            return found
        end
    end

    return nil
end

-- 讀取 prettier 配置
local function read_prettier_config(config_path)
    local file = io.open(config_path, 'r')
    if not file then
        return nil
    end

    local content = file:read('*all')
    file:close()

    -- 嘗試解析 JSON
    local ok, config = pcall(vim.fn.json_decode, content)
    if ok and config.tabWidth then
        return config.tabWidth
    end

    return nil
end

-- 讀取 editorconfig 配置
local function read_editorconfig(config_path)
    local file = io.open(config_path, 'r')
    if not file then
        return nil
    end

    local in_wildcard_section = false
    local indent_size = nil

    for line in file:lines() do
        -- 檢查是否進入 [*] 或 [*.{js,ts,vue,...}] section
        if line:match('^%[%*%]') or line:match('^%[%*%.') then
            in_wildcard_section = true
        elseif line:match('^%[') then
            in_wildcard_section = false
        end

        -- 在適當的 section 中讀取 indent_size
        if in_wildcard_section then
            local size = line:match('^indent_size%s*=%s*(%d+)')
            if size then
                indent_size = tonumber(size)
            end
        end
    end

    file:close()
    return indent_size
end

-- 主函數：檢測並設定 tab 寬度
function M.setup_tab_width()
    local tab_width = nil

    -- 優先檢查 .prettierrc
    local prettier_config = find_config_file({'.prettierrc', '.prettierrc.json', 'prettier.config.js'})
    if prettier_config and prettier_config:match('%.prettierrc%.?j?s?o?n?$') then
        tab_width = read_prettier_config(prettier_config)
    end

    -- 如果沒有找到 prettier 配置，檢查 .editorconfig
    if not tab_width then
        local editorconfig = find_config_file({'.editorconfig'})
        if editorconfig then
            tab_width = read_editorconfig(editorconfig)
        end
    end

    -- 如果找到配置，應用它
    if tab_width then
        vim.opt_local.tabstop = tab_width
        vim.opt_local.shiftwidth = tab_width
        vim.opt_local.softtabstop = tab_width
    end
    -- 否則使用全局預設值（2 個空格）
end

return M
