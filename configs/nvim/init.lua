-- ========================================================================== --
-- Neovim Minimalist Configuration for Rust, Python, Code Review & Markdown
-- ========================================================================== --

-- 1. BASIC SETTINGS
-- -----------------------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Ensure Mason installed language servers (rust-analyzer, pyright, marksman) are in PATH
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

local opt = vim.opt
opt.number = true               -- Show line numbers
opt.relativenumber = true       -- Relative line numbers for fast jumping
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true            -- Use spaces instead of tabs
opt.smartindent = true
opt.wrap = false                -- Default no wrap for code
opt.termguicolors = true        -- True color support
opt.signcolumn = "yes"          -- Always show signcolumn for git & diagnostics
opt.cursorline = true           -- Highlight the current line
opt.clipboard = "unnamedplus"   -- Sync with system clipboard
opt.splitright = true           -- Vertical splits open to the right
opt.splitbelow = true           -- Horizontal splits open below
opt.undofile = true             -- Persistent undo history
opt.updatetime = 250            -- Faster completion & gitsigns refresh
opt.timeoutlen = 300            -- Faster key sequence timeout
opt.mouse = "a"                 -- Mouse support enabled

-- Clear search highlight on Esc
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { silent = true })

-- Easy window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window Left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window Down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window Up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window Right" })

-- 2. FILETYPE SETTINGS (Markdown & Rust/Python)
-- -----------------------------------------------------------------------------
local ft_group = vim.api.nvim_create_augroup("FileTypeOverrides", { clear = true })

-- Markdown: soft wrapping, line breaking at word boundary, conceal level for formatting
vim.api.nvim_create_autocmd("FileType", {
  group = ft_group,
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
    vim.opt_local.conceallevel = 2
  end,
})

-- Rust & Python specific indentation
vim.api.nvim_create_autocmd("FileType", {
  group = ft_group,
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = ft_group,
  pattern = "rust",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
  end,
})

-- 3. TRANSPARENCY ENFORCEMENT (Inherit Terminal Background)
-- -----------------------------------------------------------------------------
local function set_transparency()
  local highlights = {
    "Normal", "NormalNC", "SignColumn", "NormalFloat", "FloatBorder",
    "TelescopeNormal", "TelescopeBorder", "LineNr", "CursorLineNr",
    "Folded", "NonText", "SpecialKey", "VertSplit", "WinSeparator",
    "StatusLine", "StatusLineNC",
  }
  for _, hl in ipairs(highlights) do
    vim.api.nvim_set_hl(0, hl, { bg = "none", ctermbg = "none" })
  end
end

vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  group = ft_group,
  callback = set_transparency,
})

-- 4. BOOTSTRAP LAZY.NVIM
-- -----------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 5. PLUGIN SPECIFICATIONS
-- -----------------------------------------------------------------------------
require("lazy").setup({
  -- A. THEME (Transparent Tokyo Night to blend with Cosmic Terminal)
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight-moon")
      set_transparency()
    end,
  },

  -- B. ICONS
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- C. CODE REVIEW & GIT WORKFLOW
  -- 1) Git signs, hunk diff previews, inline blame
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = " " },
        topdelete    = { text = "▔" },
        changedelete = { text = "▎" },
      },
      current_line_blame_opts = {
        delay = 300,
        virt_text_pos = "eol",
      },
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        -- Hunk navigation
        map("n", "]c", function() gs.nav_hunk("next") end, "Next Git Hunk")
        map("n", "[c", function() gs.nav_hunk("prev") end, "Prev Git Hunk")

        -- Review actions
        map("n", "<leader>hp", gs.preview_hunk, "Preview Hunk Diff")
        map("n", "<leader>hs", gs.stage_hunk, "Stage Hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset Hunk")
        map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle Inline Git Blame")
        map("n", "<leader>hd", gs.diffthis, "Diff File Against Index")
      end,
    },
  },

  -- 2) Full side-by-side Git Diffview & PR Review
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Diffview: Open Review (Working Tree / Branch)" },
      { "<leader>gc", "<cmd>DiffviewClose<CR>", desc = "Diffview: Close Review" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "Diffview: Current File Git History" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "Diffview: Branch Git History" },
    },
  },

  -- D. FUZZY FINDER (Powered by system fzf & ripgrep)
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<CR>", desc = "Find Files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<CR>", desc = "Live Ripgrep Search" },
      { "<leader>fb", "<cmd>FzfLua buffers<CR>", desc = "List Buffers" },
      { "<leader>gs", "<cmd>FzfLua git_status<CR>", desc = "Git Changed Files" },
      { "<leader>gl", "<cmd>FzfLua git_commits<CR>", desc = "Git Commit Log" },
    },
    opts = {
      winopts = {
        preview = { default = "bat" },
      },
    },
  },

  -- E. SYNTAX HIGHLIGHTING (Treesitter for Rust, Python, Markdown)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "rust", "python", "markdown", "markdown_inline",
          "toml", "json", "yaml", "bash", "lua",
        },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
      })
    end,
  },

  -- F. MARKDOWN INLINE RENDERING
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    opts = {
      heading = {
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
      bullet = {
        icons = { "•", "○", "◆", "◇" },
      },
      checkbox = {
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰄵 " },
      },
    },
  },

  -- G. LSP & AUTOCOMPLETION (Rust, Python, Markdown)
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = { "pyright", "rust_analyzer", "marksman" },
      automatic_installation = true,
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Global LSP keybindings on attach
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(ev)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = ev.buf, desc = "LSP: " .. desc })
          end

          map("gd", vim.lsp.buf.definition, "Go to Definition")
          map("gr", vim.lsp.buf.references, "Find References")
          map("K", vim.lsp.buf.hover, "Hover Documentation")
          map("<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
          map("]d", vim.diagnostic.goto_next, "Next Diagnostic")
          map("<leader>e", vim.diagnostic.open_float, "Show Diagnostic Error")
        end,
      })

      -- Configure language server capabilities & options (Neovim 0.11+ / 0.12 API)
      if vim.lsp.config then
        vim.lsp.config("*", {
          capabilities = capabilities,
        })
        vim.lsp.config("rust_analyzer", {
          settings = {
            ["rust-analyzer"] = {
              checkOnSave = { command = "clippy" },
            },
          },
        })
        vim.lsp.enable({ "pyright", "rust_analyzer", "marksman" })
      else
        local lspconfig = require("lspconfig")
        lspconfig.pyright.setup({ capabilities = capabilities })
        lspconfig.rust_analyzer.setup({
          capabilities = capabilities,
          settings = {
            ["rust-analyzer"] = { checkOnSave = { command = "clippy" } },
          },
        })
        lspconfig.marksman.setup({ capabilities = capabilities })
      end
    end,
  },

  -- Minimal Autocompletion engine
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "path" },
          { name = "buffer" },
        }),
      })
    end,
  },
}, {
  ui = {
    border = "rounded",
    backdrop = 100,
  },
})
