---@class CodeAction: vim.lsp.buf.code_action.Opts
---@field filter fun(x: lsp.CodeAction|lsp.Command):boolean?|fun(x: lsp.CodeAction|lsp.Command):boolean?[]?

---@class Format: vim.lsp.buf.format.Opts
---@field filter fun(client: vim.lsp.Client):boolean?|fun(client: vim.lsp.Client):boolean?[]?

---@class Rename: vim.lsp.buf.rename.Opts
---@field filter fun(client: vim.lsp.Client): boolean?|fun(client: vim.lsp.Client): boolean?[]?

---@class Buf
---@field code_action CodeAction?
---@field declaration vim.lsp.LocationOpts?
---@field definition vim.lsp.LocationOpts?
---@field document_symbol vim.lsp.ListOpts?
---@field format Format?
---@field implementation vim.lsp.LocationOpts?
---@field references vim.lsp.ListOpts?
---@field rename Rename?
---@field type_definition vim.lsp.LocationOpts?
---@field workspace_symbol vim.lsp.ListOpts?

---@class Server: vim.lsp.ClientConfig
---@field cmd (string[]|fun(dispatchers: vim.lsp.rpc.Dispatchers): vim.lsp.rpc.PublicClient)?

---@class LspOpts
---@field buf Buf?
---@field capabilities lsp.ClientCapabilities?
---@field diagnostic vim.diagnostic.Opts?
---@field servers table<string, Server>?

local spec = {
  'neovim/nvim-lspconfig',
  dependencies = {
    'saghen/blink.cmp',
    { 'j-hui/fidget.nvim', opts = {} },
  },
  opts_extend = {
    'buf.code_action.filter',
    'buf.format.filter',
    'buf.rename.filter',
  },
  ---@type LspOpts
  opts = {},
}

-- options for some `lsp.buf.*` functions
-- `filter` option can receive a list of predicate
-- that will be reduced using `and` operation
spec.opts.buf = {
  code_action = { filter = {}, apply = true },
  declaration = {},
  definition = {},
  document_symbol = {},
  implementation = {},
  format = { filter = {}, async = true },
  rename = { filter = {} },
  references = {},
  type_definition = {},
  workspace_symbol = {},
}

-- global capabilities options
spec.opts.capabilities = {
  workspace = {
    fileOperations = { didRename = true, willRename = true },
  },
  textDocument = {
    foldingRange = { dynamicRegistration = false, lineFoldingOnly = true },
  },
}

-- options for `vim.diagnostic.config()`
spec.opts.diagnostic = {
  severity_sort = true,
  -- stylua: ignore
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = require('local.icons').diagnostics.error,
      [vim.diagnostic.severity.WARN]  = require('local.icons').diagnostics.warn,
      [vim.diagnostic.severity.INFO]  = require('local.icons').diagnostics.info,
      [vim.diagnostic.severity.HINT]  = require('local.icons').diagnostics.hint,
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
  virtual_text = true,
}

-- server configuration
spec.opts.servers = {
  -- moved to lua/plugins/lang/lua.lua
  -- lua_ls = {},
}

