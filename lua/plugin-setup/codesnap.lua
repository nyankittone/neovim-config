require("codesnap").setup({
  bg_theme = "summer",
  watermark = "🔥🔥🔥 VERY COOL AND AWESOME CODE SNAPSHOT!!! 🔥🔥🔥", -- Might consider removing this watermark
  watermark_font_family = "Papyrus",
  mac_window_bar = true,
  code_font_family = "JetBrainsMono Nerd Font",
  save_path = "~/Pictures/Neovim",
  has_breadcrumbs = true,
})

-- why does this only work like half the time I press the keybind??????
-- there's likely a conflicting keybind here.
vim.keymap.set('v', '<leader>cc', "<cmd>CodeSnap<cr>", { desc = 'wow' })
