local spec = {
  'rachartier/tiny-inline-diagnostic.nvim',
  event = 'VeryLazy',
  priority = 900, -- needs to be loaded earlier
  opts = {},
}

spec.opts.blend = { factor = 0.1 }

spec.opts.options = {
  show_source = true,
  multilines = true,
  multiple_diag_under_cursor = true,
  show_all_diags_on_cursorline = true,
}

return spec
