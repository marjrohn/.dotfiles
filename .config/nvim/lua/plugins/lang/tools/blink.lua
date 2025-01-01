local spec = {
  'saghen/blink.cmp',
  build = 'cargo +nightly build --release',
  event = 'InsertEnter',
  opts_extend = {
    'sources.default',
    'sources.compat',
  },
  dependencies = {
    'rafamadriz/friendly-snippets',
    { 'saghen/blink.compat', opts = { impersonate_nvim_cmp = true } },
  },
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {},
}

spec.opts.appearance = { use_nvim_cmp_as_default = true }
spec.opts.completion = {
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
spec.opts.fuzzy = { prebuilt_binaries = { download = false } }
spec.opts.keymap = { preset = 'super-tab' }
spec.opts.sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } }

function spec.config(_, opts)
  -- setup compat sources
  local enabled = opts.sources.default
  for _, source in ipairs(opts.sources.compat or {}) do
    opts.sources.providers[source] = vim.tbl_deep_extend(
      'force',
      { name = source, module = 'blink.compat.source' },
      opts.sources.providers[source] or {}
    )

    if type(enabled) == 'table' and not vim.tbl_contains(enabled, source) then
      table.insert(enabled, source)
    end
  end

  -- Unset custom prop to pass blink.cmp validation
  opts.sources.compat = nil

  require('blink.cmp').setup(opts)
end

return spec
