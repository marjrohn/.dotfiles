local lazydev = { 'folke/lazydev.nvim', ft = 'lua', opts = {} }
local treesitter = { 'nvim-treesitter/nvim-treesitter', opts = {} }
local null_ls = { 'nvimtools/none-ls.nvim', opts = {} }
local lspconfig = {
  'neovim/nvim-lspconfig',
  ---@type LspConfig
  opts = { buf = {}, servers = {} },
}
local blink = {
  'saghen/blink.cmp',
  ---@type blink.cmp.Config
  opts = {},
}

local specs = { lazydev, treesitter, null_ls, lspconfig, blink }

-- stylua: ignore
lazydev.opts.library = {
  { path = '${3rd}/luv/library', words = {  'vim%.uv'  } },
  { path = 'lazy.nvim',          mods  = {    'lazy'   } },
  { path = 'nvim-lspconfig',     mods  = { 'lspconfig' } },
  { path = 'blink.cmp',          mods  = { 'blink.cmp' } }
}

treesitter.opts.ensure_installed = { 'lua', 'luap', 'luadoc' }

lspconfig.opts.buf.format = {
  filter = {
    function(client)
      -- format with `stylua`(null_ls) instead
      return client.name ~= 'lua_ls'
    end,
  },
}

lspconfig.opts.servers.lua_ls = {
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

blink.opts.sources = {
  default = { 'lazydev' },
  providers = {
    lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink' },
  },
}

null_ls.opts.root_markers = {
  'selene.toml',
  'stylua.toml',
  '.stylua.toml',
}

null_ls.opts.sources = {
  function(formatting, diagnostics)
    return { formatting.stylua, diagnostics.selene }
  end,
}

return specs
