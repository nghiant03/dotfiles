local pickers = require("config.pickers")

local function extra(name, opts)
  return function()
    require("mini.extra").pickers[name](opts)
  end
end

local function builtin(name, local_opts, opts)
  return function()
    require("mini.pick").builtin[name](local_opts, opts)
  end
end

require("mini.pick").setup({})
require("mini.extra").setup({})
require("mini.files").setup({ options = { use_as_default_explorer = true } })

require("config.maps")({
  { "<leader><space>", builtin("files"), desc = "Find Files" },
  { "<leader>,", builtin("buffers"), desc = "Buffers" },
  { "<leader>/", builtin("grep_live"), desc = "Grep" },
  { "<leader>fb", builtin("buffers"), desc = "Buffers" },
  {
    "<leader>fc",
    builtin("files", nil, { source = { cwd = vim.fn.stdpath("config") } }),
    desc = "Find Config File",
  },
  { "<leader>ff", builtin("files"), desc = "Find Files" },
  { "<leader>fg", extra("git_files"), desc = "Find Git Files" },
  { "<leader>fr", extra("oldfiles"), desc = "Recent Files" },
  { "<leader>sg", builtin("grep_live"), desc = "Grep" },
  { "<leader>sw", pickers.grep_word, desc = "Grep Word / Selection", mode = { "n", "x" } },
  { '<leader>s"', extra("registers"), desc = "Registers" },
  { "<leader>s/", extra("history", { scope = "/" }), desc = "Search History" },
  { "<leader>sb", extra("buf_lines", { scope = "current" }), desc = "Buffer Lines" },
  { "<leader>sB", extra("buf_lines", { scope = "all" }), desc = "Search Open Buffers" },
  { "<leader>sc", extra("history", { scope = ":" }), desc = "Command History" },
  { "<leader>sC", extra("commands"), desc = "Commands" },
  { "<leader>sh", builtin("help"), desc = "Help Pages" },
  { "<leader>sH", extra("hl_groups"), desc = "Highlights" },
  { "<leader>si", pickers.icons, desc = "Icons" },
  { "<leader>sj", extra("list", { scope = "jump" }), desc = "Jumps" },
  { "<leader>sk", extra("keymaps"), desc = "Keymaps" },
  { "<leader>sm", extra("marks"), desc = "Marks" },
  { "<leader>sM", extra("manpages"), desc = "Man Pages" },
  { "<leader>sp", pickers.plugins, desc = "Search Plugin Specs" },
  { "<leader>sR", builtin("resume"), desc = "Resume Picker" },
  { "<leader>su", pickers.undo, desc = "Undo History" },
  { "<leader>st", pickers.todos, desc = "Search TODO Comments" },
  { "gd", extra("lsp", { scope = "definition" }), desc = "Goto Definition" },
  { "gD", extra("lsp", { scope = "declaration" }), desc = "Goto Declaration" },
  { "<leader>sS", extra("lsp", { scope = "workspace_symbol" }), desc = "LSP Workspace Symbols" },
  {
    "<leader>e",
    function()
      local files = require("mini.files")
      if files.close() then
        return
      end
      local path = vim.api.nvim_buf_get_name(0)
      files.open(vim.fn.filereadable(path) == 1 and path or vim.fn.getcwd())
    end,
    desc = "File Explorer",
  },
  { "<leader>cs", "<cmd>AerialToggle<cr>", desc = "Aerial: Toggle Symbols Panel" },
})

require("aerial").setup({
  attach_mode = "global",
  backends = { "lsp", "treesitter", "markdown", "man" },
  show_guides = true,
  layout = {
    resize_to_content = false,
    win_opts = {
      winhl = "Normal:NormalFloat,FloatBorder:NormalFloat,SignColumn:SignColumnSB",
      signcolumn = "yes",
      statuscolumn = " ",
    },
  },
  guides = { mid_item = "├╴", last_item = "└╴", nested_top = "│ ", whitespace = "  " },
})
