-- This config is written in one file to optimize loading speeds for it.
-- No Mason or mason-lspconfig is uesd for LSP; we're just going to use lspconfig as-is.

-- Setting leader keys to Space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrapping Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

--[[ TODO: Should do:
    Notes-taking plugin
    Removal of lspconfig to reduce startup times
    Keybinds for quickfix lists and undo tree
--]]

-- Setting up LSP and related keybinds
local function lsp_on_attach(_, buffer_number)
    local function nmap(keys, fn, description)
        if description then
            description = "LSP:" .. description
        end

        vim.keymap.set("n", keys, fn, {buffer = buffer_number, desc = description})
    end

    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

    nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
    nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
    nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

    -- I might consider disabling this bind entirely; what does this do that vim.lsp.buf.hover
    -- doesn't?
    -- This keybind was previously <C-k> I think. Might switch it back in the future.
    nmap('<C-s>', vim.lsp.buf.signature_help, 'Signature Documentation')

    -- Lesser used LSP functionality
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    nmap('<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, '[W]orkspace [L]ist Folders')

    vim.api.nvim_buf_create_user_command(buffer_number, 'Format', function(_)
        vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })
end

local function lua_ls_init(client)
    if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc') then
            return
        end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
            -- Tell the language server which version of Lua you're using
            -- (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT'
        },
        -- Make the server aware of Neovim runtime files
        workspace = {
            checkThirdParty = false,
            library = {
                vim.env.VIMRUNTIME
                -- Depending on the usage, you might want to add additional paths here.
                -- "${3rd}/luv/library"
                -- "${3rd}/busted/library",
            }
            -- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
            -- library = vim.api.nvim_get_runtime_file("", true)
        }
    })
end

