return {
  'saghen/blink.cmp',
  dependencies = 'rafamadriz/friendly-snippets',
  build = 'cargo +nightly build --release',
  opts = {
    nerd_font_variant = 'mono',
    highlight = { use_nvim_cmp_as_default = true },
    accept = { auto_brackets = { enabled = true } },
    trigger = { signature_help = { enabled = true } },
    sources = {
      -- add lazydev to your completion providers
      completion = { enabled_providers = { 'lsp', 'path', 'snippets', 'buffer', 'lazydev' } },
      -- dont show LuaLS require statements when lazydev has items
      providers = {
        lsp = { fallback_for = { 'lazydev' } },
        lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink' },
      },
    },
  },
}
