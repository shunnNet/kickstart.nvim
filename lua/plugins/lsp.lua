vim.o.updatetime = 250
vim.lsp.set_log_level("OFF")
vim.o.signcolumn = 'yes'


-- vim.diagnostic.enable(false)
-- vim.o.shortmess = "astWAIc"
-- vim.o.report = 99999
-- vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
-- 靜音所有 notify（包含 LSP error）
-- vim.notify = function(msg, level, opts)
--     if level == vim.log.levels.ERROR then
--         -- 想完全不顯示就直接 return
--         return
--     end
--     -- 其他訊息照常顯示
--     vim.api.nvim_echo({ { msg } }, true, {})
-- end


-- vim.lsp.handlers["window/showMessage"] = function(_, result, ctx)
--     if result.type == vim.lsp.protocol.MessageType.Error then
--         return
--     end
--     vim.notify(result.message, vim.log.levels[result.type])
-- end
-- vim.diagnostic.config({
--     virtual_text = false, -- 不要在行尾噴紅字
--     signs = true,         -- 保留 sign column
--     float = { border = "rounded" },
--     underline = true,
--     update_in_insert = false,
-- })

-- 定義診斷顏色 (可以依需求調整)
vim.cmd [[
  highlight DiagnosticError guifg=#f44747
  highlight DiagnosticWarn  guifg=#ff8800
  highlight DiagnosticInfo  guifg=#4fc1ff
  highlight DiagnosticHint  guifg=#10B981
]]

vim.api.nvim_create_autocmd('CursorHold', {
    pattern = "*",
    callback = function()
        vim.diagnostic.open_float(nil, {
            focusable = false,
            border = "double",
            prefix = "⚠️ "
        }
        )
    end
})

local nvim_path = vim.fn.stdpath('data')
local vue_language_server_path = nvim_path ..
    '/mason/packages' .. '/vue-language-server' .. '/node_modules/@vue/language-server'
local vue_plugin = {
    name = '@vue/typescript-plugin',
    location = vue_language_server_path,
    languages = { 'vue' },
    configNamespace = 'typescript',
}
--
vim.lsp.config('vue_ls', {})
vim.lsp.config('ts_ls', {
    init_options = {
        plugins = {
            vue_plugin,
        },
    },
    filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
})
vim.lsp.config('lua_ls', {
    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT', -- Neovim use LuaJIT
                path = vim.split(package.path, ';'),
            },
            diagnostics = {
                globals = { 'vim' }, -- Make lua understand global vim variable
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file('', true), -- Load nvim runtime
                checkThirdParty = false,
            },
            telemetry = {
                enable = false,
            }
        }
    }
})

vim.lsp.config('tailwindcss', {
    -- settings = {
    --     tailwindCSS = {
    --         classAttributes = {
    --             'class',
    --             'className',
    --             'class:list',
    --             'classList',
    --             'ngClass',
    --             'ui',
    --             ':ui'
    --         },
    --     }
    -- }
})

vim.lsp.config('yamlls', {
    settings = {
        yaml = {
            schemas = {
                -- 如果需要，可以在這裡添加特定的 schema 設定
                -- ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
            },
            validate = true,
            hover = true,
            completion = true,
        }
    }
})

vim.lsp.config('jsonls', {
    settings = {
        json = {
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
        }
    }
})

-- tailwindcss-language-server install is required
vim.lsp.enable({
    'vue_ls', 'ts_ls', 'eslint', 'tailwindcss', 'yamlls', 'jsonls', 'marksman'
})
--
local function showClientsAttachedBuffers()
    for _, client in pairs(vim.lsp.get_active_clients()) do
        print('Client: ', client.name)
        print("Attached Buffers: ")
        for _, buf in ipairs(vim.lsp.get_buffers_by_client_id(client.id)) do
            print(" " .. buf .. " -> " .. vim.api.nvim_buf_get_name(buf))
        end
    end
end

vim.api.nvim_create_user_command(
    'LspBC',
    showClientsAttachedBuffers,
    {}
)

