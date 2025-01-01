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
  -- Todo: define typying
  opts = {},
}

spec.opts = {
  root_markers = { '.git' },
  sources = {},
}

function spec.config(_, opts)
  local null_ls = require('null-ls')

  opts.root_dir = opts.root_dir or require('null-ls.utils').root_pattern(opts.root_markers)
  opts.root_markers = nil

  local sourcers = vim.deepcopy(opts.sources)
  opts.sources = vim
    .iter(vim.deepcopy(sourcers))
    :map(function(source)
      return source(
        null_ls.builtins.formatting,
        null_ls.builtins.diagnostics,
        null_ls.builtins.code_actions
      )
    end)
    :flatten()
    :totable()

  null_ls.setup(opts)
end

return spec