-- Configuring plugins
require("lazy").setup {
    {
        "folke/todo-comments.nvim",
        dependencies = {"nvim-lua/plenary.nvim"},
        opts = {
            highlight = {
                mukltiline = false,
                before = "",
                after = "",
            },
        },
    },

    {
        "iamcco/markdown-preview.nvim",
        cmd = {"MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop"},
        ft = { "markdown" },
        build = function() vim.fn["mkdp#util#install"]() end,

        config = function()
            vim.g.mkdp_auto_close = 0
        end,
    },

    -- TODO: Make this lazy-loadable! Currently, it's awkward, because the highlighter won't work
    -- until the plugin is loaded, but there doesn't appear to be any custom event for that.
    {
        "uga-rosa/ccc.nvim",
        opts = {
            auto_enable = true,
            lsp = true,
            preserve = true,
            alpha = "auto",
            highlighter = {
                auto_enable = true,
            },
        },
    },

    {
        "christoomey/vim-tmux-navigator",
        cmd = {
            "TmuxNavigateLeft",
            "TmuxNavigateDown",
            "TmuxNavigateUp",
            "TmuxNavigateRight",
            "TmuxNavigatePrevious",
        },
        keys = {
            { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
            { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
            { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
            { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
            { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
        },
    },

    -- TODO: I'm not sure if the treesitter stuff here is working 100% as it should.
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup {
                ensure_installed = {"c", "lua", "cpp", "markdown", "go", "rust", "java", "python", "javascript", "html"},
                highlight = {
                    enable = true,
                },
                 keymaps = {
                     init_selection = "gnn",
                     node_incremental = "grn",
                     scope_incremental = "grc",
                     node_decremental = "grm",
                 },
            }

            -- Uncomment these lines to enable code folding.
            -- vim.wo.foldmethod = "expr"
            -- vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end,
    },

    -- TODO: Figure out how to add a keybind to take a screenshot! The officially documented way
    -- isn't working...
    {
        "mistricky/codesnap.nvim",
        build = "make",
        cmd = {
            "CodeSnap",
            "CodeSnapSave",
        },
        opts = {
            save_path = "~/Pictures/Neovim",
            has_breadcrumbs = true,
            bg_color = "#11141b",
            watermark = ":3",
            code_font_family = "JetBrainsMono Nerd Font",
        },
    },

    {
        "neovim/nvim-lspconfig",
        ft = {"c", "cpp", "java", "python", "javascript", "rust", "go", "html", "typescript", "sh", "bash", "lua", "nix"},

        -- I may replace this with nvim_cmp in the future, gonna be real
        dependencies = {
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },

        -- TODO: Verify that, when the LSP is started, not every lsp known to man is started
        -- at once.
        config = function()
            local lsp = require "lspconfig"
            local cmp = require "cmp"
            local snip = require "luasnip"

            cmp.setup {
                snippet = {
                    expand = function(args)
                        snip.lsp_expand(args.body)
                    end,
                },
                completion = {
                    completeopt = "menu,menuone,noinsert",
                },
                mapping = cmp.mapping.preset.insert {
                    ['<C-n>'] = cmp.mapping.select_next_item(),
                    ['<C-p>'] = cmp.mapping.select_prev_item(),
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete {},
                },
                sources = cmp.config.sources {
                    {name = "nvim_lsp"},
                    {name = "luasnip"},
                    {name = "path"},
                },
            }

            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

            for _, server_name in ipairs {
                "clangd",
                "gopls",
                "rust_analyzer",
                "pyright",
                "ts_ls",
                "jdtls",
                "bashls",
                "lua_ls",
                "htmx",
                "nil_ls",
            } do
                -- TODO: Fix lua_ls integration being sliiiiightly broken.
                if server_name == "lua_ls" then
                    lsp["lua_ls"].setup {
                        on_init = lua_ls_init,
                        settings = {
                            Lua = {}
                        },
                        capabilities = capabilities,
                        on_attach = lsp_on_attach,
                    }
                else
                    lsp[server_name].setup {
                        capabilities = capabilities,
                        on_attach = lsp_on_attach,
                    }
                end
            end
        end,
    },

    {
         "nvim-telescope/telescope.nvim",
         branch = "0.1.x",
         dependencies = {
             "nvim-lua/plenary.nvim",
             "debugloop/telescope-undo.nvim",
         },

         -- Having Telescope be lazy-loaded like this is HELLA goofy and brittle. I should find a
         -- better way...
         keys = {
             {"<leader>ff"},
             {"<leader>fr"},
             {"<leader><space>"},
             {"<leader>fh"},
             {"<leader>fc"},
             {"<leader>fC"},
             {"<leader>fm"},
             {"<leader>fi"},
             {"<leader>fd"},
             {"<leader>gf"},
             {"<leader>gc"},
             {"<leader>gb"},
             {"<leader>gs"},
             {"<leader>u", "<cmd>Telescope undo<cr>"},
         },

         config = function()
             pcall(require("telescope").load_extension, "fzf")

             -- Setting up things so that we can ripgrep through dotfiles
             local vimgrep_arguments = {unpack(require("telescope.config").values.vimgrep_arguments)}
             table.insert(vimgrep_arguments, "--hidden")
             table.insert(vimgrep_arguments, "--glob")
             table.insert(vimgrep_arguments, "!**/.git/*")

             -- Continuing said setup for that, plus some extra shit
             require("telescope").setup {
                 defaults = {
                     vimgrep_arguments = vimgrep_arguments,
                 },
                 pickers = {
                     find_files = {
                         find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*"},
                     },
                 },
                 extensions = {
                     undo = {
                         side_by_side = true,
                         entry_format = "#$ID, $STAT, $TIME",
                         layout_strategy = "vertical",

                         mappings = {
                             i = {
                                 ["<C-y>"] = require("telescope-undo.actions").yank_deletions,
                                 ["<C-r>"] = require("telescope-undo.actions").restore,
                             },
                         },
                     },
                 },
             }

            require("telescope").load_extension("undo")

             local function map(keys, fn, description)
                 if description then
                     description = "Telescope: " .. description
                 end

                 vim.keymap.set("n", keys, fn, {desc = description})
             end

             local telescope = require "telescope.builtin"

             -- Telescope-specific keybinds
             map("<leader>ff", telescope.find_files, "[F]ind [F]iles")
             map("<leader>fr", telescope.live_grep, "[F]ind with [R]egex")
             map("<leader><space>", telescope.buffers, "Find Buffers")
             map("<leader>fh", telescope.help_tags, "[F]ind [H]elp")

             -- Will probably remove one of these... I must experiment
             map("<leader>fc", telescope.commands, "[F]ind [C]ommands")
             map("<leader>fC", telescope.command_history, "[F]ind [C]command history")

             -- TODO: might remove; do I really want to look at manpages through vim?
             map("<leader>fm", telescope.man_pages, "[F]ind [M]anpage")
             map("<leader>fi", telescope.current_buffer_fuzzy_find, "[F]ind [I]nside current buffer")
             map("<leader>fd", telescope.diagnostics, "[F]ind [D]iagnostics")

             -- Git-related keybinds
             map("<leader>gf", telescope.git_files, "Show [G]it [F]iles")
             map("<leader>gc", telescope.git_commits, "[G]it [C]ommits")
             map("<leader>gb", telescope.git_branches, "[G]it [B]ranches")
             map("<leader>gs", telescope.git_status, "[G]it [S]tatus")

             -- TODO: Investigate switching some of the keybinds within the Telescope window.
             -- Namely, the binds for moving up and down from insert mode.
         end,
    },

    -- TODO: Look for an alternative to this that hooks into telescope... also look into using
    -- telescope and treesitter like wayyyyy more girlie
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        keys = {
            {"<leader>p", "<cmd>Neotree toggle float<cr>"},
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
            opts = {
                close_if_last_window = true,
                enable_git_status = false,
                enable_diagnostics = true,
            },
        },
    },

    {
        "numToStr/Comment.nvim",
        keys = {
            {mode = {"n"}, "gcc", "gbc", "gcO", "gco"},
            {mode = {"v"}, "gc", "gb"},
        },
        opts = {},
    },

    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = {
            integrations = {
                gitsigns = false,
                notify = false,
            },
        },
    },
}

-- Setting up keybinds
vim.keymap.set("n", "]t", function()
    require("todo-comments").jump_next()
end, {desc = "Next todo comment"})

vim.keymap.set("n", "[t", function()
    require("todo-comments").jump_prev()
end, {desc = "Previous todo comment"})

vim.keymap.set("n", "<leader>cp", "<cmd>CccPick<cr>", {desc = "Open color picker"})
vim.keymap.set("n", "<leader>cc", "<cmd>CccConvert<cr>", {desc = "Convert color format"})

vim.keymap.set("n", "<leader>m", "<cmd>MarkdownPreviewToggle<cr>", {desc = "Toggle markdown preview"})

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

local function set_indent(n)
    return function()
        vim.bo.shiftwidth = 0
        vim.bo.tabstop = n

        print("Set indentation to " .. n .. " spaces")
    end
end

vim.keymap.set("n", "<leader>i2", set_indent(2), {desc = "Set indentation to 2 spaces"})
vim.keymap.set("n", "<leader>i3", set_indent(3), {desc = "Set indentation to 3 spaces"})
vim.keymap.set("n", "<leader>i4", set_indent(4), {desc = "Set indentation to 4 spaces"})
vim.keymap.set("n", "<leader>i6", set_indent(6), {desc = "Set indentation to 6 spaces"})
vim.keymap.set("n", "<leader>i8", set_indent(8), {desc = "Set indentation to 8 spaces"})

vim.keymap.set("n", "<leader>it", function()
  vim.o.expandtab = false
  print "Using tabs for indentation"
end, {desc = "Use tabs instead of spaces"})

vim.keymap.set("n", "<leader>is", function()
  vim.o.expandtab = true
  print "Using spaces for indentation"
end, {desc = "Use spaces instead of tabs"})

-- Setting up autocommands
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
    pattern = "*",
})

