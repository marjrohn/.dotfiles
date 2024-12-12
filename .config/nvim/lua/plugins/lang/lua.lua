local lazydev = {
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = { { path = 'luvit-meta/library', words = { 'vim%.uv' } } },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true },
}

local treesitter = { 'nvim-treesitter/nvim-treesitter', opts = {} }
local lsp = { 'neovim/nvim-lspconfig', opts = { servers = {} } }
local cmp = { 'saghen/blink.cmp', opts = {} }
local null_ls = { 'nvimtools/none-ls.nvim' }

treesitter.opts.ensure_installed = {
  'lua',
  'luap',
  'luadoc',
}

lsp.opts.servers.lua_ls = {
  settings = {
    lua = { completion = { callSnippet = 'Replace' } },
    diagnostics = { disable = { 'missing-fields' } },
  },
}

cmp.opts.sources = {
  default = { 'lazydev' },
  providers = { lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink' } },
}

function null_ls.opts(_, opts)
  opts.sources = opts.sources or {}

  vim.list_extend(opts.sources, {
    require('null-ls').builtins.formatting.stylua,
    require('null-ls').builtins.diagnostics.selene,
  })
end

return vim.list_extend(lazydev, { treesitter, lsp, cmp, null_ls })
