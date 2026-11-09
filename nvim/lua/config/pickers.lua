local M = {}

function M.grep_word()
  local pattern = vim.fn.expand("<cword>")
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    local region = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), {
      type = mode,
      exclusive = vim.o.selection == "exclusive",
    })
    pattern = table.concat(region, "\n")
    vim.cmd.normal({ "\27", bang = true })
  end
  if pattern ~= "" then
    require("mini.pick").builtin.grep({ pattern = pattern, method = "plain" })
  end
end

function M.todos()
  require("mini.pick").builtin.grep({ pattern = [[\b(TODO|FIXME|FIX|BUG|HACK|WARN|NOTE|PERF|TEST):]] })
end

function M.plugins()
  require("mini.pick").builtin.grep({ pattern = [=[["'][A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+["']]=] }, {
    source = { cwd = vim.fn.stdpath("config") .. "/lua/plugins", name = "Plugin Specs" },
  })
end

function M.icons()
  local icons, items = require("mini.icons"), {}
  for _, category in ipairs({ "default", "directory", "extension", "file", "filetype", "lsp", "os" }) do
    for _, name in ipairs(icons.list(category)) do
      local glyph = icons.get(category, name)
      items[#items + 1] = { text = glyph .. "  " .. category .. "  " .. name, glyph = glyph }
    end
  end
  require("mini.pick").start({
    source = {
      name = "Icons",
      items = items,
      choose = function(item)
        vim.fn.setreg('"', item.glyph)
      end,
    },
  })
end

local function current_file()
  local path = vim.api.nvim_buf_get_name(0)
  if vim.bo.buftype ~= "" or path == "" then
    vim.notify("Current buffer is not a file", vim.log.levels.WARN)
    return
  end
  return path
end

function M.git_file()
  local path = current_file()
  if path then
    require("mini.extra").pickers.git_commits({ path = path })
  end
end

function M.git_line()
  local path = current_file()
  if not path then
    return
  end
  local root = vim.fs.root(path, ".git")
  if not root then
    vim.notify("Current file is not in a Git repository", vim.log.levels.WARN)
    return
  end
  local relative = path:sub(#root + 2)
  local line = vim.api.nvim_win_get_cursor(0)[1]
  require("mini.pick").builtin.cli({
    command = {
      "git",
      "--no-pager",
      "log",
      "--format=%h %s",
      "--no-patch",
      "-L",
      line .. "," .. line .. ":" .. relative,
    },
  }, {
    source = {
      cwd = root,
      name = "Git Log Line",
      choose = function(item)
        local hash = item:match("^%x+")
        if not hash then
          return
        end
        local result = vim
          .system({ "git", "--no-pager", "show", hash, "--", relative }, { cwd = root, text = true })
          :wait()
        if result.code ~= 0 then
          vim.notify(result.stderr, vim.log.levels.ERROR)
          return
        end
        vim.cmd("new")
        vim.bo.buftype, vim.bo.bufhidden, vim.bo.swapfile = "nofile", "wipe", false
        vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(result.stdout, "\n", { plain = true }))
        vim.bo.filetype = "diff"
        vim.bo.modifiable = false
      end,
    },
  })
end

function M.undo()
  local buf, tree = vim.api.nvim_get_current_buf(), vim.fn.undotree()
  local items = { { seq = 0, text = "0  Initial state" } }
  local function collect(entries)
    for _, entry in ipairs(entries) do
      items[#items + 1] = {
        seq = entry.seq,
        text = string.format(
          "%d  %s%s",
          entry.seq,
          os.date("%Y-%m-%d %H:%M:%S", entry.time),
          entry.seq == tree.seq_cur and "  (current)" or ""
        ),
      }
      if entry.alt then
        collect(entry.alt)
      end
    end
  end
  collect(tree.entries)
  table.sort(items, function(a, b)
    return a.seq > b.seq
  end)
  require("mini.pick").start({
    source = {
      name = "Undo History",
      items = items,
      choose = function(item)
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_call(buf, function()
            vim.cmd.undo(item.seq)
          end)
        end
      end,
    },
  })
end

return M
