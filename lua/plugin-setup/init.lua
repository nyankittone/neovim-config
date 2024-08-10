-- Making Lazy.nvim install, and perhaps even set up my plugins!
-- Not everything is set up here; some stuff, like my colorschemes, are set up outside of here, but
-- defined here.

require('lazy').setup({
  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- TODO: Setup custom stuff for this plugin, please.(i.e, custom colors)
  -- FIXIT: There's a problem where having this plugin enabled prevents Neovim's startup text from
  -- appearing properly. Fix that maybe? Not the end of the world, but pretty annoying for me tbh.
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require 'plugin-setup/todo-comments'
    end,
  },

  -- Detect tabstop and shiftwidth automatically (disabled currently)
  -- TODO: Find a replacement plugin for this, that is more configureable and allows for being
  -- overridden for certain types of files (e.g. go files :3)
  --'tpope/vim-sleuth',

  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      -- Might remove this from the config!
      { 'j-hui/fidget.nvim', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  --'WhoIsSethDaniel/mason-tool-installer',

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },

  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    config = function()
      require "plugin-setup/gitsigns"
    end,
    event = "VeryLazy",
  },

  {
    "folke/tokyonight.nvim",
    -- lazy = true,
    priority = 1000,
    opts = {
      style = 'storm',
      transparent = false,
      on_colors = function(colors)
        colors.bg = "#05070a"
      end,
    },
  },

  {
    "Mofiqul/dracula.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require "plugin-setup/dracula"
    end,
  },

  -- Set lualine as status line if the terminal supports more than 8 colors. Else, just use the
  -- default nvim status line.
  {
    'nvim-lualine/lualine.nvim',
    config = function()
      require 'plugin-setup/lualine'
    end,
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', lazy = true, opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    -- This list of keys will need to be updated each time we add a keybind to telescope lmao
    keys = {
        {'<leader>sf'},
        {'<leader>s/'},
        {'<leader>ss'},
        {'<leader>gf'},
        {'<leader>sf'},
        {'<leader>sh'},
        {'<leader>sw'},
        {'<leader>sg'},
        {'<leader>sG'},
        {'<leader>sd'},
        {'<leader>sr'},
        {'<leader>sm'},
        {'<leader>sc'},
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },

    config = function()
      require 'plugin-setup/telescope'
    end,
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  -- Plugin for taking code screenshots
  -- TODO: Lazy-load this plugin.
  {
    'mistricky/codesnap.nvim',
    build = 'make',
    config = function()
      require 'plugin-setup/codesnap'
    end,
  },

  -- Plugin for adding Discord presence to the editor (Discord will show me as "playing Neovim"!)
  'andweeb/presence.nvim',

  -- Really awesome plugin for previewing Markdown text :3
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
    config = function()
      require 'plugin-setup/markdown-preview'
    end,
  }
  -- Some example plugins that came bundled with kickstart.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this file if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  -- { import = 'custom.plugins' },
}, {
  checker = {},
})

