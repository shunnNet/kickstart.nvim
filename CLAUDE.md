# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 專案概述

這是一個基於 kickstart.nvim 的 Neovim 設定專案，使用 Lua 撰寫，採用 lazy.nvim 作為套件管理器。

## 架構結構

```
init.lua                    # 入口：載入 keymap、初始化 lazy.nvim
lua/
├── keymap.lua              # 全域按鍵設定
├── settings/
│   ├── default.lua         # 主要設定與套件清單（非 VSCode 環境）
│   └── vscode.lua          # VSCode 環境專用設定
├── plugins/
│   ├── lsp.lua             # LSP 設定（nvim-lspconfig, mason, cmp）
│   └── theme.lua           # 主題相關套件
├── utils/
│   ├── file_operations.lua # 檔案操作工具（刪除、建立檔案）
│   └── theme_manager.lua   # 主題管理與持久化
└── lsnip.lua               # LuaSnip 自訂 snippets
```

## 常用指令

```bash
# 健康檢查
:checkhealth

# 套件管理 (lazy.nvim)
:Lazy              # 開啟套件管理介面
:Lazy sync         # 同步套件
:Lazy update       # 更新套件

# LSP
:Mason             # 開啟 Mason 套件管理
:LspInfo           # 查看 LSP 狀態
:LspBC             # 自訂指令：顯示各 client 附加的 buffers

# 格式化
:ConformInfo       # 查看 conform.nvim 狀態
```

## LSP 設定

啟用的語言伺服器：`vue_ls`, `ts_ls`, `eslint`, `tailwindcss`, `yamlls`, `jsonls`, `marksman`

LSP 設定位於 `lua/plugins/lsp.lua`：
- 使用 Neovim 0.11+ 的 `vim.lsp.config()` 和 `vim.lsp.enable()` API
- Vue + TypeScript 整合透過 `@vue/typescript-plugin`
- Mason 自動安裝：`lua_ls`, `yamlls`, `jsonls`, `marksman`

## 主要套件

- **UI**: snacks.nvim（explorer, picker, notifier）、barbar.nvim（bufferline）、lualine.nvim
- **編輯**: nvim-cmp + LuaSnip、nvim-autopairs、nvim-surround、Comment.nvim
- **導航**: telescope.nvim、project.nvim
- **Git**: diffview.nvim、gitsigns.nvim、vim-fugitive、lazygit（透過 toggleterm）
- **格式化**: conform.nvim（prettierd）
- **LSP 增強**: lspsaga.nvim
- **AI**: claudecode.nvim

## 按鍵慣例

- Leader 鍵：`<Space>`
- `<leader>f*`：檔案操作（find, grep, projects）
- `<leader>s*`：搜尋功能
- `<leader>b*`：Buffer 操作
- `<leader>d*`：Diffview
- `<leader>t*`：Terminal / Tab
- `<leader>a*`：AI / Claude Code
- `<leader>l*`：Lazygit
- `gd`, `gr`, `gI`, `gD`：LSP 導航
- `gd` 使用自訂實作（非 telescope）：收集所有 LSP clients 結果，單一結果直接跳，多結果用 telescope 顯示

## Snippets

自訂 snippets 放在 `~/.config/nvim/snippets/`，使用 VSCode 格式，由 LuaSnip 載入。
