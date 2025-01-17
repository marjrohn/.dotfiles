local tiny = {
  'rachartier/tiny-inline-diagnostic.nvim',
  event = 'VeryLazy',
  priority = 900, -- needs to be loaded earlier
  opts = {},
}

tiny.opts.blend = { factor = 0.1 }

tiny.opts.options = {
  show_source = true,
  multilines = true,
  multiple_diag_under_cursor = true,
  show_all_diags_on_cursorline = true,
}

local lsp = {
  'neovim/nvim-lspconfig',
  opts = {
    diagnostic = { virtual_text = false },
  },
}

return { tiny, lsp }
