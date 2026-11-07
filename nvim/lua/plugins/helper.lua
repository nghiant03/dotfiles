return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>s", group = "search" },
        { "<leader>d", group = "debug" },
        { "<leader>c", group = "code" },
        { "<leader>a", group = "ai" },
        { "<localleader>j", group = "jove" },
        { "<localleader>l", group = "latex" },
      },
    },
  },
  {
		"stevearc/aerial.nvim",
		opts = function()
			local opts = {
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
				-- stylua: ignore
				guides = {
					mid_item   = "├╴",
					last_item  = "└╴",
					nested_top = "│ ",
					whitespace = "  ",
				},
			}
			return opts
		end,
		keys = {
			{ "<leader>cs", "<cmd>AerialToggle<cr>", desc = "Aerial: Toggle Symbols Panel" },
		},
	},
	{
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup{
        check_ts = true,
        ts_config = {
          python = {"import_from_statement"}
        },
        disable_filetype = {"codecompanion", "snacks_picker_input"}
      }
    end
  },
  {
    "kawre/neotab.nvim",
    event = "InsertEnter",
    opts = {
      tabkey = "",
    },
    config = function(_, opts)
      require("config.neotab").setup(opts)
    end,
  },
  {
		"NeogitOrg/neogit",
		cmd = "Neogit",
		dependencies = {
			"folke/snacks.nvim",             -- optional
		},
		opts = {
			graph_style = "kitty",
			disable_hint = true,
			process_spinner = true,
			commit_editor = {
				staged_diff_split_kind = "auto"
			}
		},
		keys = {
			{ "<leader>G", "<cmd>Neogit<cr>", desc = "Neogit" },
		},
  },
	{
		"esmuellert/codediff.nvim",
		dependencies = { "MunifTanjim/nui.nvim" },
		cmd = "CodeDiff",
	},
	{
		"linux-cultist/venv-selector.nvim",
		ft = "python", -- Load when opening Python files
		keys = { { "<localleader>v", "<cmd>VenvSelect<cr>", ft = "python", desc = "Python: Select Venv" } }, -- Open picker on keymap
		opts = {
			options = {}, -- plugin-wide options
			search = {}   -- custom search definitions
		},
	},
	"kevinhwang91/nvim-bqf",
  "kevinhwang91/nvim-hlslens",
  "vladdoster/remember.nvim",
  "folke/todo-comments.nvim",
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      local ensure = {
        "python", "markdown", "markdown_inline", "yaml", "toml",
        "bash", "lua", "json", "rust", "html", "css", "javascript",
        "typescript", "vim", "vimdoc", "query", "c", "cpp",
      }
      local nts = require("nvim-treesitter")
      local installed = nts.get_installed("parsers")
      local missing = {}
      for _, lang in ipairs(ensure) do
        if not vim.tbl_contains(installed, lang) then
          table.insert(missing, lang)
        end
      end
      if #missing > 0 then
        nts.install(missing)
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = ensure,
        callback = function(ev)
          pcall(vim.treesitter.start, ev.buf)
        end,
      })
    end,
  },
}
