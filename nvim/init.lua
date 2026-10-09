vim.g.is_ssh = os.getenv("SSH_TTY") ~= nil
if vim.g.is_ssh then
	vim.env.PATH = vim.env.HOME .. "/.local/bin:" .. vim.env.PATH
end
require("config.options")
require("config.keymaps")
require("config.cmds")
require("config.lazy")
