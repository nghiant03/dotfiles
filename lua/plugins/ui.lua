require("mini.icons").setup({ extension = { lock = { glyph = "", hl = "MiniIconsGrey" } } })
require("mini.tabline").setup({})
require("mini.notify").setup({})

vim.keymap.set("n", "<leader>n", function()
  require("mini.notify").show_history()
end, { desc = "Notification History" })

require("lualine").setup({
  options = {
    theme = "tokyonight",
    icons_enabled = true,
    disabled_filetypes = { "minifiles" },
  },
  sections = {
    lualine_a = { { "filename", path = 1 } },
    lualine_x = { "encoding", "fileformat" },
    lualine_y = { "filetype" },
    lualine_z = { "progress", "location" },
  },
})

-- Register key hints on the next event-loop turn.
vim.schedule(function()
  local clue = require("mini.clue")
  local groups = {
    { "<Leader>f", "Find" },
    { "<Leader>g", "Git" },
    { "<Leader>s", "Search" },
    { "<Leader>d", "Debug" },
    { "<Leader>c", "Code" },
    { "<Leader>a", "AI" },
    { "<Leader>x", "Diagnostics / Lists" },
    { "<LocalLeader>j", "Jove" },
    { "<LocalLeader>l", "LaTeX" },
  }
  local clues = {
    clue.gen_clues.g(),
    clue.gen_clues.z(),
    clue.gen_clues.windows(),
    clue.gen_clues.registers(),
    clue.gen_clues.marks(),
    clue.gen_clues.square_brackets(),
  }
  for _, group in ipairs(groups) do
    clues[#clues + 1] = { mode = { "n", "x" }, keys = group[1], desc = "+" .. group[2] }
  end
  clue.setup({
    triggers = {
      { mode = { "n", "x" }, keys = "<Leader>" },
      { mode = { "n", "x" }, keys = "<LocalLeader>" },
      { mode = { "n", "x" }, keys = "g" },
      { mode = { "n", "x" }, keys = "z" },
      { mode = "n", keys = "<C-w>" },
      { mode = "n", keys = "[" },
      { mode = "n", keys = "]" },
      { mode = { "n", "x" }, keys = "'" },
      { mode = { "n", "x" }, keys = "`" },
      { mode = { "n", "x" }, keys = '"' },
      { mode = { "i", "c" }, keys = "<C-r>" },
    },
    clues = clues,
    window = { delay = 300 },
  })
end)
