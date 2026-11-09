local M = {}

local builds = {
  ["nvim-treesitter"] = function()
    require("nvim-treesitter").update()
  end,
  ["cord.nvim"] = function()
    require("cord.api.command").update()
  end,
}

function M.build(name)
  assert(builds[name], "No build hook for " .. name)
  local package = vim.pack.get({ name }, { info = false })[1]
  if not package.active then
    vim.cmd.packadd(name)
  end
  builds[name]()
end

vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("config_pack_build", { clear = true }),
  callback = function(ev)
    if ev.data.kind == "delete" or not builds[ev.data.spec.name] then
      return
    end
    vim.schedule(function()
      M.build(ev.data.spec.name)
    end)
  end,
})

vim.api.nvim_create_user_command("PackBuild", function(opts)
  if opts.args ~= "" then
    M.build(opts.args)
    return
  end
  for name in pairs(builds) do
    M.build(name)
  end
end, {
  nargs = "?",
  complete = function()
    return vim.tbl_keys(builds)
  end,
  desc = "Rebuild native packages with install/update hooks",
})

return M
