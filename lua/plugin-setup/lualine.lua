-- Bubbles config for lualine
-- Author: lokesh-krishna
-- MIT license, see LICENSE for more details.

-- stylua: ignore
local colors = {
  blue   = '#80a0ff',
  cyan   = '#79dac8',
  black  = '#080808',
  white  = '#c6c6c6',
  red    = '#ff5555',
  violet = '#c294ff',
  grey   = '#404050',
  green  = '#50fa7b',
  yellow = '#f1fa8c',
  orange = '#ffb86c'
}

local bubbles_theme = {
  normal = {
    a = { fg = colors.black, bg = colors.violet },
    b = { fg = colors.white, bg = colors.grey },
    c = { fg = colors.white },
  },

  insert = { a = { fg = colors.black, bg = colors.green } },
  visual = { a = { fg = colors.black, bg = colors.yellow } },
  command = { a = { fg = colors.black, bg = colors.orange} },
  replace = { a = { fg = colors.black, bg = colors.red } },

  inactive = {
    a = { fg = colors.white, bg = colors.black },
    b = { fg = colors.white, bg = colors.black },
    c = { fg = colors.white },
  },
}

require('lualine').setup {
  options = {
    theme = "palenight",
    component_separators = { left = '💞', right = '✨'},
    section_separators = { left = '', right = '' },
  },
  sections = {
    lualine_a = { { 'mode', fmt = function(str)
      return str:sub(1, 1) .. str:sub(2, str:len()):lower()
    end, separator = { left = ' '}, right_padding = 2 }},
    lualine_b = { 'filename', 'filesize', 'branch' },
    lualine_c = {
      '%=', --[[ add your center compoentnts here in place of this comment ]]
    },
    lualine_x = {},
    lualine_y = { 'encoding', 'filetype', 'progress' },
    lualine_z = {
      { 'location', separator = { right = ' ' }, left_padding = 2 },
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
