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

local lsp = {
  'neovim/nvim-lspconfig',
  opts = { servers = {} },
}

local cmp = {
  'saghen/blink.cmp',
  opts = {},
}

lsp.opts.servers.lua_ls = {
  settings = {
    lua = { completion = { callSnippet = 'Replace' } },
    diagnostics = { disable = { 'missing-fields' } },
  },
}

cmp.opts.sources = {
  -- add lazydev to completion providers
  default = { 'lazydev' },
  providers = { lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink' } },
}

return vim.list_extend(lazydev, { lsp, cmp })
