-- Basic Settings (from Helix config)
vim.o.number = true
vim.o.relativenumber = true
vim.o.scrolloff = 4
vim.o.cursorline = true
vim.o.cursorcolumn = true
vim.o.termguicolors = true
vim.o.updatetime = 200 -- Idle timeout
vim.o.signcolumn = "yes"
vim.o.mouse = "a"
vim.o.colorcolumn = "80,100" -- Helix rulers

-- Trim trailing whitespace on save
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  command = [[%s/\s\+$//e]],
})

-- Theme: gruvbox-material (Helix uses gruvbox_dark_soft)
vim.g.gruvbox_material_background = "soft"
vim.g.gruvbox_material_foreground = "material"
vim.g.gruvbox_material_ui_contrast = "high" -- Matches Helix popup-border = "all" style
vim.cmd("colorscheme gruvbox-material")

-- Keymaps (Leader key)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- --- Plugins Configuration ---

-- 1. Status Line (Lualine) - Matching Helix statusline
require('lualine').setup {
  options = {
    theme = 'gruvbox-material',
    component_separators = '|',
    section_separators = '',
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'diagnostics'}, -- Helix: spinner, diagnostics
    lualine_c = {'filename'},    -- Helix: file-name
    lualine_x = {'encoding', 'filetype'}, -- Helix: file-encoding, file-type
    lualine_y = {'progress'},    -- Helix: position (approx)
    lualine_z = {'location'}     -- Helix: position
  },
}

-- 2. Buffer Line (Bufferline) - Matching Helix bufferline = "always"
require("bufferline").setup{
  options = {
    mode = "buffers",
    always_show_bufferline = true,
    show_buffer_close_icons = false,
    show_close_icon = false,
  }
}

-- 3. Indent Guides (Indent Blankline) - Matching Helix indent-guides
require("ibl").setup {
    indent = { char = "|" },
    scope = { enabled = true },
}

-- 4. Git Signs - Matching Helix gutters (implied)
require('gitsigns').setup()

-- 5. Telescope (File Picker)
local builtin = require('telescope.builtin')
local themes = require('telescope.themes')

require('telescope').setup{
  defaults = {
    -- Matching Helix: file-picker.hidden = false
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '--hidden' -- Search hidden files
    },
  },
  pickers = {
    find_files = {
      hidden = true -- Search hidden files
    }
  },
  extensions = {
    ['ui-select'] = {
      require('telescope.themes').get_dropdown {
        -- even more opts
      }
    }
  }
}

-- Load telescope extensions
require("telescope").load_extension("ui-select")

-- 6. Oil.nvim (File System Editor - like directory buffers)
require("oil").setup({
  default_file_explorer = true,
  view_options = {
    show_hidden = true,
  },
})

-- 7. Harpoon (Workplace Navigation)
-- local harpoon = require("harpoon")
-- harpoon:setup()

-- 8. Flash.nvim (Motions)
-- require("flash").setup()

-- 9. Which-Key (Menu System) - Replicating Helix <space> menu
local wk = require("which-key")

-- Helper for terminal tools (lazygit, gitui)
-- We use a simple floating terminal implementation for now
local function open_float_term(cmd)
  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.9)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded"
  })
  vim.fn.termopen(cmd, {
    on_exit = function()
      vim.api.nvim_win_close(win, true)
    end
  })
  vim.cmd("startinsert")
end

