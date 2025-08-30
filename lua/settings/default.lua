return {
    { import = 'plugins.theme' },
    { import = 'plugins.lsp' },
    {
        'sindrets/diffview.nvim',
        config = function()
            require('diffview').setup {}
        end
    },
    {
        'DaikyXendo/nvim-material-icon',
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = function()
            require('nvim-web-devicons').setup({
                -- your personnal icons can go here (to override)
                -- you can specify color or cterm_color instead of specifying both of them
                -- DevIcon will be appended to `name`
                override = {
                    zsh = {
                        icon = "",
                        color = "#428850",
                        cterm_color = "65",
                        name = "Zsh"
                    }
                },

                -- globally enable different highlight colors per icon (default to true)
                -- if set to false all icons will have the default icon's color
                color_icons = true,
                -- globally enable default icons (default to false)
                -- will get overriden by `get_icons` option
                default = true,
            })
        end
    },
    {
        "romgrk/barbar.nvim",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            require("barbar").setup {}
        end
    },

    {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup({
                auto_hide = true,
            })
        end
    },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require('lualine').setup({
                options = {
                    disabled_filetypes = {
                        'NvimTree'
                    }
                }
            })
        end
    },
    {
        'nvim-tree/nvim-tree.lua',
        dependencies = {
            'nvim-tree/nvim-web-devicons',
            'DaikyXendo/nvim-material-icon',
        },
        config = function()
            require('nvim-tree').setup({
                view = {
                    side = 'left',
                    width = 30,
                },
                renderer = {
                    group_empty = true,
                    -- icons = {
                    --     show = { file = true, folder = true, folder_arrow = true, git = true },
                    --     glyphs = require('nvim-material-icon').get_icons(),
                    -- }
                },
                filters = {
                    dotfiles = false,
                },
                actions = {
                    open_file = {
                        quit_on_open = false,
                        window_picker = {
                            enable = true,
                        }
                    }
                },
                hijack_unnamed_buffer_when_opening = false,
                hijack_netrw = true,
                disable_netrw = true,
                update_focused_file = {
                    enable = true,
                    update_root = false,
                }
            })
            vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', {
                desc = 'Toggle file explorer'
            })
        end
    },
    {
        'nvim-telescope/telescope.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            { -- If encountering errors, see telescope-fzf-native README for installation instructions
                'nvim-telescope/telescope-fzf-native.nvim',

                -- `build` is used to run some command when the plugin is installed/updated.
                -- This is only run then, not every time Neovim starts up.
                build = 'make',

                -- `cond` is a condition used to determine whether this plugin should be
                -- installed and loaded.
                cond = function()
                    return vim.fn.executable 'make' == 1
                end,
            },
            { 'nvim-telescope/telescope-ui-select.nvim' },

            -- Useful for getting pretty icons, but requires a Nerd Font.
            { 'nvim-tree/nvim-web-devicons',            enabled = vim.g.have_nerd_font },

        },
        event = 'VimEnter',

        config = function()
            require('telescope').setup({
                defaults = {
                    file_ignore_patterns = {
                        '%.git/',
                        'node_modules/',
                        'dist/'
                    }
                },
                pickers = {
                    find_files = {
                        hidden = true -- include hidden files
                    }
                },
                extensions = {
                    ['ui-select'] = {
                        require('telescope.themes').get_dropdown() -- picker will be a dropdown instead of fullscreen list
                    }
                }
            })

            -- Enable Telescope extensions if they are installed
            pcall(require('telescope').load_extension, 'ui-select')
            pcall(require('telescope').load_extension, 'fzf')

            -- See `:help telescope.builtin`
            local builtin = require 'telescope.builtin'
            vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
            vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })

            -- vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
            -- vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
            -- vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
            -- vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
            -- vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
            -- vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
            -- vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
            -- vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

            local Path = require('plenary.path')
            local function open_file(filename)
                local p = Path:new(filename)
                if not p:exists() then
                    p:touch({ parents = true })
                end
                vim.cmd('edit ' .. filename)
            end
            vim.api.nvim_create_user_command('NewFile', open_file, {})
            vim.keymap.set('n', '<leader>nf', open_file, { desc = 'Create new file' })
        end
    },
    {
        'windwp/nvim-autopairs',
        event = 'InsertEnter',
        config = true,
        -- use opts = {} for passing setup options
        -- this is equalent to setup({}) function
    },
    {                       -- Useful plugin to show you pending keybinds.
        'folke/which-key.nvim',
        event = 'VimEnter', -- Sets the loading event to 'VimEnter'
        config = function() -- This is the function that runs, AFTER loading
            require('which-key').setup()

            -- Document existing key chains
            require('which-key').register {
                ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
                ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
                ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
                ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
                ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
                ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
                ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
            }
            -- visual mode
            require('which-key').register({
                ['<leader>h'] = { 'Git [H]unk' },
            }, { mode = 'v' })
        end,
    },
    {
        'tpope/vim-fugitive',
        cmd = { 'Git', 'G' }
    },
    {
        'kylechui/nvim-surround',
        version = "*",
        event = "VeryLazy",
        config = function()
            require('nvim-surround').setup({})
        end
    }
}
