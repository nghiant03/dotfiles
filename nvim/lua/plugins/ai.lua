return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		opts = {
			suggestion = { enabled = false },
			panel = { enabled = false },
		},
	},
	{
		"folke/sidekick.nvim",
		opts = {},
		keys = {
			{
				"<Tab>",
				function()
					if not require("sidekick").nes_jump_or_apply() then
						return "<Tab>"
					end
				end,
				expr = true,
				desc = "Sidekick: Goto/Apply Next Edit Suggestion",
			},
			{
				"<C-.>",
				function()
					require("sidekick.cli").focus()
				end,
				desc = "Focus AI CLI",
				mode = { "n", "t", "i", "x" },
			},
			{
				"<leader>aa",
				function()
					require("sidekick.cli").toggle()
				end,
				desc = "Sidekick: Toggle AI CLI",
			},
			{
				"<leader>as",
				function()
					require("sidekick.cli").select({ filter = { installed = true } })
				end,
				desc = "Sidekick: Select AI CLI",
			},
			{
				"<leader>ad",
				function()
					require("sidekick.cli").close()
				end,
				desc = "Sidekick: Detach AI CLI",
			},
			{
				"<leader>at",
				function()
					require("sidekick.cli").send({ msg = "{this}" })
				end,
				desc = "Sidekick: Send This to AI CLI",
				mode = { "n", "x" },
			},
			{
				"<leader>af",
				function()
					require("sidekick.cli").send({ msg = "{file}" })
				end,
				desc = "Sidekick: Send File to AI CLI",
			},
			{
				"<leader>av",
				function()
					require("sidekick.cli").send({ msg = "{selection}" })
				end,
				desc = "Sidekick: Send Selection to AI CLI",
				mode = "x",
			},
			{
				"<leader>ap",
				function()
					local cli = require("sidekick.cli")
					cli.prompt({
						cb = function(_, text)
							if text then
								cli.send({ text = text })
							end
						end,
					})
				end,
				desc = "Sidekick: Select Prompt",
				mode = { "n", "x" },
			},
		},
	},
}
