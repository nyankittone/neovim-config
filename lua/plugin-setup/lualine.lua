-- Bubbles config for lualine
-- Author: lokesh-krishna
-- MIT license, see LICENSE for more details.

local bubbles_theme = {
  normal = {
    a = { fg = '#080808', bg = '#c294ff', gui = "bold" },
    b = { fg = '#c6c6c6', bg = '#404050' },
    c = { fg = '#c6c6c6' },
  },

  insert = { a = { fg = '#080808', bg = '#50fa7b', gui = "bold"  } },
  visual = { a = { fg = '#080808', bg = '#f1fa8c', gui = "bold"  } },
  command = { a = { fg = '#080808', bg = '#ffb86c', gui = "bold" } },
  replace = { a = { fg = '#080808', bg = '#ff5555', gui = "bold"  } },

  inactive = {
    a = { fg = '#c6c6c6', bg = '#080808' },
    b = { fg = '#c6c6c6', bg = '#080808' },
    c = { fg = '#c6c6c6' },
  },
}

local onedark_alt = require 'lualine.themes.onedark'
onedark_alt.normal.c.bg = "#000000"

local thing
if require("get-term-colors") then
  thing = {
    theme = onedark_alt,
    comp_separators = { left = '💞', right = '✨'},
    sect_separators = { left = '', right = '' },
    left_separator = { left = ' '},
    right_separator = { right = ' ' },
  }
else
  thing = {
    theme = "16color",
    comp_separators = { left = "/", right = "/"},
    sect_separators = {},
    left_separator = {},
    right_separator = {},
  }
end

require('lualine').setup {
  options = {
    theme = thing.theme,
    component_separators = thing.comp_separators,
    section_separators = thing.sect_separators,
  },
  sections = {
    lualine_a = { { 'mode', fmt = function(str)
      return str:sub(1, 1) .. str:sub(2, str:len()):lower()
    end, separator = thing.left_separator, right_padding = 2 }},
    lualine_b = { 'filename', 'filesize', 'branch' },
    lualine_c = {
      '%=', --[[ add your center compoentnts here in place of this comment ]]
    },
    lualine_x = {},
    lualine_y = { 'encoding', 'filetype', 'progress' },
    lualine_z = {
      { 'location', separator = thing.right_separator, left_padding = 2 },
    },
  },
  inactive_sections = {
    lualine_a = { 'filename' },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { 'location' },
  },
  tabline = {},
  extensions = {},
}
