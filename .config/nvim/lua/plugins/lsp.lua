local lazydev = {
  'folke/lazydev.nvim',
  ft = 'lua', -- only load on lua files
  opts = {},
}

lazydev.opts.library = {
  { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
}

--

local blink = {
  'saghen/blink.cmp',
  build = 'cargo +nightly build --release',
  event = 'InsertEnter',
  opts_extend = {
    'sources.default',
  },
  dependencies = {
    'rafamadriz/friendly-snippets',
  },
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {},
}

blink.opts.completion = {
  documentation = {
    auto_show = true,
    auto_show_delay_ms = 200,
  },
  menu = {
    draw = { treesitter = { 'lsp' } },
  },
  trigger = {
    show_in_snippet = false,
  },
}

blink.opts.fuzzy = {
  prebuilt_binaries = { download = false },
}

blink.opts.keymap = {
  preset = 'super-tab',
}

blink.opts.sources = {
  default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
  providers = {
    lazydev = {
      name = 'LazyDev',
      module = 'lazydev.integrations.blink',
      score_offset = 100,
    },
  },
}

return {
  { 'neovim/nvim-lspconfig' },
  { 'j-hui/fidget.nvim', config = true },
  lazydev,
  blink,
}
