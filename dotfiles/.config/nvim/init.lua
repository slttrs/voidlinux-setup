vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })


-- ~/.config/nvim/init.lua
-- Minimal IDE-like setup. Requires Neovim 0.11+.
-- System deps: git, a C compiler (gcc/clang), tree-sitter-cli, ripgrep, a Nerd Font,
--              node/npm (html/css servers), python3, dotnet SDK (for C# / omnisharp).

------------------------------------------------------------
-- Options
------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local o = vim.opt
o.number = true
o.relativenumber = true
o.mouse = "a"
o.clipboard = "unnamedplus"
o.undofile = true
o.ignorecase = true
o.smartcase = true
o.signcolumn = "yes"
o.updatetime = 250
o.splitright = true
o.splitbelow = true
o.cursorline = true
o.scrolloff = 8
o.termguicolors = true
o.showmode = false
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4
o.completeopt = "menu,menuone,noselect"

-- 2-space indent for web files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "html", "css", "javascript", "json", "lua" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.hl.on_yank() end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
  end,
})

------------------------------------------------------------
-- Plugin manager (lazy.nvim bootstrap)
------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

------------------------------------------------------------
-- Plugins
------------------------------------------------------------
require("lazy").setup({

  -- Colorscheme

  {
    "rashedInt32/tidepool.nvim",
    priority = 1000,
    config = function()
      require("tidepool").setup({
        palette = "muted",
        transparent = true,
        styles = { bold = true, italic = true, italic_identifiers = false },
        on_highlights = function(groups, palette)
          groups.Comment = { fg = palette.subtle, italic = true }
          -- groups.EndOfBuffer = vim.tbl_extend("force", groups.EndOfBuffer or {}, { bg = "NONE" })
        end,
      })
      vim.cmd.colorscheme("tidepool")
    end,
  },

  --[[
  {
    "linusng/green-shades.vim",
    priority = 1000,
    transparent = true,
    config = function()
      vim.cmd.colorscheme("green-shades")
      vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
    end,
  },
  ]]

  -- Icons (needs a Nerd Font in your terminal)
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- File manager (sidebar)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-web-devicons" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
      { "<leader>E", "<cmd>NvimTreeFindFile<cr>", desc = "Reveal current file in tree" },
    },
    opts = {
      view = { width = 30 },
      filters = { dotfiles = false },
      renderer = { group_empty = true },
    },
  },

  -- Tabs (buffer tabs along the top)
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        offsets = {
          { filetype = "NvimTree", text = "Files", text_align = "left", separator = true },
        },
      },
    },
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-web-devicons" },
    event = "VeryLazy",
    opts = { options = { globalstatus = true, section_separators = "", component_separators = "|" } },
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep in project" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
    },
  },

  -- Syntax highlighting (Treesitter, "main" branch API)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({
        "python", "c_sharp", "cpp", "c", "html", "css",
        "lua", "vim", "vimdoc", "markdown", "json", "bash",
      })
      vim.api.nvim_create_autocmd("FileType", {
        callback = function() pcall(vim.treesitter.start) end,
      })
    end,
  },

  -- LSP: server installer + configs
  { "mason-org/mason.nvim", opts = {} },
  { "neovim/nvim-lspconfig" },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig", "saghen/blink.cmp" },
    config = function()
      -- Give every server the completion capabilities from blink.cmp
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      -- clangd: nicer defaults for C/C++
      vim.lsp.config("clangd", {
        cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu" },
      })

      require("mason-lspconfig").setup({
        -- Installed automatically and enabled automatically
        ensure_installed = { "pyright", "clangd", "omnisharp", "html", "cssls", "lua_ls" },
      })
    end,
  },

  -- Completion + documentation popups + signature help
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    opts = {
      keymap = { preset = "super-tab" }, -- <C-space> open, <C-y> accept, <C-n>/<C-p> select
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
      },
      signature = { enabled = true },
      sources = { default = { "lsp", "path", "buffer" } },
    },
  },

  -- Git signs in the gutter
  { "lewis6991/gitsigns.nvim", event = "BufReadPre", opts = {} },

  -- Auto-close brackets/quotes
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

    -- Auto-close and auto-rename HTML tags
  { "windwp/nvim-ts-autotag", event = "InsertEnter", opts = {} },

  -- Shows available keybindings as you type
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },
})

------------------------------------------------------------
-- Keymaps
------------------------------------------------------------
local map = vim.keymap.set

-- Tabs (buffers)
map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next tab" })
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous tab" })
map("n", "<leader>x", function()
  local cur = vim.api.nvim_get_current_buf()
  if vim.bo[cur].modified then
    vim.notify("Unsaved changes: save first (<leader>w)", vim.log.levels.WARN)
    return
  end
  local listed = vim.tbl_filter(function(b)
    return vim.bo[b].buflisted
  end, vim.api.nvim_list_bufs())
  if #listed > 1 then
    vim.cmd("bprevious")
  end
  vim.cmd("bdelete " .. cur)
end, { desc = "Close current tab" })

map("n", "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", { desc = "Close other tabs" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Misc
map("n", "<Esc>", "<cmd>nohlsearch<cr>")
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save" })

-- Toggle the inline error text (keeps underlines, gutter signs and <leader>d)
local virtual_text_on = true
map("n", "<leader>tv", function()
  virtual_text_on = not virtual_text_on
  vim.diagnostic.config({ virtual_text = virtual_text_on })
end, { desc = "Toggle inline diagnostic text" })

-- Toggle ALL diagnostics (text, underlines, signs)
map("n", "<leader>td", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle all diagnostics" })

-- Undo / redo
map("n", "<C-z>", "u", { desc = "Undo" })
map("i", "<C-z>", "<C-o>u", { desc = "Undo" })
map("n", "<C-y>", "<C-r>", { desc = "Redo" })

------------------------------------------------------------
-- LSP keymaps (active only when a server is attached)
------------------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local function lmap(keys, fn, desc)
      map("n", keys, fn, { buffer = ev.buf, desc = "LSP: " .. desc })
    end
    -- Built-in 0.11 defaults you also get for free:
    --   K = hover docs, grr = references, gra = code action, grn = rename,
    --   gri = implementation, <C-s> (insert) = signature help
    lmap("gd", vim.lsp.buf.definition, "Go to definition")
    lmap("gD", vim.lsp.buf.declaration, "Go to declaration")
    lmap("<leader>ca", vim.lsp.buf.code_action, "Code action")
    lmap("<leader>rn", vim.lsp.buf.rename, "Rename")
    lmap("<leader>f", function() vim.lsp.buf.format({ async = true }) end, "Format file")
    lmap("<leader>d", vim.diagnostic.open_float, "Line diagnostics")
  end,
})

vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
  float = { border = "rounded" },
})

require("run")
