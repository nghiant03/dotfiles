vim.opt.termguicolors = true

return {
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        theme = 'tokyonight',
        icons_enabled = true,
        disabled_filetypes = {"NvimTree", "snacks_dashboard"},
      },
      sections = {
        lualine_a = {{ 'filename', path = 1 }},
        lualine_x = {"encoding", "fileformat"},
        lualine_y = {"filetype"},
        lualine_z = {"progress", "location"},
      }
    }
  },
  {
    "folke/snacks.nvim",
    version = '*',
		lazy = false,
		priority = 1000,
    keys = {
      { "<leader>t", function() require("snacks").terminal.toggle() end, desc = "Toggle Terminal" },
      -- Top pickers & explorer
      { "<leader><space>", function() require("snacks").picker.smart() end, desc = "Smart Find Files" },
      { "<leader>,",       function() require("snacks").picker.buffers() end, desc = "Buffers" },
      { "<leader>/",       function() require("snacks").picker.grep() end, desc = "Grep" },
      { "<leader>n",       function() require("snacks").picker.notifications() end, desc = "Notification History" },
      { "<leader>e",       function() require("snacks").explorer() end, desc = "File Explorer" },
      -- find
      { "<leader>fb", function() require("snacks").picker.buffers() end, desc = "Buffers" },
      { "<leader>fc", function() require("snacks").picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
      { "<leader>ff", function() require("snacks").picker.files() end, desc = "Find Files" },
      { "<leader>fg", function() require("snacks").picker.git_files() end, desc = "Find Git Files" },
      { "<leader>fp", function() require("snacks").picker.projects() end, desc = "Projects" },
      { "<leader>fr", function() require("snacks").picker.recent() end, desc = "Recent" },
      -- git
      { "<leader>gb", function() require("snacks").picker.git_branches() end, desc = "Git Branches" },
      { "<leader>gf", function() require("snacks").picker.git_log_file() end, desc = "Git Log File" },
      { "<leader>gl", function() require("snacks").picker.git_log() end, desc = "Git Log" },
      { "<leader>gL", function() require("snacks").picker.git_log_line() end, desc = "Git Log Line" },
      { "<leader>gs", function() require("snacks").picker.git_status() end, desc = "Git Status" },
      { "<leader>gS", function() require("snacks").picker.git_stash() end, desc = "Git Stash" },
      -- search
      { "<leader>sg", function() require("snacks").picker.grep() end, desc = "Grep" },
      { "<leader>sw", function() require("snacks").picker.grep_word() end, desc = "Grep Word", mode = { "n", "x" } },
      { "<leader>s\"",  function() require("snacks").picker.registers() end, desc = "Registers" },
      { "<leader>s/",   function() require("snacks").picker.search_history() end, desc = "Search History" },
      { "<leader>sa", function() require("snacks").picker.autocmds() end, desc = "Autocmds" },
      { "<leader>sb", function() require("snacks").picker.lines() end, desc = "Buffer Lines" },
      { "<leader>sB", function() require("snacks").picker.grep_buffers() end, desc = "Grep Open Buffers" },
      { "<leader>sc", function() require("snacks").picker.command_history() end, desc = "Command History" },
      { "<leader>sC", function() require("snacks").picker.commands() end, desc = "Commands" },
      { "<leader>sh", function() require("snacks").picker.help() end, desc = "Help Pages" },
      { "<leader>sH", function() require("snacks").picker.highlights() end, desc = "Highlights" },
      { "<leader>si", function() require("snacks").picker.icons() end, desc = "Icons" },
      { "<leader>sj", function() require("snacks").picker.jumps() end, desc = "Jumps" },
      { "<leader>sk", function() require("snacks").picker.keymaps() end, desc = "Keymaps" },
      { "<leader>sm", function() require("snacks").picker.marks() end, desc = "Marks" },
      { "<leader>sM", function() require("snacks").picker.man() end, desc = "Man Pages" },
      { "<leader>sp", function() require("snacks").picker.lazy() end, desc = "Search for Plugin Spec" },
      { "<leader>sR", function() require("snacks").picker.resume() end, desc = "Resume" },
      { "<leader>su", function() require("snacks").picker.undo() end, desc = "Undo History" },
      -- LSP pickers
      { "gd", function() require("snacks").picker.lsp_definitions() end, desc = "Goto Definition" },
      { "gD", function() require("snacks").picker.lsp_declarations() end, desc = "Goto Declaration" },
      { "<leader>sS", function() require("snacks").picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
    },
    opts = {
      bigfile = {},
      explorer = { replace_netrw = true },
      picker = { sources = { explorer = {} } },
      notifier = {},
      terminal = {
        win = {
          position = "bottom",
          keys = {
            term_normal = false,
            term_hide = { "<esc><esc>", "hide", mode = { "n", "t" }, desc = "Hide Terminal" },
          },
        },
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    opts = { max_lines = 5, multiline_threshold = 2 },
  },
}
