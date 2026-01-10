-- vim.notify('Test notify message', vim.log.levels.ERROR)

-- vim.print("Test", { A = 123 })
--

--[[ local group = vim.api.nvim_create_augroup('User', { clear = true })
-- { clear = true } 的作用等同於 Vimscript 中的 :autocmd!，
-- 確保每次載入時都會清除此群組中的舊定義。

vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    pattern = "*",
    callback = function()
        local name = vim.api.nvim_buf_get_name(0)
        vim.notify('Successfully saved: ' .. name)
    end
}) ]]

local function get_file_size()
    local path = vim.fn.expand("%:p") -- make path absolute
    local fsize = vim.fn.getfsize(path)

    local units = { 'B', 'KiB', 'MiB', 'GiB', 'TiB' }
    local i = 0

    while fsize >= 1024 and i < #units - 1 do
        fsize = fsize / 1024
        i = i + 1
    end

    -- 格式化輸出，保留兩位小數 (%.2f %s)
    return string.format("%.0f %s", fsize, units[i + 1])
end


vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })

-- require('plugins.coc')

return {
    { import = 'plugins.theme' },
    { import = 'kickstart.plugins.gitsigns' },
    { import = 'plugins.lsp' },
    -- {
    --     'neoclide/coc.nvim',
    --     branch = 'release',
    -- },
    {
        'stevearc/conform.nvim',
        opts = {
            formatters_by_ft = {
                javascript = { 'prettier' },
                typescript = { 'prettier' },
                vue = { 'prettier' },
                json = { 'prettier' },
                markdown = { 'prettier' },
                html = { 'prettier' }
            },
            format_on_save = {
                lsp_fallback = true,
                async = false,
                timeout_ms = 500,
            }
        }
    },

    {
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim" },
        opts = {
            terminal_cmd = "~/.claude/local/claude", -- Point to local installation
            terminal = {
                ---@module "snacks"
                ---@type snacks.win.Config|{}
                snacks_win_opts = {
                    position = "float",
                    width = 0.9,
                    height = 0.9,
                    keys = {
                        claude_hide = {
                            "<C-,>",
                            function(self)
                                self:hide()
                            end,
                            mode = "t",
                            desc = "Hide",
                        },
                    },
                },
            },
        },

        config = true,
        keys = {

            { "<C-,>",      "<cmd>ClaudeCodeFocus<cr>",       desc = "Claude Code",        mode = { "n", "x" } },
            { "<leader>a",  nil,                              desc = "AI/Claude Code" },
            { "<leader>ac", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude" },
            { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
            { "<leader>ar", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
            { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
            { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
            { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add current buffer" },
            { "<leader>as", "<cmd>ClaudeCodeSend<cr>",        mode = "v",                  desc = "Send to Claude" },
            {
                "<leader>as",
                "<cmd>ClaudeCodeTreeAdd<cr>",
                desc = "Add file",
                ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
            },
            -- Diff management
            { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
            { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Deny diff" },
            -- Your keymaps here
        },
    },
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        ---@type snacks.Config
        opts = {
            bigfile = { enabled = true },
            dashboard = { enabled = true },
            explorer = { enabled = true, follow_file = false },
            indent = { enabled = true },
            input = { enabled = true },
            notifier = {
                enabled = true,
                timeout = 3000,
            },
            picker = {
                layout = "default", -- 或 "vertical" / "horizontal"
                -- win = {
                --     height = 20,
                --     preview = true,
                -- },
            },
            -- picker = { enabled = true },
            quickfile = { enabled = true },
            scope = { enabled = true },
            scroll = {
                enabled = true,
                animate = {
                    duration = { step = 10, total = 100 },
                    easing = "linear",
                },
            },

            statuscolumn = { enabled = true },
            words = { enabled = true },
            -- styles = {
            --     wo = {
            --         colorcolumn = "",
            --         cursorcolumn = false,
            --         cursorline = false,
            --         foldmethod = "manual",
            --         list = false,
            --         number = false,
            --         relativenumber = false,
            --         sidescrolloff = 0,
            --         signcolumn = "no",
            --         spell = false,
            --         statuscolumn = "",
            --         statusline = "",
            --         winbar = "",
            --         -- winhighlight = "Normal:SnacksDashboardNormal,NormalFloat:SnacksDashboardNormal",
            --         wrap = false,
            --     },
            -- },
            -- win = {
            -- 	position = "float",
            -- 	backdrop = 10,
            -- 	height = 0.9,
            -- 	width = 0.9,
            -- 	zindex = 50,
            -- }
        },
        keys = {
            -- -- Top Pickers & Explorer
            -- { "<leader><space>", function() Snacks.picker.smart() end,                                   desc = "Smart Find Files" },
            { "<leader>,",  function() Snacks.picker.buffers() end,                  desc = "Buffers" },
            { "<leader>/",  function() Snacks.picker.grep() end,                     desc = "Grep" },

            { "<leader>:",  function() Snacks.picker.command_history() end,          desc = "Command History" },
            -- { "<leader>n",       function() Snacks.picker.notifications() end,                           desc = "Notification History" },
            { "<leader>e",  function() Snacks.explorer({ follow_file = false }) end, desc = "File Explorer" },
            -- -- find
            { "<leader>fb", function() Snacks.picker.buffers() end,                  desc = "Buffers" },
            { "<leader>fg", function() Snacks.picker.grep() end,                     desc = "Grep" },
            {
                "<leader>ff",
                function()
                    Snacks.picker.files({
                        cmd = "rg"
                    })
                end,
                desc = "Find Files"
            },
            {
                "<leader>sf",
                function()
                    Snacks.picker.files({
                        cmd = "rg"
                    })
                end,
                desc = "Find Files"
            },

            -- { "<leader>fg", function() Snacks.picker.git_files() end,             desc = "Find Git Files" },
            { "<leader>fp", function() Snacks.picker.projects() end,                                desc = "Projects" },
            { "<leader>fr", function() Snacks.picker.recent() end,                                  desc = "Recent" },
            { "<leader>fs", function() Snacks.picker.lsp_symbols() end,                             desc = "LSP Symbols" },
            { "<leader>fS", function() Snacks.picker.lsp_workspace_symbols() end,                   desc = "LSP Workspace Symbols" },
            { "<leader>fc", function() Snacks.picker.commands() end,                                desc = "Commands" },
            { "<leader>sc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
            -- git
            -- { "<leader>gb", function() Snacks.picker.git_branches() end,          desc = "Git Branches" },
            -- { "<leader>gl", function() Snacks.picker.git_log() end,               desc = "Git Log" },
            -- { "<leader>gL", function() Snacks.picker.git_log_line() end,          desc = "Git Log Line" },
            -- { "<leader>gs", function() Snacks.picker.git_status() end,            desc = "Git Status" },
            -- { "<leader>gS", function() Snacks.picker.git_stash() end,             desc = "Git Stash" },
            -- { "<leader>gd", function() Snacks.picker.git_diff() end,              desc = "Git Diff (Hunks)" },
            -- { "<leader>gf", function() Snacks.picker.git_log_file() end,          desc = "Git Log File" },
            -- Grep
            -- { "<leader>sb", function() Snacks.picker.lines() end,                 desc = "Buffer Lines" },
            -- { "<leader>sB", function() Snacks.picker.grep_buffers() end,          desc = "Grep Open Buffers" },
            -- { "<leader>sg", function() Snacks.picker.grep() end,                  desc = "Grep" },
            -- { "<leader>sw", function() Snacks.picker.grep_word() end,             desc = "Visual selection or word", mode = { "n", "x" } },
            -- search
            { '<leader>s"', function() Snacks.picker.registers() end,                               desc = "Registers" },
            { '<leader>s/', function() Snacks.picker.search_history() end,                          desc = "Search History" },
            -- { "<leader>sa", function() Snacks.picker.autocmds() end,              desc = "Autocmds" },
            -- { "<leader>sb", function() Snacks.picker.lines() end,                 desc = "Buffer Lines" },
            { "<leader>sc", function() Snacks.picker.command_history() end,                         desc = "Command History" },
            -- { "<leader>sd", function() Snacks.picker.diagnostics() end,           desc = "Diagnostics" },
            -- { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end,    desc = "Buffer Diagnostics" },
            { "<leader>sh", function() Snacks.picker.help() end,                                    desc = "Help Pages" },
            -- { "<leader>sH", function() Snacks.picker.highlights() end,            desc = "Highlights" },
            -- { "<leader>si", function() Snacks.picker.icons() end,                 desc = "Icons" },
            { "<leader>sj", function() Snacks.picker.jumps() end,                                   desc = "Jumps" },
            { "<leader>sk", function() Snacks.picker.keymaps() end,                                 desc = "Keymaps" },
            { "<leader>sl", function() Snacks.picker.loclist() end,                                 desc = "Location List" },
            { "<leader>sm", function() Snacks.picker.marks() end,                                   desc = "Marks" },
            { "<leader>sM", function() Snacks.picker.man() end,                                     desc = "Man Pages" },
            -- { "<leader>sp", function() Snacks.picker.lazy() end,                  desc = "Search for Plugin Spec" },
            { "<leader>sq", function() Snacks.picker.qflist() end,                                  desc = "Quickfix List" },
            { "<leader>sr", function() Snacks.picker.resume() end,                                  desc = "Resume" },
            -- { "<leader>su", function() Snacks.picker.undo() end,                  desc = "Undo History" },
            -- { "<leader>uC", function() Snacks.picker.colorschemes() end,          desc = "Colorschemes" },
            -- LSP
            -- { "gd",         function() Snacks.picker.lsp_definitions() end,       desc = "Goto Definition" },
            -- { "gD",         function() Snacks.picker.lsp_declarations() end,      desc = "Goto Declaration" },
            -- { "gr",         function() Snacks.picker.lsp_references() end,        nowait = true,                     desc = "References" },
            -- { "gI",         function() Snacks.picker.lsp_implementations() end,   desc = "Goto Implementation" },
            -- { "gy",         function() Snacks.picker.lsp_type_definitions() end,  desc = "Goto T[y]pe Definition" },
            -- { "gai",        function() Snacks.picker.lsp_incoming_calls() end,    desc = "C[a]lls Incoming" },
            -- { "gao",        function() Snacks.picker.lsp_outgoing_calls() end,    desc = "C[a]lls Outgoing" },
            -- Other
            { "<leader>z",  function() Snacks.zen() end,                                            desc = "Toggle Zen Mode" },
            { "<leader>Z",  function() Snacks.zen.zoom() end,                                       desc = "Toggle Zoom" },
            { "<leader>.",  function() Snacks.scratch() end,                                        desc = "Toggle Scratch Buffer" },
            { "<leader>S",  function() Snacks.scratch.select() end,                                 desc = "Select Scratch Buffer" },
            -- { "<leader>n",  function() Snacks.notifier.show_history() end,        desc = "Notification History" },
            -- { "<leader>bd", function() Snacks.bufdelete() end,               desc = "Delete Buffer" },
            { "<leader>cR", function() Snacks.rename.rename_file() end,                             desc = "Rename File" },
            -- { "<leader>gB", function() Snacks.gitbrowse() end,                    desc = "Git Browse",               mode = { "n", "v" } },
            -- { "<leader>gg", function() Snacks.lazygit() end,                      desc = "Lazygit" },
            -- { "<leader>un", function() Snacks.notifier.hide() end,           desc = "Dismiss All Notifications" },
            -- { "<c-/>",      function() Snacks.terminal() end,                     desc = "Toggle Terminal" },
            -- { "<c-_>",      function() Snacks.terminal() end,                     desc = "which_key_ignore" },
            -- { "]]",         function() Snacks.words.jump(vim.v.count1) end,  desc = "Next Reference",           mode = { "n", "t" } },
            -- { "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference",           mode = { "n", "t" } },
            {
                "<leader>N",
                desc = "Neovim News",
                function()
                    Snacks.win({
                        file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
                        width = 0.6,
                        height = 0.6,
                        wo = {
                            spell = false,
                            wrap = false,
                            signcolumn = "yes",
                            statuscolumn = " ",
                            conceallevel = 3,
                        },
                    })
                end,
            }
        },
        init = function()
            vim.api.nvim_create_autocmd("User", {
                pattern = "VeryLazy",
                callback = function()
                    -- Setup some globals for debugging (lazy-loaded)
                    _G.dd = function(...)
                        Snacks.debug.inspect(...)
                    end
                    _G.bt = function()
                        Snacks.debug.backtrace()
                    end

                    -- Override print to use snacks for `:=` command
                    if vim.fn.has("nvim-0.11") == 1 then
                        vim._print = function(_, ...)
                            dd(...)
                        end
                    else
                        vim.print = _G.dd
                    end

                    -- Create some toggle mappings
                    Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
                    Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
                    Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map(
                        "<leader>uL")
                    Snacks.toggle.diagnostics():map("<leader>ud")
                    Snacks.toggle.line_number():map("<leader>ul")
                    Snacks.toggle.option("conceallevel",
                        { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
                        :map("<leader>uc")
                    Snacks.toggle.treesitter():map("<leader>uT")
                    Snacks.toggle.option("background",
                        { off = "light", on = "dark", name = "Dark Background" }):map(
                        "<leader>ub")
                    Snacks.toggle.inlay_hints():map("<leader>uh")
                    Snacks.toggle.indent():map("<leader>ug")
                    Snacks.toggle.dim():map("<leader>uD")
                end,
            })
        end,
    },
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
                -- pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
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
                    },
                },
                sections = {
                    lualine_a = { 'mode' },
                    lualine_b = { 'branch', 'diff', 'diagnostics' },
                    lualine_c = {
                        {
                            'filename',
                            path = 1,
                        }
                    },
                    lualine_x = {
                        get_file_size,
                        'encoding', 'fileformat', 'filetype'
                    },
                    lualine_y = { 'progress' },
                    lualine_z = { 'location', 'tabs' }
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = {
                        {
                            'filename',
                            path = 1,
                        }
                    },
                    lualine_x = { 'location' },
                    lualine_y = {},
                    lualine_z = {}
                },
                tabs = {},

                -- winbar = {
                --     lualine_a = {
                --
                --     },
                --     lualine_b = {
                --
                --     },
                --     lualine_c = {
                --     },
                --     lualine_x = {},
                --     lualine_y = {},
                --     lualine_z = {
                --
                --     }
                -- },
                -- inactive_winbar = {
                --     lualine_a = {
                --
                --     },
                --     lualine_b = {},
                --
                --     lualine_c = {
                --
                --     },
                --
                --     lualine_x = {},
                --     lualine_y = {},
                --     lualine_z = {}
                -- }
            })
        end
    },
    -- {
    --     'nvim-tree/nvim-tree.lua',
    --
    --     dependencies = {
    --         'nvim-tree/nvim-web-devicons',
    --         'DaikyXendo/nvim-material-icon',
    --     },
    --     config = function()
    --         require('nvim-tree').setup({
    --             view = {
    --                 float = {
    --                     enable = true, -- 啟用浮動模式
    --                     open_win_config = function()
    --                         local screen_w = vim.opt.columns:get()
    --                         local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
    --                         local window_w = math.floor(screen_w * 0.5)
    --                         local window_h = math.floor(screen_h * 0.5)
    --                         local center_x = (screen_w - window_w) / 2
    --                         local center_y = ((vim.opt.lines:get() - window_h) / 2) -
    --                             vim.opt.cmdheight:get()
    --                         return {
    --                             relative = "editor",
    --                             border = "rounded",
    --                             width = window_w,
    --                             height = window_h,
    --                             row = center_y,
    --                             col = center_x,
    --                         }
    --                     end
    --                 },
    --                 width = 50,
    --             },
    --             renderer = {
    --                 group_empty = true,
    --                 -- ":~:s?$?/..?"
    --                 root_folder_label = ":t"
    --                 -- icons = {
    --                 --     show = { file = true, folder = true, folder_arrow = true, git = true },
    --                 --     glyphs = require('nvim-material-icon').get_icons(),
    --                 -- }
    --             },
    --             filters = {
    --                 dotfiles = false,
    --                 git_ignored = false,
    --             },
    --             live_filter = {
    --                 always_show_folders = false,
    --             },
    --             actions = {
    --                 open_file = {
    --                     quit_on_open = false,
    --                     window_picker = {
    --                         enable = true,
    --                     }
    --                 }
    --             },
    --             hijack_unnamed_buffer_when_opening = false,
    --             hijack_netrw = true,
    --             disable_netrw = true,
    --             update_focused_file = {
    --                 enable = true,
    --                 update_root = false,
    --             },
    --             update_cwd = true,
    --         })
    --         -- vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', {
    --         --     desc = 'Toggle file explorer'
    --         -- })
    --     end
    -- },
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
                    -- ['ui-select'] = {
                    --     require('telescope.themes').get_dropdown() -- picker will be a dropdown instead of fullscreen list
                    -- }
                }
            })

            -- Enable Telescope extensions if they are installed
            -- pcall(require('telescope').load_extension, 'ui-select')
            pcall(require('telescope').load_extension, 'fzf')

            -- See `:help telescope.builtin`
            local builtin = require 'telescope.builtin'
            -- vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
            -- vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })

            -- Lua mapping example (init.lua or keymaps file)
            vim.keymap.set("n", "<leader>so", function()
                builtin.oldfiles({
                    cwd_only = true
                })
            end, { desc = "[F]ind [R]ecent files" })

            -- vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
            -- vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
            -- vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
            -- vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
            -- vim.keymap.set('n', '<leader>sD', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
            -- vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
            -- vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
            -- vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

            -- local Path = require('plenary.path')
            -- local function open_file(filename)
            --     local p = Path:new(filename)
            --     if not p:exists() then
            --         p:touch({ parents = true })
            --     end
            --     vim.cmd('edit ' .. filename)
            -- end
            -- vim.api.nvim_create_user_command('NewFile', open_file, {})
            -- vim.keymap.set('n', '<leader>nf', open_file, { desc = 'Create new file' })

            -- require "multi-grep".setup()
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
    },
    {
        'ahmedkhalf/project.nvim',
        dependencies = {
            'nvim-telescope/telescope.nvim'
        },
        config = function()
            require('project_nvim').setup({
                silent_chdir = true,
                patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile" },
            })
            require('telescope').load_extension('projects')
        end
    },
    {
        'akinsho/toggleterm.nvim',
        version = "*",
        config = function()
            require("toggleterm").setup {
                size = 20,                -- 水平分割大小
                open_mapping = [[<C-\>]], -- 開關快捷鍵
                shade_terminals = true,
                direction = 'horizontal', -- 預設方向，可改 'float' 或 'vertical'
                autochdir = true
            }

            local DIR      = "/Users/net.chen/Library/Application Support/lazygit"
            local Terminal = require('toggleterm.terminal').Terminal
            local lazygit  = Terminal:new({
                cmd = "lazygit",
                env = {
                    LG_CONFIG_FILE = DIR ..
                        "/config.yml,/Users/net.chen/.config/lazygit-catppuccin/themes-mergable/frappe/maroon.yml"
                },
                direction = "float",
                display_name = "lazygit",
                hidden = true
            })

            function _lazygit_toggle()
                lazygit:toggle()
            end

            vim.api.nvim_set_keymap("n", "<leader>lg", "<cmd>lua _lazygit_toggle()<CR>",
                { noremap = true, silent = true })
        end
    },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' }, -- if you use the mini.nvim suite
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' }, -- if you use standalone mini plugins
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {},
    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && npm install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
    },
    -- {
    --     "chrisgrieser/nvim-origami",
    --     event = "VeryLazy",
    --     opts = {}, -- needed even when using default config
    --
    --     -- recommended: disable vim's auto-folding
    --     init = function
    --         vim.opt.foldlevel = 99
    --         vim.opt.foldlevelstart = 99
    --     end,
    -- },
    {
        "gbprod/yanky.nvim",
        opts = {
            history_length = 10
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        },
    },
    {
        "3rd/image.nvim",
        build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
        opts = {
            processor = "magick_cli",
            integrations = {
                -- html = {
                --    enabled = true
                -- },
                -- css = {
                --     enabled = true
                -- }
            }
        }
    },


    -- Lua
    -- {
    --     "folke/zen-mode.nvim",
    --     opts = {
    --         width = .85
    --         -- your configuration comes here
    --         -- or leave it empty to use the default settings
    --         -- refer to the configuration section below
    --     },
    --     config = function()
    --     end
    -- }

}
