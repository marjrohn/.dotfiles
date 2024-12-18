local spec = {
  'nvimtools/none-ls.nvim',
  dependencies = {
    'nvimtools/none-ls-extras.nvim',
    'nvim-lua/plenary.nvim',
  },
  opts_extend = {
    'root_markers',
    'sources',
  },
}

spec.opts = {
  root_markers = { '.git' },
  sources = {},
}

function spec.config(_, opts)
  opts.root_dir = opts.root_dir or require('null-ls.utils').root_pattern(opts.root_markers)

  opts.root_markers = nil

  opts.sources = vim
    .iter(opts.sources)
    :map(function(source)
      return source()
    end)
    :flatten()
    :totable()

  require('null-ls').setup(opts)
end

return spec
