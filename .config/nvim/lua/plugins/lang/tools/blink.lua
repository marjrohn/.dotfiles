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
  opts = {},
}

spec.opts.appereance = {
  use_nvim_cmp_as_default = true,
  nerd_font_variant = 'mono',
}

spec.opts.completion = {
  accept = {
    auto_brackets = { enabled = true },
  },
  documentation = {
    auto_show = true,
    auto_show_delay_ms = 200,
  },
  menu = {
    draw = { treesitter = true },
  },
  trigger = { show_in_snippet = false },
}

spec.opts.keymap = { preset = 'super-tab' }

spec.opts.prebuild_binaries = { download = false }

spec.opts.sources = {
  default = { 'lsp', 'path', 'snippets', 'buffer' },
  compat = {},
}

function spec.opts.config(_, opts)
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

  -- check if we need to override symbol kinds
  for _, provider in pairs(opts.sources.providers or {}) do
    if provider.kind then
      require('blink.cmp.types').CompletionItemKind[provider.kind] = provider.kind
      local transform_items = provider.transform_items

      provider.transform_items = function(ctx, items)
        items = transform_items and transform_items(ctx, items) or items
        for _, item in ipairs(items) do
          item.kind = provider.kind or item.kind
        end
        return items
      end
    end
  end

  require('blink.cmp').setup(opts)
end

return spec
