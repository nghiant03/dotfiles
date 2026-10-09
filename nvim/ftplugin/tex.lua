if vim.g.is_ssh then
  return
end
vim.opt.wrap = true
local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { buffer = true, silent = true, desc = desc })
end
map("n", "<localleader>li", "<cmd>VimtexInfo<cr>",            "Tex: Info")
map("n", "<localleader>lc", "<cmd>VimtexCompile<cr>",          "Tex: Compile")
map("n", "<localleader>ls", "<cmd>VimtexStop<cr>",             "Tex: Stop")
map("n", "<localleader>lC", "<cmd>VimtexClean<cr>",            "Tex: Clean All")
map("n", "<localleader>lv", "<cmd>VimtexView<cr>",             "Tex: View")
map("n", "<localleader>lS", "<cmd>VimtexCompileSelected<cr>",  "Tex: Compile Selected")
