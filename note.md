You can see buffer list by `:ls` or `:ls!`

Alternate buffer:
`#`. The last active buffer.

- `<C+^>`
- `:b#`

`%`: buffer in current window

`:new`, `:vnew`, `enew`: create new buffer
navigate: `:bn` `:bp`
delete buffer: `:bd`

## What difference between `:q` and `:bd` ?

`:q` delete the window, and leave vim when there is only one window.

`:bd` delete the buffer. also ask when it is not saved.

## Plugins

we use lazy to setup

`:Lazy`: check all plugins status
`:Lazy update`: update plugins

Plugins are github repos, or sometimes is just a url.
We can controll 'how' and 'when' plugin is loaded.
to install a plugin:

```lua
-- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).

require('lazy').setup({
  'tpope/vim-sleuth' -- Detect tabstop and shiftwidth automatically
})

require('lazy').setup({
  -- Use `opts = {}`
  --  1. load plugin with default options
  --  2. force a plugin to be loaded when nvim started.
  --
  --  This is equivalent to:
  --    require('Comment').setup({})

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },
})

require('lazy').setup({
  {
    'folke/which-key.nvim',
    event = 'VimEnter', -- Load this plugin when VimEnter event.
    config = function()
      -- config is a funtion that runs AFTER plugin loaded.
      -- ........
    end
  }
})


```

## LSP

`:Mason`: to get all available LSP packages.

capabilites is what LSP client (which is neovim) is capable doing.

```lua
--  By default, Neovim doesn't support everything that is in the LSP specification.
--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
```

## Other useful shortcut and commands

save all buffer: `:wa`
page down: `<C-f>`
page up : `<C-b>`
temporary back to normal mode when insert mode: `<C-o>`

## telescope related

```lua
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
```

## Reference

[Neovim for Beginners — Buffer](https://alpha2phi.medium.com/neovim-for-beginners-managing-buffers-91367668ce7)

## all

- plugins
- keymap
- telescope
- LSP
  - formatter
  - autocompletion
- mini.nvim
- Git

https://www.reddit.com/r/neovim/comments/nspg8o/telescope_find_files_not_showing_hidden_files/

## others

### vim.g

A keymap global varibales.
Should be setup as quickly as possible.

```lua
vim.g.mapleader = " " -- <Leader> as empty key
```

### vim.o and vim.g

vim.o：用於設定 Neovim 本身的全域選項，影響編輯器的行為和外觀。
vim.g：用於設定全域變數，通常用於插件的配置和選項。
這兩者在設定 Neovim 時各有其特定的用途，vim.o 主要是用於編輯器的內建選項，而 vim.g 則是用於插件相關的全域變數。

### move cursor in insertion mode

- Method 1: use shortcut

```lua
vim.api.nvim_set_keymap('i', '<C-h>', '<Left>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-j>', '<Down>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-k>', '<Up>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-l>', '<Right>', { noremap = true, silent = true })
```

- Method 2: use plugins
  vim-sneak: 提供快速跳轉到某個字符的功能。
  vim-easymotion: 提供更靈活的跳轉方式。

## Manage Plugins by lua modules

The lua module can be a folder export `init.lua`.

For example: in following structure

```
/module
  init.lua

init.lua
```

```lua
-- module/init.lua

local M = {}

function M.greet(name)
  return "Hello " .. name
end

return M
```

```lua
-- init.lua

local module = require('module')
print(module.greet("myname"))
```

### combine with lazy.nvim

see _:help lazy.nvim-lazy.nvim-structuring-your-plugins_

You can require your local module for setup

Example:

- `~/.config/nvim/init.lua`

> lua

    require("lazy").setup("plugins")
    require("lazy").setup({ import: "plugins" })

<

- `~/.config/nvim/lua/plugins.lua` or `~/.config/nvim/lua/plugins/init.lua` **(this file is optional)**

> lua

    return {
      "folke/neodev.nvim",
      "folke/which-key.nvim",
      { "folke/neoconf.nvim", cmd = "Neoconf" },
    }

<

## lazy.nvim init vs config

```lua
{
  'some/plugin',
  init = function()
    -- 在插件加载前执行的代码
    -- 主要用于设置一些与插件相关的全局变量或基本设置，这些设置需要在插件被加载前生效。
    vim.g.some_plugin_setting = true
  end,
}

{
  'some/plugin',
  config = function()
    -- 在插件加载后执行的代码
    -- 主要用于配置插件的具体行为和功能设置，通常涉及调用插件提供的 API 或设置插件的选项。
    require('some_plugin').setup({
      option1 = true,
      option2 = 'value'
    })
  end,
}
```

## treesitter vs lsp

see :help lsp-vs-treesitter

They provide different part about language for better editing experience.

## fold

nvim has builtin folding support

zo: open fold
zc: close fold
za: toggle fold
zi: toggle folding

- in nvim, you can use `:set foldenable` to set init folding state
- when foldenable true, all folding is active when entering file, so you will see lots of folding when entering file.

## other plugins

- https://github.com/code-biscuits/nvim-biscuits
- https://github.com/ThePrimeagen/harpoon
- https://github.com/folke/trouble.nvim
- https://github.com/editorconfig/editorconfig-vim
- https://github.com/vim-test/vim-test

## issue

This line not work..

```lua
+ 1145 vim.keymap.set('n', '<C-CR>', '<S-o>')
```

## others?
- press ' or ` in normal mode, show functionality 'mark'. What is that?
- surround add bracket. like ``



