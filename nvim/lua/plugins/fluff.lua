if vim.g.is_ssh then
    return {}
end

return {
  {
    'vyfor/cord.nvim',
    build = ':Cord update',
    -- opts = {}
  },
}
