local pickers = require("config.pickers")

return {
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = { "nvim-mini/mini.pick", "nvim-mini/mini.extra" },
    opts = {
      integrations = { mini_pick = true, snacks = false },
      graph_style = "kitty",
      disable_hint = true,
      process_spinner = true,
      commit_editor = { staged_diff_split_kind = "auto" },
    },
    keys = {
      { "<leader>G", "<cmd>Neogit<cr>", desc = "Neogit" },
      {
        "<leader>gb",
        function()
          require("neogit").open({ "branch" })
        end,
        desc = "Git Branches (Neogit)",
      },
      { "<leader>gf", pickers.git_file, desc = "Git Log File" },
      {
        "<leader>gl",
        function()
          require("mini.extra").pickers.git_commits()
        end,
        desc = "Git Log",
      },
      { "<leader>gL", pickers.git_line, desc = "Git Log Line" },
      {
        "<leader>gs",
        function()
          require("neogit").open()
        end,
        desc = "Git Status (Neogit)",
      },
      {
        "<leader>gS",
        function()
          require("neogit").open({ "stash" })
        end,
        desc = "Git Stash (Neogit)",
      },
    },
  },
  {
    "esmuellert/codediff.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    cmd = "CodeDiff",
  },
}
