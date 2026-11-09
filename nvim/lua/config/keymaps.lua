local map = vim.keymap.set
-- Normal
map("n", "<C-S-Left>",  "<C-w>H", { desc = "Move Window to Left Edge" })
map("n", "<C-S-Down>",  "<C-w>J", { desc = "Move Window to Bottom Edge" })
map("n", "<C-S-Up>",    "<C-w>K", { desc = "Move Window to Top Edge" })
map("n", "<C-S-Right>", "<C-w>L", { desc = "Move Window to Right Edge" })
map("n", "<C-h>",        "<C-w>h",                		  { desc = "Focus Left Window" })
map("n", "<C-j>",        "<C-w>j",                		  { desc = "Focus Lower Window" })
map("n", "<C-k>",        "<C-w>k",                		  { desc = "Focus Upper Window" })
map("n", "<C-l>",        "<C-w>l",                		  { desc = "Focus Right Window" })
map("n", "<C-Up>",       "<cmd>resize -2<cr>",    		  { desc = "Decrease Window Height" })
map("n", "<C-Down>",     "<cmd>resize +2<cr>",    		  { desc = "Increase Window Height" })
map("n", "<C-Left>",     "<cmd>vertical resize -2<cr>", { desc = "Narrow Window" })
map("n", "<C-Right>",    "<cmd>vertical resize +2<cr>", { desc = "Widen Window" })
map("n", "<S-l>",        "<cmd>bnext<cr>",        	    { desc = "Next Buffer" })
map("n", "<S-h>",        "<cmd>bprevious<cr>",    		  { desc = "Previous Buffer" })
map("n", "<LeftMouse>",  "m'<LeftMouse>",         		  { desc = "Click (Add to Jumplist)" })
-- Terminal
map("n", "<leader>t", function()
  require("config.terminal").toggle()
end, { desc = "Toggle Terminal" })
map("t",								 "<C-q>", "<C-\\><C-n>",				{ desc = "Terminal: Enter Normal Mode" })
-- Visual
map("v", "<",            "<gv",                   	    { desc = "Indent Left and Reselect" })
map("v", ">",            ">gv",                   		  { desc = "Indent Right and Reselect" })
map("v", "p",            '"_dP',                  		  { desc = "Paste Without Yanking" })
-- Visual block
map("x", "J",            ":move '>+1<CR>gv-gv",   		  { desc = "Move Selection Down" })
map("x", "K",            ":move '<-2<CR>gv-gv",   		  { desc = "Move Selection Up" })
