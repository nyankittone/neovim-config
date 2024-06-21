local plugin = require("todo-comments")

plugin.setup({
  signs = false,

  -- BUG: This plugin appears like it might have a bug preventing changes in FIX from actually
  -- being applied. That's a problem.
  FIX = {
    icon = " ", -- icon used for the sign, and in search results
    color = "error", -- can be a hex color, or a named color (see below)
    alt = { "FIXME", "BUG", "BUGGY", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
    -- signs = false, -- configure signs for some keywords individually
  },

  highlight = {
    multiline = false, -- switch to true if you switch the "after" text to be "fg" again.
    before = "",
    after = "", -- Undecided on whether or not to make this "" or "fg"
  },
})

-- Setting up keybinds for jumping between TODO labels
-- TODO: Consider adding more specifically for FIXMEs, TESTSs, or whatnot.
-- Is it possible to make this wrap, too?
vim.keymap.set("n", "]t", function()
  plugin.jump_next()
end, { desc = "Next todo comment"})

vim.keymap.set("n", "[t", function()
  plugin.jump_prev()
end, { desc = "Previous todo comment"})

