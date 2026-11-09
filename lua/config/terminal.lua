local M = {}
local buf

local function hide()
  local win = buf and vim.fn.bufwinid(buf) or -1
  if win ~= -1 then
    if #vim.api.nvim_tabpage_list_wins(0) == 1 then
      vim.cmd("new")
    end
    vim.api.nvim_win_close(win, true)
  end
end

function M.toggle()
  if buf and vim.api.nvim_buf_is_valid(buf) and vim.fn.bufwinid(buf) ~= -1 then
    hide()
    return
  end

  vim.cmd("botright 15split")
  if buf and vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_win_set_buf(0, buf)
  else
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(0, buf)
    vim.bo[buf].bufhidden = "hide"
    vim.fn.jobstart(vim.o.shell, { term = true })
    vim.keymap.set({ "n", "t" }, "<Esc><Esc>", hide, { buffer = buf, desc = "Hide Terminal" })
    vim.api.nvim_create_autocmd("TermClose", {
      buffer = buf,
      once = true,
      callback = function(ev)
        if buf == ev.buf then
          buf = nil
        end
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(ev.buf) then
            vim.api.nvim_buf_delete(ev.buf, { force = true })
          end
        end)
      end,
    })
  end
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.cmd("startinsert")
end

return M
