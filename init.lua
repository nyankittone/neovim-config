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

local function map(mode, prefix)
    return function(keys, fn, description)
        if description then
            description = prefix .. ": " .. description
        end

        vim.keymap.set(mode, keys, fn, {desc = description})
    end
end

local function umap(keys, command, description)
    for _, mode in ipairs {"n", "i", "t", "v", "s"} do
        if description then
            vim.keymap.set(mode, "<C-Space>" .. keys, command, {desc = "Universal: " .. description})
        else
            vim.keymap.set(mode, "<C-Space>" .. keys, command)
        end
    end
end

local function umap_gen_all(strings)
    local returned = {}

    for _, str in ipairs(strings) do
        for _, key_seq in ipairs {"n", "i", "t", "v", "s"} do
            table.insert(returned, {key_seq, "<C-Space>" .. str})
        end
    end

    return returned
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
        "vimwiki/vimwiki",
        ft = {
            "markdown",
            "wiki",
        },
    },

    "tpope/vim-fugitive",

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
            auto_enable = false,
            lsp = true,
            preserve = true,
            alpha = "auto",
            highlighter = {
                auto_enable = true,
                excludes = {""}, -- Preventing buffers that don't have a file type (e.g. terminals)
                                 -- from being highlighted.
            },
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

    -- TODO: Remove lspconfig; manage LSP configurations without any plugins.
    -- I still want to use nvim-cmp, though.
    {
        "neovim/nvim-lspconfig",
        ft = {"c", "cpp", "java", "python", "javascript", "rust", "go", "html", "typescript", "sh", "bash", "lua", "nix"},

        dependencies = {
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },

        config = function()
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
                    ['<C-v>'] = cmp.mapping.complete {},
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
                "qmlls",
            } do
                if server_name == "lua_ls" then
                    vim.lsp.config["lua_ls"] = {
                        on_init = lua_ls_init,
                        settings = {
                            Lua = {}
                        },
                        capabilities = capabilities,
                        on_attach = lsp_on_attach,
                        unpack(vim.lsp.config.lua_ls)
                    }
                else
                    vim.lsp.config[server_name] = {
                        capabilities = capabilities,
                        on_attach = lsp_on_attach,
                        unpack(vim.lsp.config[server_name])
                    }
                end

                vim.lsp.enable(server_name)
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

         -- TODO: Lazy-load this sucker. Right now I have it turned off for convenience.

         config = function()
             pcall(require("telescope").load_extension, "fzf")

             -- Setting up things so that we can ripgrep through dotfiles
             local vimgrep_arguments = {unpack(require("telescope.config").values.vimgrep_arguments)}
             table.insert(vimgrep_arguments, "--hidden")
             table.insert(vimgrep_arguments, "--glob")
             table.insert(vimgrep_arguments, "!**/.git/*")

             local actions = require("telescope.actions")
             local state = require("telescope.actions.state")

             local function gen_binds(strat)
                 local function meow(callback, window_strat)
                     return function(_)
                         local thing = state.get_selected_entry()
                         vim.cmd.stopinsert()
                         vim.cmd("quit!")

                         window_strat()
                         callback(thing)
                     end
                 end

                 local retpart = {
                     ["<C-r>"] = meow(strat, function() end),
                     ["<C-s>"] = meow(strat, function()
                         vim.api.nvim_open_win(0, true, {
                             split = "below",
                             win = 0,
                         })
                     end),
                     ["<C-v>"] = meow(strat, function()
                         vim.api.nvim_open_win(0, true, {
                             split = "right",
                             win = 0,
                         })
                     end),
                     ["<C-t>"] = meow(strat, vim.cmd.tabnew),
                 }

                 return {
                     n = retpart,
                     i = retpart,
                 }
             end

             -- Continuing said setup for that, plus some extra shit
             require("telescope").setup {
                 defaults = {
                     vimgrep_arguments = vimgrep_arguments,

                     mappings = {
                         i = {
                             ["<C-r>"] = actions.select_default,
                             ["<C-s>"] = actions.select_horizontal,
                             ["<C-v>"] = actions.select_vertical,
                         },
                     },
                 },
                 pickers = {
                     find_files = {
                         find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*"},

                         mappings = gen_binds(function(selection)
                             vim.cmd.edit(selection[1])
                         end)
                     },
                     man_pages = {
                         sections = { "ALL" },

                         mappings = gen_binds(function(manpage)
                             vim.cmd("hide Man " .. manpage.section .. " " .. manpage.ordinal)
                         end),
                     },
                     buffers = {
                         mappings = gen_binds(function(selected)
                             vim.api.nvim_set_current_buf(selected.bufnr)
                         end),
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

             local telescope = require "telescope.builtin"
             local tmap = map("n", "Telescope")

             -- Telescope-specific keybinds
             umap("f", telescope.find_files, "Find [F]iles")
             umap("R", telescope.live_grep, "Find with [R]egex")
             umap("<space>", telescope.buffers, "Find Buffers")
             umap("h", telescope.help_tags, "Find [H]elp")

             tmap("<leader>fc", telescope.command_history, "[F]ind [C]command history")
             tmap("<leader>u", require("telescope").extensions.undo.undo, "Open [U]ndo history")

             umap("m", telescope.man_pages, "[F]ind [M]anpage")
             tmap("<leader>fd", telescope.diagnostics, "[F]ind [D]iagnostics")

             -- Git-related keybinds
             umap("gf", telescope.git_files, "Show [G]it [F]iles")
             umap("gc", telescope.git_commits, "[G]it [C]ommits")
             umap("gb", telescope.git_branches, "[G]it [B]ranches")
             umap("gs", telescope.git_status, "[G]it [S]tatus")

             -- TODO: Investigate switching some of the keybinds within the Telescope window.
             -- Namely, the binds for moving up and down from insert mode.
         end,
    },

    -- TODO: Configure Neotree more in-depth. Also see if it meshes nicely with Oil.nvim, and if
    -- not, if I should remove this plugin.
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        keys = {
            {"<leader>p", "<cmd>Neotree toggle float .<cr>"},
            {"<leader>G", "<cmd>Neotree toggle float git_status .<cr>"},
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
            opts = {
                close_if_last_window = true,
                enable_git_status = false,
                enable_diagnostics = true,
                sort_case_insensitive = true,

                default_component_configs = {
                    git_status = {
                        symbols = {
                            added = "+",
                            modified = "~",
                            deleted = "-",
                        },
                    },
                },

                filesystem = {
                    filtered_items = {
                        hide_dotfiles = false,
                        hide_gitignored = false,
                    },
                },
            },
        },
    },

    {
        "stevearc/oil.nvim",
        dependencies = {
            {
                "nvim-mini/mini.icons",
                opts = {
                    default_file_explorer = true,
                    columns = {
                        "icon",
                        "permissions",
                        "size",
                    },
                    buf_options = {
                        buflisted = true,
                    },
                    delete_to_trash = true,
                    skip_confirm_for_simple_edits = true,
                    cleanup_delay_ms = 10000,
                    constrain_cursor = "editable",
                    watch_for_changes = true,
                    show_hidden = true,
                    natural_order = false,
                    case_insensitive = true,
                },
            },
        },
        opts = {},
        lazy = false,
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

    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        config = true,
        opts = {},
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

vim.keymap.set("n", "[d", function() vim.diagnostic.jump({count = 1, float = true}) end, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({count = -1, float = true}) end, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

local function set_indent(n)
    return function()
        vim.bo.shiftwidth = 0
        vim.bo.tabstop = n

        print("Set indentation to " .. n .. " spaces")
    end
end

for i = 1,9 do
    vim.keymap.set("n", "<leader>i" .. i, set_indent(i), {desc = "Set indentation to " .. i .. " spaces"})
end

vim.keymap.set("n", "<leader>it", function()
  vim.o.expandtab = false
  print "Using tabs for indentation"
end, {desc = "Use tabs instead of spaces"})

vim.keymap.set("n", "<leader>is", function()
  vim.o.expandtab = true
  print "Using spaces for indentation"
end, {desc = "Use spaces instead of tabs"})

-- May remove this at some point
vim.keymap.set("n", "<leader>o", "<CMD>Oil<CR>", {desc = "Open file manager in parent directory"})

vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h")
vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j")
vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k")
vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l")

local function command_or_func(thing)
    if type(thing) == "string" then
        vim.cmd(thing)
    end
    if type(thing) == "function" then
        thing()
    end
end

local function spawn_term()
    vim.cmd.terminal()
    vim.api.nvim_input("i")
end

local function spawn_horiz(command)
    return function()
        vim.cmd ([[
            split
            wincmd j
        ]])

        command_or_func(command)
    end
end

local function spawn_vert(command)
    return function()
        vim.cmd ([[
            vsplit
            wincmd l
        ]])

        command_or_func(command)
    end
end

local function spawn_in_place(command)
    return function()
        command_or_func(command)
    end
end

local function spawn_tab(command)
    return function()
        vim.cmd.tabnew()
        command_or_func(command)
    end
end

umap("s", spawn_horiz(spawn_term))
umap("v", spawn_vert(spawn_term))
umap("r", spawn_in_place(spawn_term))
umap("t", spawn_tab(spawn_term))
-- generate_launch("t", spawn_term)

umap(":", function()
    vim.cmd.stopinsert()
    vim.api.nvim_input(":")
end)

umap("n", vim.cmd.stopinsert, "Exit insert mode")

-- I may instead this return and do nothing else if the requested tab doesn't exist, and then have a
-- different key sequence for making new tabs.
for i = 1,10 do
    umap(i % 10, function()
        if i <= #(vim.api.nvim_list_tabpages()) then
            vim.api.nvim_set_current_tabpage(i)
        end
    end)
end

-- Bind for moving windows between tabs? Idk if I'd find this useful.
-- We should also like 100000% fix the issue where the neovim terminal freezes when it's doing too
-- much...
-- We should set up sessions to work better!

-- Setting up autocommands
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
    pattern = "*",
})

vim.api.nvim_create_autocmd("TermOpen", {
    desc = "Terminal emulator configuration",
    callback = function()
        vim.wo.spell = false
    end,
})

vim.api.nvim_create_autocmd("WinEnter", {
    desc = "Automatically enter terminal mode when switching to a terminal window",
    callback = function()
        if vim.bo.buftype == "terminal" then
            vim.api.nvim_input("i") -- Goofy-aah way of entering terminal mode
        end
    end,
})

vim.api.nvim_create_autocmd("TermRequest", {
  desc = 'Handles OSC 7 dir change requests',
  callback = function(ev)
    local val, n = string.gsub(ev.data.sequence, '\027]7;file://[^/]*', '')
    if n > 0 then
      -- OSC 7: dir-change
      local dir = val
      if vim.fn.isdirectory(dir) == 0 then
        vim.notify('invalid dir: '..dir)
        return
      end
      vim.b[ev.buf].osc7_dir = dir
      if vim.api.nvim_get_current_buf() == ev.buf then
        vim.cmd.lcd(dir)
      end
    end
  end
})

vim.api.nvim_create_autocmd("ColorScheme", {
    desc = "fix up a few rough edges with the colorscheme I use :3",
    callback = function()
            vim.api.nvim_set_hl(0, "Normal", {})
            vim.api.nvim_set_hl(0, "NormalNC", {})
    end,
})

-- Configuring diagnostics
vim.diagnostic.config({
    virtual_text = true,
    -- virtual_lines = true,
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
vim.o.tw = 100

-- Setting the colorscheme
vim.cmd.colorscheme "gruvbox"

