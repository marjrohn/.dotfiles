local timeout = 3000

local conform = {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {},
  ---@module 'conform'
  ---@type conform.setupOpts
  opts = {},
}

conform.opts.formatters_by_ft = {
  lua = { 'stylua' },
  ['_'] = { 'trim_whitespace' },
  ['*'] = { 'injected' },
}

conform.opts.default_format_opts = {
  timeout_ms = timeout,
  async = false,
  quit = false,
  lsp_format = 'fallback',
}

conform.opts.formatters = {
  injected = { options = { ignore_errors = true } },
}

function conform.opts.format_on_save(buf)
  local g_var = vim.g.lsp_autoformat_enable
  local b_var = vim.b[buf].lsp_autoformat_enable

  if (b_var == nil) and (g_var == true) or (b_var == true) then
    return {
      timeout_ms = timeout,
      async = false,
      quit = false,
      lsp_format = 'fallback',
    }
  end
end

local map = require('local.helpers').mapping({ mode = { 'n', 'x' }, key_list = conform.keys })

map({ 'grf', '<f4>', '<leader>lf' }, function()
  require('conform').format()
end, { desc = 'Format' })

map({ 'grF', '<leader>lF' }, function()
  require('conform').format({ formatters = { 'injected' } })
end, { desc = 'Format (Injected)' })

return conform
