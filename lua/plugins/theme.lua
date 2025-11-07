vim.api.nvim_set_hl(0, "LineNr", { bg = "NONE" })
return {
    {
        'folke/tokyonight.nvim',
        priority = 10,
        config = function()
            vim.cmd('colorscheme tokyonight')
        end
    },
    {
        'ellisonleao/gruvbox.nvim',
        priority = 1000,
        config = function()
            vim.cmd('colorscheme gruvbox')
        end
    },
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        priority = 50,
        config = function()
            require('catppuccin').setup({ flavour = 'frappe' })
            vim.cmd('colorscheme catppuccin')
        end
    },
    {
        'Mofiqul/dracula.nvim',
        priority = 150,
        config = function()
            vim.cmd('colorscheme dracula')
        end
    },
    {
        'rebelot/kanagawa.nvim',
        priority = 1,
        config = function()
            require('kanagawa').setup({
                transparent = true
            })
            vim.cmd('colorscheme kanagawa')
        end
    },
    {
        'navarasu/onedark.nvim',
        priority = 100,
        config = function()
            require('onedark').setup({
                style = 'darker',
                transparent = true,
                lualine = {
                    transparent = true, -- lualine center bar transparency
                },

            })
            require('onedark').load()
        end
    }
}
