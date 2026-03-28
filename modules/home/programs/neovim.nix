{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    withPython3 = true;
    withNodeJs = true;

    # -- LSP / formatter / linter binaries in nvim's PATH -------------
    extraPackages = with pkgs; [
      # Language servers
      nil # Nix LSP
      lua-language-server
      pyright # Python LSP
      ruff # Python linter + formatter
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted # html/css/json/eslint
      gopls # Go LSP
      rust-analyzer
      terraform-ls
      helm-ls
      yaml-language-server
      bash-language-server
      taplo # TOML LSP

      # Formatters
      stylua
      nodePackages.prettier
      shfmt
      nixfmt

      # Tools used by plugins
      ripgrep
      fd
      tree-sitter
    ];

    plugins = with pkgs.vimPlugins; [
      lazy-nvim # plugin manager (installed via nix, loads Lua configs)
    ];

    # -- Bootstrap lazy.nvim and hand off to lua config ----------------
    initLua = ''
      -- -- Options ------------------------------------------------------
      vim.g.mapleader        = " "
      vim.g.maplocalleader   = " "

      local opt = vim.opt
      opt.number         = true
      opt.relativenumber = true
      opt.signcolumn     = "yes"
      opt.tabstop        = 2
      opt.shiftwidth     = 2
      opt.expandtab      = true
      opt.smartindent    = true
      opt.wrap           = false
      opt.ignorecase     = true
      opt.smartcase      = true
      opt.splitright     = true
      opt.splitbelow     = true
      opt.termguicolors  = true
      opt.cursorline     = true
      opt.scrolloff      = 8
      opt.undofile       = true
      opt.updatetime     = 200
      opt.clipboard      = "unnamedplus"

      -- -- Bootstrap lazy.nvim (nix-managed) ----------------------------
      local lazypath = "${pkgs.vimPlugins.lazy-nvim}/share/nvim/site/pack/lazy/opt/lazy.nvim"
      vim.opt.rtp:prepend(lazypath)

      -- -- Plugins -------------------------------------------------------
      require("lazy").setup({
        -- Colourscheme
        {
          "folke/tokyonight.nvim",
          lazy = false, priority = 1000,
          config = function() vim.cmd.colorscheme("tokyonight-night") end,
        },

        -- Status line
        { "nvim-lualine/lualine.nvim", opts = { theme = "tokyonight" } },

        -- File explorer
        {
          "nvim-neo-tree/neo-tree.nvim", branch = "v3.x",
          dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
          keys = { { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Explorer" } },
        },

        -- Fuzzy finder
        {
          "nvim-telescope/telescope.nvim",
          dependencies = { "nvim-lua/plenary.nvim" },
          keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>",  desc = "Find files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>",   desc = "Live grep"  },
            { "<leader>fb", "<cmd>Telescope buffers<cr>",     desc = "Buffers"    },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>",   desc = "Help"       },
          },
        },

        -- Treesitter
        {
          "nvim-treesitter/nvim-treesitter",
          build = ":TSUpdate",
          opts  = {
            ensure_installed = {
              "lua", "python", "typescript", "javascript", "go", "rust",
              "nix", "yaml", "json", "toml", "bash", "dockerfile",
              "hcl", "sql", "markdown", "markdown_inline",
            },
            highlight     = { enable = true },
            indent        = { enable = true },
            auto_install  = false,
          },
        },

        -- LSP
        {
          "neovim/nvim-lspconfig",
          config = function()
            local lsp = require("lspconfig")
            local servers = {
              "nil_ls", "lua_ls", "pyright", "ts_ls",
              "gopls", "rust_analyzer", "terraformls",
              "helm_ls", "yamlls", "bashls",
            }
            for _, s in ipairs(servers) do
              lsp[s].setup({})
            end
          end,
        },

        -- Completion
        {
          "hrsh7th/nvim-cmp",
          dependencies = {
            "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",     "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
          },
          config = function()
            local cmp  = require("cmp")
            local snip = require("luasnip")
            cmp.setup({
              snippet = { expand = function(a) snip.lsp_expand(a.body) end },
              mapping = cmp.mapping.preset.insert({
                ["<C-d>"]   = cmp.mapping.scroll_docs(-4),
                ["<C-f>"]   = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<CR>"]    = cmp.mapping.confirm({ select = true }),
              }),
              sources = cmp.config.sources({
                { name = "nvim_lsp" }, { name = "luasnip" },
                { name = "buffer"  }, { name = "path"    },
              }),
            })
          end,
        },

        -- Formatting
        {
          "stevearc/conform.nvim",
          opts = {
            formatters_by_ft = {
              lua        = { "stylua" },
              python     = { "ruff_format" },
              javascript = { "prettier" },
              typescript = { "prettier" },
              json       = { "prettier" },
              yaml       = { "prettier" },
              nix        = { "nixfmt" },
              sh         = { "shfmt" },
              go         = { "gofmt" },
            },
            format_on_save = { timeout_ms = 500, lsp_fallback = true },
          },
        },

        -- Which-key
        { "folke/which-key.nvim", event = "VeryLazy" },

        -- Git signs
        { "lewis6991/gitsigns.nvim", opts = {} },

        -- Diagnostics panel
        {
          "folke/trouble.nvim",
          keys = { { "<leader>xx", "<cmd>TroubleToggle<cr>", desc = "Trouble" } },
        },

        -- Comment
        { "numToStr/Comment.nvim", opts = {} },

        -- Auto-pairs
        { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

        -- Indent guides
        { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
      }, {
        -- lazy.nvim opts: don't try to fetch plugins (they come from nix or will be git-fetched)
        performance = { rtp = { disabled_plugins = { "gzip", "tarPlugin", "tofu", "zipPlugin" } } },
      })

      -- -- Key mappings --------------------------------------------------
      local map = vim.keymap.set
      map("n", "<leader>w",  "<cmd>w<cr>",          { desc = "Save" })
      map("n", "<leader>q",  "<cmd>q<cr>",           { desc = "Quit" })
      map("n", "<leader>bd", "<cmd>bd<cr>",          { desc = "Delete buffer" })
      map("n", "<Esc>",      "<cmd>nohl<cr>",        { desc = "Clear search" })

      -- Better window navigation
      map("n", "<C-h>", "<C-w>h")
      map("n", "<C-j>", "<C-w>j")
      map("n", "<C-k>", "<C-w>k")
      map("n", "<C-l>", "<C-w>l")

      -- Move lines
      map("v", "J", ":m '>+1<CR>gv=gv")
      map("v", "K", ":m '<-2<CR>gv=gv")
    '';
  };
}
