local autocmd = require('local.helpers').autocmd
local augroup = require('local.helpers').augroup

local function capitalize(str)
  return str:lower():gsub('%S+', function(word)
    return word:gsub('^%l', string.upper)
  end)
end

vim.diagnostic.config({
  severity_sort = true,
  -- stylua: ignore
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = require('config.icons') .diagnostics.error,
      [vim.diagnostic.severity.WARN]  = require('config.icons').diagnostics.warn,
      [vim.diagnostic.severity.INFO]  = require('config.icons').diagnostics.info,
      [vim.diagnostic.severity.HINT]  = require('config.icons').diagnostics.hint,
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = 'DiagnosticError',
      [vim.diagnostic.severity.WARN]  = 'DiagnosticWarn',
      [vim.diagnostic.severity.INFO]  = 'DiagnosticInfo',
      [vim.diagnostic.severity.HINT]  = 'DiagnosticHint',
    }
  },
  underline = true,
  update_in_insert = false,
  virtual_text = {
    format = function(diagnostic)
      local message = diagnostic.message:gsub('^%s*(.-)[%s%.\n]*$', '%1')

      return message .. '.'
    end,
  },
  virtual_lines = {
    current_line = true,
    format = function(diagnostic)
      local source = capitalize(diagnostic.source:gsub('^%s*(.-)[%s%.]*$', '%1'))
      local message = diagnostic.message:gsub('^%s*(.-)[%s%.\n]*$', '%1')
      local separator = message:match('\n') and '\n\t' or '. '

      return string.format('[%s] %s%s(%s)', diagnostic.code, message, separator, source)
    end,
  },
  float = {
    source = true,
  },
})

-- diagnostic are disabled if the buffer is not modifiable or readony
-- see `lua/config/lsp.lua` and `lua/plugins/lint.lua`
autocmd('BufReadPost', {
  group = augroup('no_diagnostic_notification'),
  callback = function(ev)
    vim.defer_fn(function()
      if not vim.api.nvim_buf_is_valid(ev.buf) then
        return
      end

      if vim.b[ev.buf].no_diagnostic_notified or not vim.b[ev.buf].tried_diagnostics then
        return
      end

      local msg
      local msg_fmt = 'Diagnostics disabled on this buffer because %s.'

      if not vim.bo[ev.buf].modifiable then
        msg = string.format(msg_fmt, 'writing is not allowed (readonly)')
      elseif vim.bo[ev.buf].readonly then
        msg = string.format(msg_fmt, 'change is not allowed (not modifiable)')
      end

      if msg then
        vim.notify(msg, vim.log.levels.INFO)
        vim.b[ev.buf].no_diagnostic_notified = true
      end
    end, 1000)
  end,
})

-- clear virtual text/lines diagnostics as soon as insert mode start
autocmd('InsertEnter', {
  group = augroup('diagnostic_insert_mode_hide'),
  callback = function(ev)
    for _, namespace in pairs(vim.diagnostic.get_namespaces()) do
      local virt_text_ns = namespace.user_data.virt_text_ns
      local virt_lines_ns = namespace.user_data.virt_lines_ns

      if virt_text_ns then
        vim.api.nvim_buf_clear_namespace(ev.buf, virt_text_ns, 0, -1)
      end

      if virt_lines_ns then
        vim.api.nvim_buf_clear_namespace(ev.buf, virt_lines_ns, 0, -1)
      end
    end
  end,
})

-- immediatially show diagnostics decorations when leaving insert mode
autocmd('InsertLeave', {
  group = augroup('diagnostic_insert_mode_show'),
  callback = function(ev)
    vim.diagnostic.show(nil, ev.buf)
  end,
})

autocmd({ 'CursorMoved', 'CursorHold', 'DiagnosticChanged' }, {
  group = augroup('diagnostic_only_virt_lines'),
  callback = function(ev)
    vim.defer_fn(function()
      -- needed because the function is being defered
      if not vim.api.nvim_buf_is_valid(ev.buf) then
        return
      end

      local has_virt_lines
      for _, namespace in pairs(vim.diagnostic.get_namespaces()) do
        local ns = namespace.user_data.virt_lines_ns
        if ns then
          local extmarks = vim.api.nvim_buf_get_extmarks(ev.buf, ns, 0, -1, {})
          if not vim.tbl_isempty(extmarks) then
            has_virt_lines = true
            break
          end
        end
      end

      if has_virt_lines then
        for _, namespace in pairs(vim.diagnostic.get_namespaces()) do
          local ns = namespace.user_data.virt_text_ns
          if ns then
            vim.api.nvim_buf_clear_namespace(ev.buf, ns, 0, -1)
            vim.b[ev.buf].diagnostic_virt_text_cleared = true
          end
        end
      elseif vim.b[ev.buf].diagnostic_virt_text_cleared then
        vim.b[ev.buf].diagnostic_virt_text_cleared = nil
        vim.diagnostic.show(nil, ev.buf)
      end
    end, 50)
    -- defer by 50ms to make sure that the callback run after the virtual lines
    -- have been updated (or at least try)
    -- vim.defer_fn(cb, 50)
  end,
})
