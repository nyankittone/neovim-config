-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
  pattern = '*',
})

-- making sure our cursor is set to the correct one on exit
vim.api.nvim_create_autocmd("ExitPre", {
  group = vim.api.nvim_create_augroup("Exit", {clear = true}),
  command = "set guicursor=a:hor90",
  desc = "Set cursor back to beam when leaving Neovim.",
})

vim.api.nvim_create_autocmd("TermOpen", {
  command = "setlocal nonumber",
})

vim.api.nvim_create_autocmd("ColorScheme", {
  desc = "Fix up a few rough things the Dracula colorscheme does that I don't like ;)",
  callback = function()
    if vim.g.colors_name ~= "dracula" then
      return
    end

    vim.g.terminal_color_0 = "#000000"
    vim.g.terminal_color_1 = "#ff5555"
    vim.g.terminal_color_2 = "#50fa7b"
    vim.g.terminal_color_3 = "#effa78"
    vim.g.terminal_color_4 = "#bd93f9"
    vim.g.terminal_color_5 = "#ff79c6"
    vim.g.terminal_color_6 = "#8d79ba"
    vim.g.terminal_color_7 = "#bfbfbf"
    vim.g.terminal_color_8 = "#4d4d4d"
    vim.g.terminal_color_9 = "#ff6e67"
    vim.g.terminal_color_10 = "#5af78e"
    vim.g.terminal_color_11 = "#eaf08d"
    vim.g.terminal_color_12 = "#caa9fa"
    vim.g.terminal_color_13 = "#ff92d0"
    vim.g.terminal_color_14 = "#aa91e3"
    vim.g.terminal_color_15 = "#e6e6e6"

    vim.api.nvim_set_hl(0, "CursorLineNr", {fg = "#c294ff", bold = true})
  end,
})

