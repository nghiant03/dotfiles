return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "kawre/neotab.nvim",
      "zbirenbaum/copilot.lua",
      "fang2hou/blink-copilot",
    },
    opts = {
      keymap = {
        preset = "default",
        ["<Tab>"] = {
          "snippet_forward",
          function() return require("sidekick").nes_jump_or_apply() end,
          "fallback",
        },
      },
      completion = {
        accept = { auto_brackets = { enabled = true } },
        documentation = { auto_show = true },
        ghost_text = { enabled = true },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "copilot" },
        providers = {
          copilot = {
            name = "Copilot",
            module = "blink-copilot",
            async = true,
          },
        },
      },
      cmdline = {
        enabled = true,
        keymap = { preset = "cmdline" },
      },
    },
  }
}
