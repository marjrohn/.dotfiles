local spec = {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'saghen/blink.cmp' },
    { 'j-hui/fidget.nvim', config = true },
  },
  opts_extend = { 'servers' },
  opts = {
    servers = {},
  },
}

function spec.config(_, opts)
  local helpers = require('local.helpers')

  local autocmd = helpers.autocmd
  local augroup = helpers.augroup

  autocmd('LspAttach', {
    group = augroup('lsp_attach'),
    callback = function(event)
      --- keymaps
      local map = helpers.map({ buffer = event.buf })
      local nmap = helpers.map({ mode = 'n', buffer = event.buf })
      local imap = helpers.map({ mode = 'i', buffer = event.buf })

      nmap('grn', vim.lsp.buf.rename, { desc = 'Rename' })
      nmap('<f2>', vim.lsp.buf.rename, { desc = 'Rename' })
      nmap('<leader>lr', vim.lsp.buf.rename, { desc = 'Rename' })

      nmap('<f3>', vim.lsp.buf.format, { desc = 'Format' })
      nmap('<leader>lf', vim.lsp.buf.format, { desc = 'Format' })

      map({ 'n', 'x' }, 'gra', vim.lsp.buf.code_action, { desc = 'Code Action' })
      map({ 'n', 'x' }, '<f4>', vim.lsp.buf.code_action, { desc = 'Code Action' })
      map({ 'n', 'x' }, '<leader>lca', vim.lsp.buf.code_action, { desc = 'Code Action' })

      nmap('grn', vim.lsp.buf.references, { desc = 'Goto References' })
      nmap('gR', vim.lsp.buf.references, { desc = 'Goto References' })

      nmap('gri', vim.lsp.buf.implementation, { desc = 'Goto Implementations' })
      nmap('go', vim.lsp.buf.type_definition, { desc = 'Type Definitions' })
      nmap('gO', vim.lsp.buf.document_symbol, { desc = 'Document Symbols' })

      imap('<c-s>', vim.lsp.buf.signature_help, { desc = 'Signature Help' })

      nmap('gd', vim.lsp.buf.definition, { desc = 'Goto Definition' })
      nmap('gD', vim.lsp.buf.declaration, { desc = 'Goto Declaration' })

      nmap('K', vim.lsp.buf.hover, { desc = 'Symbol Hover' })
      ---

      -- The following two autocommands are used to highlight references of the
      -- word under your cursor when your cursor rests there for a little while.
      local client = vim.lsp.get_client_by_id(event.data.client_id)

      if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
        local highlight_augroup = augroup('lsp_highlight', true)

        autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })

        autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })

        autocmd('LspDetach', {
          group = augroup('lsp_detach'),
          callback = function(ev)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds({ group = 'lsp_highlight', buffer = ev.buf })
          end,
        })
      end

      -- The following code creates a keymap to toggle inlay hints in your
      -- code, if the language server upports them
      if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
        nmap('<leader>lH', function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
        end, { desc = 'Toggle Inlay Hints' })
      end
    end,
  })

  --- Change diagnostic symbols in the sign column (gutter)
  local signs = require('local.icons').diagnostics

  for type, icon in pairs(signs) do
    local hl = 'DiagnosticSign' .. type:lower():gsub('^%l', string.upper)
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end
  ---

  --- languages serves
  opts.servers = vim.tbl_deep_extend('force', opts.servers, {
    lua_ls = {
      settings = {
        lua = { completion = { callSnippet = 'Replace' } },
        diagnostics = { disable = { 'missing-fields' } },
      },
    },
  })

  for server, config in pairs(opts.servers) do
    config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)

    require('lspconfig')[server].setup(config)
  end
end

return spec
