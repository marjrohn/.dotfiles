local lazydev = {
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true },
}

local treesitter = { 'nvim-treesitter/nvim-treesitter', opts = {} }

treesitter.opts.ensure_installed = {
  'lua',
  'luap',
  'luadoc',
}

local lsp = {
  'neovim/nvim-lspconfig',
  ---@type LspConfig
  opts = { buf = {}, servers = {} },
}

lsp.opts.buf.format = {
  filter = {
    function(client)
      -- format with `stylua`(null_ls) instead
      return client.name ~= 'lua_ls'
    end,
  },
}

lsp.opts.servers.lua_ls = {
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      codeLens = { enable = true },
      completion = { callSnippet = 'Replace' },
      doc = { privateName = { '^_' } },
      hint = {
        enable = true,
        setType = false,
        paramType = true,
        paramName = 'Disable',
        semicolon = 'Disable',
        arrayIndex = 'Disable',
      },
    },
  },
}

local blink = { 'saghen/blink.cmp', opts = {} }

blink.opts.sources = {
  default = { 'lazydev' },
  providers = {
    lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink' },
  },
}

local null_ls = { 'nvimtools/none-ls.nvim', opts = {} }

null_ls.opts.root_markers = {
  'selene.toml',
  'stylua.toml',
  '.stylua.toml',
}

null_ls.opts.sources = {
  function()
    local formatting = require('null-ls').builtins.formatting
    local diagnostics = require('null-ls').builtins.diagnostics

    return { formatting.stylua, diagnostics.selene }
  end,
}

return vim.list_extend(lazydev, { treesitter, lsp, blink, null_ls })
