vim.api.nvim_set_hl(0, "LineNr", { bg = "NONE" })
vim.api.nvim_set_hl(0, "SnacksPickerGitStatusUntracked", { fg = "#98c379" })

vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        vim.api.nvim_set_hl(0, "SnacksPickerGitStatusUntracked", { fg = "#98c379" })
    end,
})

return {
    {
        'folke/tokyonight.nvim',
        lazy = false,
        priority = 1000,
    },
    {
        'ellisonleao/gruvbox.nvim',
        lazy = false,
        priority = 1000,
        config = function()
            local theme_manager = require('utils.theme_manager')
            -- 設定自動儲存主題變更
            theme_manager.setup_auto_save()
            -- 載入上次選擇的主題
            theme_manager.apply_last_theme()
        end
    },
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        lazy = false,
        priority = 1000,
        config = function()
            require('catppuccin').setup({ flavour = 'frappe' })
        end
    },
    {
        'Mofiqul/dracula.nvim',
        lazy = false,
        priority = 1000,
    },
    {
        'rebelot/kanagawa.nvim',
        lazy = false,
        priority = 1000,
        config = function()
            require('kanagawa').setup({
                transparent = true
            })
        end
    },
    {
        'navarasu/onedark.nvim',
        lazy = false,
        priority = 1000,
        config = function()
            -- https://github.com/navarasu/onedark.nvim?tab=readme-ov-file#themes
            require('onedark').setup({
                style = 'warmer',
                transparent = true,
                lualine = {
                    transparent = true, -- lualine center bar transparency
                },
            })
        end
    }
}
