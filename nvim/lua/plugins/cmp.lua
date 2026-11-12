require("blink.cmp").setup({
  keymap = {
    preset = "default",
    ["<Tab>"] = {
      "snippet_forward",
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
})
