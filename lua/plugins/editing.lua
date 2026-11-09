return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        check_ts = true,
        ts_config = {
          python = { "import_from_statement" },
        },
        disable_filetype = { "minipick" },
      })
    end,
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
  "kevinhwang91/nvim-hlslens",
  "vladdoster/remember.nvim",
  {
    "nvim-mini/mini.hipatterns",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      highlighters = {
        fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
        fix = { pattern = "%f[%w]()FIX()%f[%W]", group = "MiniHipatternsFixme" },
        bug = { pattern = "%f[%w]()BUG()%f[%W]", group = "MiniHipatternsFixme" },
        hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
        warn = { pattern = "%f[%w]()WARN()%f[%W]", group = "MiniHipatternsHack" },
        todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
        note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
        perf = { pattern = "%f[%w]()PERF()%f[%W]", group = "MiniHipatternsNote" },
        test = { pattern = "%f[%w]()TEST()%f[%W]", group = "MiniHipatternsNote" },
      },
    },
  },
}
