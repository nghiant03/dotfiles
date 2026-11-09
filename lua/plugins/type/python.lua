local venv = require("venv-selector")
-- Its public setup accepts partial options; upstream types describe full defaults.
---@cast venv { setup: fun(opts: table) }
venv.setup({ options = { picker = "mini-pick" }, search = {} })

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("config_python_keys", { clear = true }),
  pattern = "python",
  callback = function(ev)
    vim.keymap.set("n", "<localleader>v", "<cmd>VenvSelect<cr>", { buffer = ev.buf, desc = "Python: Select Venv" })
  end,
})
