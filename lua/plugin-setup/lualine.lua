-- Lualine config brainstorming
-- I want to have the bar be one solid entity. Unlike the last bar.
-- It should be noticeably brighter for windows currently focused, but still easily visible for
-- unfocused windows.
-- Different colors should be used for different modes like normal. And it should be adaptable
-- between all of my themes, and when switching themes.
-- It should be somewhat verbose.

local theme
local section_separators
local error_symbols

if require 'get-term-colors' == false then
  theme = '16color'
  section_separators = ''
  error_symbols = {error = 'E:', warn = 'W:', info = 'I:', hint = 'H:'}
else
  theme = 'auto'
  section_separators = {left = '', right = ''}
  error_symbols = {error = ' ', warn = ' ', info = '󰋽 ', hint = '󰌶 '}
end

local function colon_three(amount)
  local final_string = ':3'
  for _=2,amount,1 do
    final_string = final_string .. ' :3'
  end

  return function()
    return final_string
  end
end

local config = {
  options = {
    theme = theme,
    component_separators = '/',
    section_separators = section_separators,
  },
  sections = {
    lualine_a = {{'filename', color = {gui = 'bold'}}},
    lualine_b = { 'filesize', 'encoding', 'filetype'},
    lualine_c = {'branch', 'diff', {
      'diagnostics',
      symbols = error_symbols,
    }},
    lualine_x = {'searchcount', 'selectioncount'},
    lualine_y = {'location', 'progress'},
    lualine_z = {{colon_three(3), color = {gui = 'bold'}}},
  },
}

require('lualine').setup(config)

