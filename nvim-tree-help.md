# NvimTree File Explorer Guide

## 🚀 Most Used Commands (Quick Reference)

- `Ctrl+E` - Toggle file explorer (from anywhere in Neovim)
- `Enter` - Open file/folder
- `a` - Create new file/folder (end name with `/` for folder)
- `d` - Delete file/folder
- `r` - Rename
- `h`/`l` - Close/open folders
- `g?` - Show all keybindings

---

## Complete Navigation Guide

### Basic Navigation
- `j`/`k` - Move down/up
- `h`/`l` - Close/open folders (or move left/right in tree)
- `Enter` - Open file/folder
- `<BS>` (Backspace) - Close current folder and go to parent
- `P` - Go to parent directory

### Directory Focus (Change Root)
- `<C-]>` - Change root to current folder (focus on subtree)
- `-` - Go up one directory level (changes root to parent)
- This is useful for focusing on a specific part of your project!

### File Operations
- `a` - Create new file/folder (end with `/` for folder)
- `d` - Delete
- `r` - Rename
- `x` - Cut
- `c` - Copy
- `p` - Paste
- `y` - Copy name to clipboard
- `Y` - Copy relative path
- `gy` - Copy absolute path

### View Options
- `I` - Toggle hidden files (dotfiles)
- `H` - Toggle dot files
- `R` - Refresh tree
- `W` - Collapse all folders
- `E` - Expand all folders
- `S` - Open in system file manager

### Opening Files
- `Enter`/`o` - Open in current window
- `<Tab>` - Open preview (keeps cursor in tree)
- `<C-t>` - Open in new tab
- `<C-v>` - Open in vertical split
- `<C-x>` - Open in horizontal split

### Other Commands
- `g?` - Show help/all keybindings
- `q` - Close nvim-tree
- `.` - Run command on file
- `f` - Filter files
- `F` - Clear filter
- `]e` - Go to next diagnostic item
- `[e` - Go to previous diagnostic item

### Search & Navigation
- `/` - Search in tree
- `n` - Next search result
- `N` - Previous search result

## Tips
1. Press `g?` inside nvim-tree for a complete list of keybindings
2. Use `a` to create files - type the name and press Enter
3. Create folders by ending the name with `/` when using `a`
4. Use `<C-v>` to open files in a split while keeping the tree open

## Quick Access to This Guide
While in Neovim, you can quickly open this guide:
`:e ~/.config/nvim/nvim-tree-help.md`
