local spec = {
  'rachartier/tiny-inline-diagnostic.nvim',
  event = 'VeryLazy',
  priority = 900, -- needs to be loaded earlier
  opts = {},
}

spec.opts.options = {
  multilines = true,
  multiple_diag_under_cursor = true,
  show_all_diags_on_cursorline = true,
}

function spec.config(_, opts)
  require('tiny-inline-diagnostic').setup(opts)

  vim.diagnostic.config({ virtual_text = false })
end

return spec
