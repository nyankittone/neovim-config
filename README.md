# What is this?
This is my personal Neovim configuration. It's designed to be lean and fast to start up with a
small footprint, and is meant to be run under a tmux session with possibly many other Neovim
instances running.

The entire config is only a single file, ~500 lines of code long. Many common plugins that I deem
not useful, such as Mason(-lspconfig), and lualine, that have significant implications on startup
time, are omitted. Any fancy plugins in here that aren't required on editor startup are lazy-loaded
to hell and back to keep everything fast.

## Improvements I want to make
* Consider removing lspconfig; it's adding a lot of startup time.
* Configure quickfix lists
* Configure a notes-taking pluigin (lazy-loaded ofc) - I'm thinking VimWiki, since I like editing
  Markdown.
* Create better uses for LuaSnip and nvim-treesitter
  * For nvim-treesitter in particular, I *might* abandon the plugin if I can't amke it work for my
    needs. All it's being used for right now is syntax highlighting - which to be fair, it's *much*
    better at than the default highlighting.
* The markdown-preview plugin I use here may be broken. I should fix that, if so.

