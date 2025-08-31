vim.o.updatetime = 250

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

vim.lsp.enable({
    'vue_ls', 'ts_ls', 'eslint', 'tailwindcss'
})

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
            lspconfig.eslint.setup({
                cmd = { 'vscode-eslint-language-server', '--stdio' },
                settings = {
                    format = { enable = true } -- auto fix
                },
                on_attach = function(client, buffer)
                    if not base_on_attach then return end
                    base_on_attach(client, buffer)

                    vim.api.nvim_create_autocmd('BufWritePre', {
                        buffer = buffer,
                        command = 'LspEslintFixAll',
                    })
                    local opts = { buffer = buffer, noremap = true, silent = true }
                    vim.keymap.set('n', "<leader>lf", ":LspEslintFixAll<CR>", opts)
                end
            })

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

                    -- The following autocommand is used to enable inlay hints in your
                    -- code, if the language server you are using supports them
                    --
                    -- This may be unwanted, since they displace some of your code
                    if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
                        map('<leader>th', function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
                        end, '[T]oggle Inlay [H]ints')
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
            },
            'saadparwaiz1/cmp_luasnip',

            -- Adds other completion capabilities.
            --  nvim-cmp does not ship with all sources by default. They are split
            --  into multiple repos for maintenance purposes.
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-path',
        },
        config = function()
            -- See `:help cmp`
            local cmp = require 'cmp'
            local luasnip = require 'luasnip'
            luasnip.config.setup {}

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
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'path' },
                },
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
                symbol_in_winbar = {
                    enable = true
                }
            })
        end,
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'nvim-tree/nvim-web-devicons',
        }
    },
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
    }

}