vim.api.nvim_create_autocmd("ColorScheme", {
    desc = "fix up a few rough edges with the colorscheme I use :3",
    callback = function()
        if vim.g.colors_name == "catppuccin-latte" then
            vim.api.nvim_set_hl(0, "Normal", {})
            vim.api.nvim_set_hl(0, "NormalNC", {})
        end
    end,
})

-- Setting options
vim.o.bg = "dark"
vim.o.breakindent = true
vim.o.cc = "100"
vim.o.cindent = true
vim.o.cinoptions = "1s"
vim.o.compatible = false
vim.o.completeopt = "menuone,noselect"
vim.o.cursorline = true
vim.o.cursorlineopt = "both"
vim.o.errorbells = true
vim.o.expandtab = true
vim.o.hlsearch = false
vim.o.ignorecase = true
vim.o.incsearch = true
vim.o.linebreak = true
vim.o.number = true
vim.o.scrollback = 9001
vim.o.scrolloff = 8
vim.o.shiftwidth = 0
vim.o.showmatch = true
vim.o.smartcase = true
vim.o.spell = true
vim.o.tabstop = 4
vim.o.timeoutlen=1000
vim.o.title = true
vim.o.titlestring = "%F - Neovim"
vim.o.undofile = true
vim.o.updatetime = 250
vim.o.wildmenu = true
vim.o.wrap = true

-- Setting the colorscheme
vim.cmd.colorscheme "catppuccin-latte"

