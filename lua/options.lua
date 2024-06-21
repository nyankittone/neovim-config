--[[ Options that would normally be set via ":set optionname" while Neovim is
     running. ]]
for _, value in ipairs({
  "bg=dark",
  "breakindent",
  "cc=100",
  "cindent",
  "cinoptions=1s",
  "completeopt=menuone,noselect", -- Relates to autocomplete (particularly for LSP? Maybe?)
  "confirm", -- Adds a confirmation text when, for example, trying to exit without saving.
  "cursorline",
  "cursorlineopt=number", -- TODO: consider switching this to "both" or "line" in the future.
  "errorbells",
  "expandtab",
  "ignorecase",
  "incsearch",
  "linebreak",
  "mouse=",
  "nocompatible",
  "nohlsearch",
  "number", -- hopefully having this here will cause no issues...
  "scrolloff=8",
  "shiftwidth=0",
  "showmatch",
  "smartcase",
  "tabstop=4",
  "timeoutlen=300",
  "title",
  "titlestring=%F\\ -\\ Neovim",
  "undofile",
  "updatetime=250",
  "wildmenu",
  "wrap",
}) do
  vim.cmd("set " .. value)
end

