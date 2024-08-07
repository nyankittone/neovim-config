-- Setting some globals here bc it's not working from a require'd lua file. haha..... why
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true -- flip this to "false" if you don't have a nerd font installed

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require "options"
require "keybinds"
require "autocmd"
require "plugin-setup"
require "plugin-setup/treesitter"
require "lsp"

if require("get-term-colors") then
  vim.cmd.colorscheme "tokyonight"
  vim.o.termguicolors = true
else
  vim.cmd.colorscheme "desert"
  vim.o.termguicolors = false
end