return {
    {
        'neovim/nvim-lspconfig',
        config = function()
            local lspconfig = require('lspconfig')
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            local base_on_attach = vim.lsp.config.eslint.on_attach
            -- lspconfig.eslint.setup({
            --     cmd = { 'vscode-eslint-language-server', '--stdio' },
            --     settings = {
            --         format = { enable = true } -- auto fix
            --     },
            --     on_attach = function(client, buffer)
            --         if not base_on_attach then return end
            --         base_on_attach(client, buffer)
            --
            --         vim.api.nvim_create_autocmd('BufWritePre', {
            --             buffer = buffer,
            --             command = 'silent! LspEslintFixAll',
            --
            --         })
            --         local opts = { buffer = buffer, noremap = true, silent = true }
            --         vim.keymap.set('n', "<leader>lf", ":LspEslintFixAll<CR>", opts)
            --     end
            -- })

            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('my-lsp-attach', { clear = true }),
                callback = function(event)
                    -- NOTE: Remember that Lua is a real programming language, and as such it is possible
                    -- to define small helper and utility functions so you don't have to repeat yourself.
                    --
                    -- In this case, we create a function that lets us more easily define mappings specific
                    -- for LSP related items. It sets the mode, buffer and description for us each time.
                    local map = function(keys, func, desc)
                        vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                    end

                    -- Jump to the definition of the word under your cursor.
                    --  This is where a variable was first declared, or where a function is defined, etc.
                    --  To jump back, press <C-t>.
                    map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

                    -- Find references for the word under your cursor.
                    map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

                    -- Jump to the implementation of the word under your cursor.
                    --  Useful when your language has ways of declaring types without an actual implementation.
                    map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

                    -- Jump to the type of the word under your cursor.
                    --  Useful when you're not sure what type a variable is and you want to see
                    --  the definition of its *type*, not where it was *defined*.
                    map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

                    -- Fuzzy find all the symbols in your current document.
                    --  Symbols are things like variables, functions, types, etc.
                    map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

                    -- Fuzzy find all the symbols in your current workspace.
                    --  Similar to document symbols, except searches over your entire project.
                    map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

                    -- Rename the variable under your cursor.
                    --  Most Language Servers support renaming across files, etc.
                    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

                    -- Execute a code action, usually your cursor needs to be on top of an error
                    -- or a suggestion from your LSP for this to activate.
                    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

                    -- Opens a popup that displays documentation about the word under your cursor
                    -- --  See `:help K` for why this keymap.
                    -- map('K', vim.lsp.buf.hover, 'Hover Documentation')

                    -- WARN: This is not Goto Definition, this is Goto Declaration.
                    --  For example, in C this would take you to the header.
                    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

                    -- The following two autocommands are used to highlight references of the
                    -- word under your cursor when your cursor rests there for a little while.
                    --    See `:help CursorHold` for information about when this is executed
                    --
                    -- When you move your cursor, the highlights will be cleared (the second autocommand).
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client.server_capabilities.documentHighlightProvider then
                        local highlight_augroup = vim.api.nvim_create_augroup('my-lsp-highlight', { clear = false })
                        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.document_highlight,
                        })

                        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.clear_references,
                        })

                        vim.api.nvim_create_autocmd('LspDetach', {
                            group = vim.api.nvim_create_augroup('my-lsp-detach', { clear = true }),
                            callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds { group = 'my-lsp-highlight', buffer = event2.buf }
                            end,
                        })
                    end

                    -- vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#888888", italic = true })

                    -- The following autocommand is used to enable inlay hints in your
                    -- code, if the language server you are using supports them
                    --
                    -- This may be unwanted, since they displace some of your code
                    if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
                        map('<leader>th', function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
                        end, '[T]oggle Inlay [H]ints')

                        -- vim.lsp.inlay_hint.enable(true)
                    end
                end,
            })
        end,
    },
    { -- Autocompletion
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        dependencies = {
            -- Snippet Engine & its associated nvim-cmp source
            {
                'L3MON4D3/LuaSnip',
                build = (function()
                    -- Build Step is needed for regex support in snippets.
                    -- This step is not supported in many windows environments.
                    -- Remove the below condition to re-enable on windows.
                    if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
                        return
                    end
                    return 'make install_jsregexp'
                end)(),
                dependencies = {
                    -- `friendly-snippets` contains a variety of premade snippets.
                    --    See the README about individual language/framework/plugin snippets:
                    --    https://github.com/rafamadriz/friendly-snippets
                    {
                        'rafamadriz/friendly-snippets',
                        config = function()
                            require('luasnip.loaders.from_vscode').lazy_load({
                                paths = '~/.config/nvim/snippets'
                                -- paths = '/Users/net.chen/Library/Application Support/Cursor/User/snippets'
                            })
                        end,
                    },
                },
                config = function()
                    local ls = require("luasnip")
                    local types = require('luasnip.util.types')

                    -- 跳到下一個 placeholder
                    vim.keymap.set({ "i", "s" }, "<C-l>", function()
                        if ls.jumpable(1) then
                            ls.jump(1)
                        end
                    end, { silent = true })

                    -- 跳到上一個 placeholder
                    vim.keymap.set({ "i", "s" }, "<C-h>", function()
                        if ls.jumpable(-1) then
                            ls.jump(-1)
                        end
                    end, { silent = true })

                    -- Next Choice
                    vim.keymap.set({ "i", "s" }, "<C-j>", function()
                        if ls.choice_active() then
                            ls.change_choice(1)
                        end
                    end, { silent = true })

                    -- Prev Choice
                    vim.keymap.set({ "i", "s" }, "<C-k>", function()
                        if ls.choice_active() then
                            ls.change_choice(-1)
                        end
                    end, { silent = true })


                    vim.keymap.set({ "i", "s" }, "<c-e>", function()
                        if ls.expand_or_jumpable() then
                            ls.expand_or_jump()
                        end
                    end)

                    vim.keymap.set('n', "<leader><leader>s", "<cmd>source ~/.config/nvim/lua/lsnip.lua<CR>")


                    ls.setup({
                        history = true,
                        update_events = "TextChanged,TextChangedI",
                        enable_autosnippets = true,
                        ext_opts = {
                            [types.choiceNode] = {
                                active = {
                                    virt_text = { { "choiceNode", "Comment" } },
                                },
                            },
                        },
                    })
                end
            },
            'saadparwaiz1/cmp_luasnip',

            -- Adds other completion capabilities.
            --  nvim-cmp does not ship with all sources by default. They are split
            --  into multiple repos for maintenance purposes.
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/nvim-cmp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-nvim-lsp-signature-help',
            'onsails/lspkind.nvim'
        },
        config = function()
            -- See `:help cmp`
            local cmp = require 'cmp'
            local luasnip = require 'luasnip'
            -- luasnip.config.setup {}


            cmp.setup.cmdline('/', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            })
            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = 'path' }
                }, {
                    {
                        name = 'cmdline',
                        option = {
                            ignore_cmds = { 'Man', '!' }
                        }
                    }
                })
            })



            local lspkind = require('lspkind')

            vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })


            cmp.setup {
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                completion = { completeopt = 'menu,menuone,noinsert' },

                -- For an understanding of why these mappings were
                -- chosen, you will need to read `:help ins-completion`
                --
                -- No, but seriously. Please read `:help ins-completion`, it is really good!
                mapping = cmp.mapping.preset.insert {
                    -- Select the [n]ext item
                    -- ['<C-n>'] = cmp.mapping.select_next_item(),
                    -- Select the [p]revious item
                    -- ['<C-p>'] = cmp.mapping.select_prev_item(),

                    -- Scroll the documentation window [b]ack / [f]orward
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),

                    -- Accept ([y]es) the completion.
                    --  This will auto-import if your LSP supports it.
                    --  This will expand snippets if the LSP sent a snippet.
                    -- ['<C-y>'] = cmp.mapping.confirm { select = true },

                    -- If you prefer more traditional completion keymaps,
                    -- you can uncomment the following lines
                    ['<CR>'] = cmp.mapping.confirm { select = true },
                    -- ['<Tab>'] = cmp.mapping.select_next_item(),
                    ['<S-Tab>'] = cmp.mapping.select_prev_item(),

                    -- Manually trigger a completion from nvim-cmp.
                    --  Generally you don't need this, because nvim-cmp will display
                    --  completions whenever it has completion options available.
                    ['<C-Space>'] = cmp.mapping.complete {},

                    -- Think of <c-l> as moving to the right of your snippet expansion.
                    --  So if you have a snippet that's like:
                    --  function $name($args)
                    --    $body
                    --  end
                    --
                    -- <c-l> will move you to the right of each of the expansion locations.
                    -- <c-h> is similar, except moving you backwards.
                    -- ['<C-l>'] = cmp.mapping(function()
                    --   if luasnip.expand_or_locally_jumpable() then
                    --     luasnip.expand_or_jump()
                    --   end
                    -- end, { 'i', 's' }),
                    -- ['<C-h>'] = cmp.mapping(function()
                    --   if luasnip.locally_jumpable(-1) then
                    --    luasnip.jump(-1)
                    --  end
                    -- end, { 'i', 's' }),

                    -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
                    --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
                },
                sources = {
                    -- Copilot Source
                    -- { name = "copilot",                group_index = 2 },
                    -- LSP Source
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'path' },
                    { name = 'buffer' },
                    { name = 'nvim_lsp_signature_help' }

                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                formatting = {
                    format = lspkind.cmp_format({
                        mode = "text_symbol",
                        symbol_map = { Copilot = "" },
                        maxwidth = {
                            -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
                            -- can also be a function to dynamically calculate max width such as
                            -- menu = function() return math.floor(0.45 * vim.o.columns) end,
                            menu = 50,            -- leading text (labelDetails)
                            abbr = 50,            -- actual suggestion item
                        },
                        ellipsis_char = '...',    -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
                        show_labelDetails = true, -- show labelDetails in menu. Disabled by default

                        -- The function below will be called before any actual modifications from lspkind
                        -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
                        -- before = function(entry, vim_item)
                        --     -- ...
                        --     return vim_item
                        -- end

                    })
                }
            }
        end,
    },
    -- {
    --     'hrsh7th/nvim-cmp',
    --     dependencies = {
    --         'hrsh7th/cmp-nvim-lsp', -- make lsp completion source
    --         'hrsh7th/cmp-buffer', -- make buffer completion source
    --         'hrsh7th/cmp-path', -- make path as source
    --         'hrsh7th/cmp-cmdline', -- cmd as source
    --
    --         -- snippet as source:
    --         'L3MON4D3/LuaSnip',
    --         'saadparwaiz1/cmp_luasnip'
    --     },
    --     config = function()
    --         local cmp = require('cmp')
    --         local luasnip = require('luasnip')
    --
    --         cmp.setup({
    --             snippet = {
    --                 expand = function(args)
    --                     luasnip.lsp_expand(args.body)
    --                 end
    --             },
    --             mapping = cmp.mapping.preset.insert({
    --                 ['<C-Space>'] = cmp.mapping.complete(),
    --                 ['<CR>'] = cmp.mapping.confirm({ select = true }),
    --                 ['<Tab>'] = cmp.mapping(function(fallback)
    --                     if cmp.visible() then
    --                         cmp.select_next_item()
    --                     elseif luasnip.expand_or_jumpable() then
    --                         luasnip.expand_or_jump()
    --                     else
    --                         fallback()
    --                     end
    --                 end, { 'i', 's' }),
    --                 ['<S-Tab>'] = cmp.mapping(function(fallback)
    --                     if cmp.visible() then
    --                         cmp.select_prev_item()
    --                     elseif luasnip.jumpable(-1) then
    --                         luasnip.jump(-1)
    --                     else
    --                         fallback()
    --                     end
    --                 end, { 'i', 's' })
    --             }),
    --             source = cmp.config.sources({
    --                 { name = 'nvim_lsp' },
    --                 { name = 'luasnip' },
    --                 { name = 'buffer' },
    --                 { name = 'path' },
    --             })
    --         })
    --
    --     end
    -- },
    {
        'williamboman/mason.nvim',
        config = function()
            require('mason').setup()
        end
    },
    {
        -- default install directory is: ~/.local/share/nvim/mason
        'williamboman/mason-lspconfig.nvim',
        dependencies = { 'neovim/nvim-lspconfig', 'williamboman/mason.nvim' },
        config = function()
            require('mason-lspconfig').setup({
                ensure_installed = {
                    'lua_ls',
                    'yamlls',
                    'jsonls',
                    'marksman',
                },
            })
        end
    },
    -- {
    --     'mfussenegger/nvim-lint',
    --     config = function ()
    --         require('lint').linters_by_ft = {
    --             javascript = {'eslint'},
    --             typescript = {'eslint'},
    --         }
    --         vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
    --             callback = function ()
    --                 require('lint').try_lint()
    --             end
    --         })
    --     end
    -- },
    -- {
    --     'nvimtools/none-ls.nvim',
    --     dependencies = { 'nvim-lua/plenary.nvim' },
    --     config = function ()
    --         local null_ls = require('null-ls')
    --         null_ls.setup({
    --             sources = {
    --                 null_ls.builtins.diagnostics.eslint,
    --                 null_ls.builtins.code_actions.eslint,
    --                 null_ls.builtins.formatting.prettier,
    --             },
    --             on_attach = function (client, buffer)
    --                 if client.supports_method('textDocument/formatting') then
    --                     vim.api.nvim_clear_autocmds({ group = 0, buffer })
    --                     vim.api.nvim_create_autocmd('BufWritePre', {
    --                         buffer,
    --                         callback = function ()
    --                             vim.lsp.buf.format({ bufnr = buffer })
    --                         end
    --                     })
    --                 end
    --
    --             end
    --         })
    --     end
    -- },
    {
        'nvimdev/lspsaga.nvim',
        event = 'LspAttach',
        config = function()
            require('lspsaga').setup({
                ui = {
                    border = 'rounded',
                    title = true,
                    code_action = ''
                },
                -- symbol_in_winbar = {
                --     enable = false
                -- }
            })
        end,
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'nvim-tree/nvim-web-devicons',
        }
    },
    {
        'stevearc/conform.nvim',
        config = function()
            require('conform').setup({
                formatters_by_ft = {
                    javascript = { 'prettierd' },
                    typescript = { 'prettierd' },
                    vue = { 'prettierd' },
                    json = { 'prettierd' },
                    markdown = { 'prettierd' },
                    html = { 'prettierd' },
                    yaml = { 'prettierd' }
                },
                -- format_on_save = {
                --
                --     lsp_fallback = true,
                --     async = false,
                --     timeout_ms = 1000,
                -- }
            })
        end
    },
    -- {
    --     "catgoose/nvim-colorizer.lua",
    --     event = 'BufReadPre',
    --     opts = {}
    -- }
    {
        'brenoprata10/nvim-highlight-colors',
        config = function()
            require('nvim-highlight-colors').setup {
                enable_tailwind = true
            }
        end
    },
    -- {
    --     'zbirenbaum/copilot.lua',
    --     dependencies = {
    --         'copilotlsp-nvim/copilot-lsp'
    --     },
    --     cmd = "Copilot",
    --     event = "InsertEnter",
    --     config = function()
    --         require("copilot").setup({
    --             suggestion = {
    --                 enabled = false,
    --                 -- auto_trigger = true,
    --                 -- keymap = {
    --                 --     accept = "<C-l>",
    --                 -- },
    --             },
    --             panel = {
    --                 enabled = false,
    --             },
    --             -- nes = {
    --             --     enabled = true,
    --             --     keymap = {
    --             --         accept_and_goto = "<c-a>",
    --             --         accept = false,
    --             --         dismiss = "<Esc>",
    --             --     },
    --             -- },
    --         })
    --     end,
    -- },
    -- {
    --     "zbirenbaum/copilot-cmp",
    --     config = function()
    --         require("copilot_cmp").setup()
    --     end
    -- },
    {
        'onsails/lspkind.nvim',
        config = function()
            local lspkind = require('lspkind')
            lspkind.setup({
                formatting = {
                    format = lspkind.cmp_format({
                        mode = 'symbol', -- show only symbol annotations
                        maxwidth = {
                            -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
                            -- can also be a function to dynamically calculate max width such as
                            -- menu = function() return math.floor(0.45 * vim.o.columns) end,
                            menu = 50,            -- leading text (labelDetails)
                            abbr = 50,            -- actual suggestion item
                        },
                        ellipsis_char = '...',    -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
                        show_labelDetails = true, -- show labelDetails in menu. Disabled by default

                        -- The function below will be called before any actual modifications from lspkind
                        -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
                        before = function(entry, vim_item)
                            -- ...
                            return vim_item
                        end
                    })
                }
            })
            lspkind.init({
                -- DEPRECATED (use mode instead): enables text annotations
                --
                -- default: true
                -- with_text = true,

                -- defines how annotations are shown
                -- default: symbol
                -- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
                mode = 'symbol_text',

                -- default symbol map
                -- can be either 'default' (requires nerd-fonts font) or
                -- 'codicons' for codicon preset (requires vscode-codicons font)
                --
                -- default: 'default'
                preset = 'codicons',

                -- override preset symbols
                --
                -- default: {}
                symbol_map = {
                    Text = "󰉿",
                    Method = "󰆧",
                    Function = "󰊕",
                    Constructor = "",
                    Field = "󰜢",
                    Variable = "󰀫",
                    Class = "󰠱",
                    Interface = "",
                    Module = "",
                    Property = "󰜢",
                    Unit = "󰑭",
                    Value = "󰎠",
                    Enum = "",
                    Keyword = "󰌋",
                    Snippet = "",
                    Color = "󰏘",
                    File = "󰈙",
                    Reference = "󰈇",
                    Folder = "󰉋",
                    EnumMember = "",
                    Constant = "󰏿",
                    Struct = "󰙅",
                    Event = "",
                    Operator = "󰆕",
                    TypeParameter = "",
                    Copilot = "",
                },

            })

            vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
        end
    }

}