function spec.config(_, opts)
  local helpers = require('local.helpers')
  local autocmd = helpers.autocmd
  local augroup = helpers.augroup

  for _, name in ipairs({ 'code_action', 'format', 'rename' }) do
    local predicates = vim.deepcopy(opts.buf[name].filter)
    opts.buf[name].filter = function(x)
      return vim.iter(predicates):all(function(predicate)
        return predicate(x)
      end)
    end
  end

  autocmd('LspAttach', {
    group = augroup('lsp_attach'),
    callback = function(event)
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if not client then
        return
      end

      -- set current directory for current tab
      if client.root_dir then
        vim.cmd.tcd(client.root_dir)
      end

      local map = helpers.mapping({ buffer = event.buf })
      local nmap = helpers.mapping({ mode = 'n', buffer = event.buf })
      local imap = helpers.mapping({ mode = 'i', buffer = event.buf })

      if client.supports_method(vim.lsp.protocol.Methods.textDocument_codeAction) then
        map({ 'n', 'x' }, { '<f3>', 'gra', '<leader>la' }, function()
          vim.lsp.buf.code_action(opts.buf.code_action)
        end, { desc = 'Code Action' })
      end

      -- the following two autocommands are used to highlight references of the
      -- word under your cursor when your cursor rests there for a little while.
      if client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
        local highlight_augroup = augroup('lsp_highlight', false)

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
          callback = function(_event)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds({ group = highlight_augroup, buffer = _event.buf })
          end,
        })
      end

      -- keymaps
      if client.supports_method(vim.lsp.protocol.Methods.textDocument_declaration) then
        nmap('gd', function()
          vim.lsp.buf.declaration(opts.buf.declaration)
        end, { desc = 'Goto Declaration' })
      end

      if client.supports_method(vim.lsp.protocol.Methods.textDocument_definition) then
        nmap('gD', function()
          vim.lsp.buf.definition(opts.buf.definition)
        end, { desc = 'Goto Definition' })
      end

      if client.supports_method(vim.lsp.protocol.Methods.textDocument_documentSymbol) then
        nmap('gO', function()
          vim.lsp.buf.document_symbol(opts.buf.document_symbol)
        end, { desc = 'Document Symbols' })
      end

      if client.supports_method(vim.lsp.protocol.Methods.textDocument_formatting) then
        map({ 'n', 'x' }, { '<f4>', 'grf' }, function()
          vim.lsp.buf.format(opts.buf.format)
        end, { desc = 'Format' })
      end

      if client.supports_method(vim.lsp.protocol.Methods.textDocument_hover) then
        nmap('K', vim.lsp.buf.hover, { desc = 'Symbol Hover' })
      end

      if client.supports_method(vim.lsp.protocol.Methods.textDocument_implementation) then
        nmap('gri', function()
          vim.lsp.buf.implementation(opts.buf.implementation)
        end, { desc = 'Goto Implementations' })
      end

      if client.supports_method(vim.lsp.protocol.Methods.textDocument_rename) then
        nmap({ 'grn', '<f2>', '<leader>lrn' }, function()
          vim.lsp.buf.rename(nil, opts.buf.rename)
        end, { desc = 'Rename' })
      end

      if client.supports_method(vim.lsp.protocol.Methods.textDocument_references) then
        nmap('grr', function()
          vim.lsp.buf.references(opts.buf.references)
        end, { desc = 'Goto References' })
      end

      if client.supports_method(vim.lsp.protocol.Methods.textDocument_signatureHelp) then
        imap('<c-s>', vim.lsp.buf.signature_help, { desc = 'Signature Help' })
      end

      if client.supports_method(vim.lsp.protocol.Methods.textDocument_typeDefinition) then
        nmap('go', function()
          vim.lsp.buf.type_definition(opts.buf.type_definition)
        end, { desc = 'Type Definitions' })
      end

      if client.supports_method(vim.lsp.protocol.Methods.workspace_symbol) then
        nmap('grw', function()
          vim.lsp.buf.workspace_symbol(nil, opts.buf.workspace_symbol)
        end)
      end

      if client.supports_method(vim.lsp.protocol.Methods.textDocument_codeLens) then
        local codelens_augroup = augroup('lsp_codelens', false)
        local is_enabled = false

        local function enable()
          vim.lsp.codelens.refresh()
          is_enabled = true

          autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
            group = codelens_augroup,
            buffer = event.buf,
            callback = vim.lsp.codelens.refresh,
          })
        end

        local function disable()
          vim.lsp.codelens.clear()
          is_enabled = false
          vim.api.nvim_clear_autocmds({
            group = 'lsp_codelens',
            buffer = event.buf,
          })
        end

        -- enable()

        nmap('<leader>tc', function()
          if is_enabled then
            disable()
          else
            enable()
          end
        end, { desc = 'Toggle Codelens' })
      end

      if client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
        vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })

        nmap('<leader>th', function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
        end, { desc = 'Toggle Inlay Hints' })
      end
    end,
  })

  vim.diagnostic.config(opts.diagnostic)

  for server, config in pairs(opts.servers) do
    config.capabilities = require('blink.cmp').get_lsp_capabilities(
      vim.tbl_deep_extend('force', opts.capabilities, config.capabilities or {})
    )

    require('lspconfig')[server].setup(config)
  end
end

return spec
