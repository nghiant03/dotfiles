return {
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = { "nvim-mini/mini.pick" },
    ft = "python",
    keys = {
      { "<localleader>v", "<cmd>VenvSelect<cr>", ft = "python", desc = "Python: Select Venv" },
    },
    opts = { options = { picker = "mini-pick" }, search = {} },
  },
}
