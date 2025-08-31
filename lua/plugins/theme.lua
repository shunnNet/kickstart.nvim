return {
    {
        'folke/tokyonight.nvim',
        priority = 1000,
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
        priority = 1000,
        config = function()
            require('catppuccin').setup({ flavour = 'frappe' })
            vim.cmd('colorscheme catppuccin')
        end
    },
    {
        'Mofiqul/dracula.nvim',
        priority = 1000,
        config = function()
            vim.cmd('colorscheme dracula')
        end
    },
    {
        'rebelot/kanagawa.nvim',
        priority = 300,
        config = function()
            require('kanagawa').setup({
                transparent = true
            })
            vim.cmd('colorscheme kanagawa')
        end
    },
    {
        'navarasu/onedark.nvim',
        priority = 1000,
        config = function()
            require('onedark').setup({
                style = 'darker',
                transparent = true,
            })
            require('onedark').load()
        end
    }
}
