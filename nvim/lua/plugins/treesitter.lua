return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      local ensure = {
        "python",
        "markdown",
        "markdown_inline",
        "yaml",
        "toml",
        "bash",
        "lua",
        "json",
        "rust",
        "html",
        "css",
        "javascript",
        "typescript",
        "vim",
        "vimdoc",
        "query",
        "c",
        "cpp",
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
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = { max_lines = 5, multiline_threshold = 2 },
  },
}
