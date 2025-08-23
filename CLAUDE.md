# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) - a single-file, well-documented starting point for Neovim. The configuration uses `lazy.nvim` as the plugin manager and includes various plugins for productivity.

## Common Commands

### Plugin Management
- `:Lazy` - Open lazy.nvim UI to manage plugins
- `:Lazy update` - Update all plugins
- `:Lazy sync` - Sync plugin state with lazy-lock.json

### Health Check
- `:checkhealth` - Run Neovim health checks
- `:checkhealth kickstart` - Run kickstart-specific health check

### Custom Commands
- `:Cloa` - Close all buffers except current one

### Code Formatting
- **stylua** - Lua formatter configured via `.stylua.toml`
  - Run: `stylua init.lua` or `stylua lua/`
  - Config: 160 column width, 2 spaces, Unix line endings

## Architecture

The configuration follows a single-file approach with all settings in `init.lua`:

1. **Leader key setup** - Space as leader key
2. **Basic options** - Line numbers, mouse, clipboard, etc.
3. **Plugin installation** - Via lazy.nvim with lazy loading
4. **Plugin configurations** - Inline within plugin specs
5. **Keymaps** - Custom mappings for navigation and productivity

### Key Directories
- `lua/custom/plugins/` - Directory for custom plugin configurations (currently empty)
- `lua/kickstart/plugins/` - Optional kickstart plugins (not loaded by default, includes debug, lint, autopairs, neo-tree, gitsigns)

### Important Patterns
- Plugins are configured inline using `opts` or `config` functions
- Many advanced features (LSP, debugging, file tree) are included but commented out
- Uses Treesitter for syntax highlighting and code folding
- Custom keymaps include multi-cursor support and enhanced navigation

## Key Customizations

1. **Multi-cursor editing** - VSCode-style with `<C-d>`
2. **Window navigation** - `<C-h/j/k/l>` works in both normal and insert modes
3. **Line navigation** - `ff` for line start, `fj` for line end
4. **Indentation** - Fixed 4-space tabs (overrides vim-sleuth)
5. **Treesitter folding** - Automatic code folding based on syntax

## Notes

- LSP support is available but commented out - can be enabled via Mason
- Terminal integration available through toggleterm (commented out)
- The configuration is designed as a learning tool with extensive comments
- External dependencies: git, make, unzip, gcc, ripgrep, clipboard tool, Nerd Font (optional)