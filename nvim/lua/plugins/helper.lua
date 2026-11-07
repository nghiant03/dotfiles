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
      local function can_tabout(line, col, pairs)
        local char = line:sub(col + 1, col + 1)
        local before = line:sub(1, col)
        if not before:find("%S") then
          return false
        end

        for _, pair in ipairs(pairs) do
          if char == pair.close then
            if pair.open ~= pair.close and before:match(vim.pesc(pair.open) .. "%s*$") then
              return false
            end
            if pair.open == pair.close then
              local count, last_quote, i = 0, 0, 1
              while i <= #before do
                local current = before:sub(i, i)
                if current == "\\" then
                  i = i + 2
                else
                  if current == char then
                    count = count + 1
                    last_quote = i
                  end
                  i = i + 1
                end
              end
              return count % 2 == 1 and before:sub(last_quote + 1):find("%S") ~= nil
            end
            return true
          end
        end
        return false
      end

      local neotab = require("neotab")
      neotab.setup(opts)
      local pairs = require("neotab.config").user.pairs
      vim.keymap.set("i", "<Tab>", function()
        local col = vim.api.nvim_win_get_cursor(0)[2]
        if can_tabout(vim.api.nvim_get_current_line(), col, pairs) then
          neotab.tabout()
        else
          local tab = vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
          vim.api.nvim_feedkeys(tab, "n", false)
        end
      end, { silent = true, desc = "Tab: Exit Closing Delimiter or Indent" })
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
