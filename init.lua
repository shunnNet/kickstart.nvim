require('keymap')

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', 'https://github.com/folke/lazy.nvim.git',
        lazypath })
end


vim.opt.rtp:prepend(lazypath)

if vim.g.vscode then
    require('lazy').setup(require('settings.vscode'))
else
    require('lazy').setup(require('settings.default'))
end