wk.add({
  { "<leader><space>", ":Format<CR>:w<CR>", desc = "Format and Save" },
  { "<leader>c", group = "code" },
  { "<leader>cc", "gc", desc = "Toggle Comment", remap = true },
  { "<leader>g", group = "git" },
  { "<leader>gb", function() builtin.git_bcommits() end, desc = "Git Blame (History)" },
  { "<leader>gg", function() builtin.git_status() end, desc = "Changed Files" },

  -- Harpoon (Workplace)
  -- { "<leader>h", group = "harpoon" },
  -- { "<leader>ha", function() harpoon:list():add() end, desc = "Add File" },
  -- { "<leader>hl", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, desc = "List Files" },
  -- { "<leader>h1", function() harpoon:list():select(1) end, desc = "Select 1" },
  -- { "<leader>h2", function() harpoon:list():select(2) end, desc = "Select 2" },
  -- { "<leader>h3", function() harpoon:list():select(3) end, desc = "Select 3" },
  -- { "<leader>h4", function() harpoon:list():select(4) end, desc = "Select 4" },

  -- File Navigation
  { "<leader>o", function() builtin.find_files({ cwd = vim.fn.expand('%:p:h') }) end, desc = "Open in Buffer Dir" },
  { "<leader>O", function() require("oil").open() end, desc = "File Manager (Oil)" },

  -- Flash (Motions)
  -- { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
  -- { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },

  { "<leader>p", group = "project tools" },
  { "<leader>pd", function() open_float_term("lazydocker") end, desc = "LazyDocker" },
  { "<leader>pg", function() open_float_term("lazygit") end, desc = "LazyGit" },
  { "<leader>pt", function() open_float_term("gitui") end, desc = "GitUI" },
  { "<leader>py", function() open_float_term("yazi") end, desc = "Yazi" },
  { "<leader>q", ":bd<CR>", desc = "Close Buffer" },
  { "<leader>Q", ":w<CR>:bd<CR>", desc = "Write & Close Buffer" },
  -- Window management (Helix: windowMacros)
  { "<leader>w", group = "window" },
  -- Basic window controls often mapped to space-w in nvim distros,
  -- but adhering to Helix-like single key toggles is harder in pure lua without conflicts.
  -- We'll stick to space-prefixed for safety or standard vim keys (C-w).

  -- Global bindings
  { "<C-p>", builtin.find_files, desc = "File Picker" },
  { "<C-P>", builtin.commands, desc = "Command Palette" },

  -- Buffer navigation (Helix: previousBuffer/nextBuffer via H/L)
  -- Note: H/L in Vim are "High/Low" on screen. Mapping them changes standard behavior significantly.
  -- But since you requested parity:
}, { mode = "n" })

-- Helix-like Buffer Navigation
vim.keymap.set('n', 'H', ':bprevious<CR>', { desc = 'Previous Buffer' })
vim.keymap.set('n', 'L', ':bnext<CR>', { desc = 'Next Buffer' })

-- Helix-like Selection/Editing
-- Note: 'x' in Vim is delete char. Helix uses it for select line.
-- This is a MAJOR conflict. I will map it but warn it changes Vim fundamental.
vim.keymap.set('n', 'x', 'V', { desc = 'Select Line (Visual Line)' })
vim.keymap.set('n', 'X', 'V', { desc = 'Select Line Above (Simulated)' }) -- Hard to exact match "extend above"

-- --- LSP & Completion ---

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Helper to set up servers with common settings
local function setup_server(server, config)
  config = config or {}
  config.capabilities = capabilities
  vim.lsp.config(server, config)
  vim.lsp.enable(server)
end

-- Python (basedpyright + ruff)
setup_server('basedpyright', {
  settings = {
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
      }
    }
  }
})
setup_server('ruff', {})

-- Haskell
setup_server('haskell_language_server', {
  -- HLS often needs specific project settings, defaults usually work
})

-- Docker
setup_server('dockerls', {})

-- Markdown (Marksman)
setup_server('marksman', {})

-- Harper (Grammar)
setup_server('harper_ls', {
  settings = {
    ["harper-ls"] = {
      userDictPath = vim.fn.expand("~/.config/harper.dictionary"),
      linters = {
        SentenceCapitalization = false,
        BoringWords = true
      }
    }
  }
})

-- Completion (nvim-cmp)
local cmp = require'cmp'

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item.
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  }, {
    { name = 'buffer' },
  })
})

-- Formatting (Conform)
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_format" },
    -- Add others as needed
  },
  format_on_save = {
    -- These options derived from your Helix auto-save/format config
    timeout_ms = 500,
    lsp_fallback = true,
  },
})

vim.api.nvim_create_user_command("Format", function(args)
  require("conform").format({ async = true, lsp_fallback = true })
end, {})
