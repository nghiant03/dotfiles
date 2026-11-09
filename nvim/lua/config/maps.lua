-- A compact notation for native keymaps, with no package-loading behavior.
---@param mappings table[]
return function(mappings)
  for _, mapping in ipairs(mappings) do
    local opts = vim.deepcopy(mapping)
    local lhs, rhs, mode = opts[1], opts[2], opts.mode or "n"
    opts[1], opts[2], opts.mode = nil, nil, nil
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end
