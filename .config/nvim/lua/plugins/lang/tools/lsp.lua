-- LSP configuration for `nvim-lspconfig`.
---@class LspConfig
---@field buf LspConfig.buf?
---@field capabilities LspConfig.capabilities?
---@field diagnostic LspConfig.diagnostic?
---@field handlers LspConfig.handlers?
---@field servers LspConfig.servers?

-- Options for the following `vim.lsp.buf` functions:
-- - [vim.lsp.buf.code_action](lua://LspConfig.buf.code_action)
-- - [vim.lsp.buf.declaration](lua://LspConfig.buf.declaration)
-- - [vim.lsp.buf.definition](lua://LspConfig.buf.definition)
-- - [vim.lsp.buf.document_symbol](lua://LspConfig.buf.document_symbol)
-- - [vim.lsp.buf.implementation](lua://LspConfig.buf.implementation)
-- - [vim.lsp.buf.format](lua://LspConfig.buf.format)
-- - [vim.lsp.buf.rename](lua://LspConfig.buf.rename)
-- - [vim.lsp.buf.references](lua://LspConfig.buf.references)
-- - [vim.lsp.buf.type_definition](lua://LspConfig.buf.type_definition)
-- - [vim.lsp.buf.workspace_symbol](lua://LspConfig.buf.workspace_symbol)
-- `filter` list are reduced to a single predicate using `and` operator.
---@class LspConfig.buf
---@field code_action LspConfig.buf.code_action?
---@field declaration LspConfig.buf.declaration?
---@field definition LspConfig.buf.definition?
---@field document_symbol LspConfig.buf.document_symbol?
---@field format LspConfig.buf.format?
---@field implementation LspConfig.buf.implementation?
---@field references LspConfig.buf.references?
---@field rename LspConfig.buf.rename?
---@field type_definition LspConfig.buf.type_definition?
---@field workspace_symbol LspConfig.buf.workspace_symbol?

-- Options for `vim.lsp.buf.code_action`.
---@class LspConfig.buf.code_action: vim.lsp.buf.code_action.Opts
---@field filter fun(x: lsp.CodeAction|lsp.Command):boolean?[]?

-- Options for `vim.lsp.buf.declaration`.
---@alias LspConfig.buf.declaration vim.lsp.LocationOpts?

-- Options for `vim.lsp.buf.definition`.
---@alias LspConfig.buf.definition vim.lsp.LocationOpts?

-- Options for `vim.lsp.buf.document_symbol`.
---@alias LspConfig.buf.document_symbol vim.lsp.ListOpts?

-- Options for `vim.lsp.buf.implematation`.
---@alias LspConfig.buf.implementation vim.lsp.LocationOpts?

-- Options for `vim.lsp.buf.format`.
---@class LspConfig.buf.format: vim.lsp.buf.format.Opts
---@field filter fun(client: vim.lsp.Client):boolean?[]?

-- Options for `vim.lsp.buf.references`.
---@alias LspConfig.buf.references vim.lsp.ListOpts?

-- Options for `vim.lsp.buf.rename`
---@class LspConfig.buf.rename: vim.lsp.buf.rename.Opts
---@field filter fun(client: vim.lsp.Client): boolean?[]?

-- Options for `vim.lsp.buf.type_definition`.
---@alias LspConfig.buf.type_definition vim.lsp.LocationOpts?

-- Options for `vim.lsp.buf.workspace_symbol`.
---@alias LspConfig.buf.workspace_symbol vim.lsp.ListOpts?

-- Global capabilities options that will be pass to each server, capabilities
-- defined in the server can override any option defined here:
-- ```lua
--   servers = {
--     lua_ls = {
--       capabilities = {
--          -- this will be overridden
--          foldingRange = { lineFoldingOnly = False }
--       }
--     }
--   }
-- ```
---@alias LspConfig.capabilities lsp.ClientCapabilities

-- Options for `vim.diagnostic.config()`.
---@alias LspConfig.diagnostic vim.diagnostic.Opts

-- Global handlers options that will be pass to each server. As describe in
-- [LspConfig.capabilities](lua://LspConfig.LspConfig.capabilities), any option
-- defined here can be override by the specific server.
---@alias LspConfig.handlers table<string, function>

-- Server configuration. Any key defined here will be pass to `nvim-lspconfig` setup
-- function. To see a list of all availabre LSP and its name run `:h
-- lspconfig-all`. Exemple:
-- ```lua
--   servers = {
--     -- lua
--     lua_ls = {
--       capabilities = { ... },
--       settings = { ... },
--       on_attach = function(client) ... end,
--       ...
--     },
--     -- python
--     basedpyright = {},
--     -- rust
--     rust_analyzer = {},
--     ...
--   }
-- ```
---@alias LspConfig.servers table<string, _server>

---@class _server: vim.lsp.ClientConfig
---@field cmd (string[]|fun(dispatchers: vim.lsp.rpc.Dispatchers): vim.lsp.rpc.PublicClient)?

local spec = {
  'neovim/nvim-lspconfig',
  dependencies = {
    'saghen/blink.cmp',
    { 'j-hui/fidget.nvim', opts = { progress = { ignore = { 'null-ls' } } } },
  },
  opts_extend = {
    'buf.code_action.filter',
    'buf.format.filter',
    'buf.rename.filter',
  },
  ---@type LspConfig
  opts = {},
}

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

spec.opts.capabilities = {
  workspace = {
    fileOperations = { didRename = true, willRename = true },
  },
  textDocument = {
    foldingRange = { dynamicRegistration = false, lineFoldingOnly = true },
  },
}

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

spec.opts.handlers = {
  ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' }),
  ['textDocument/signatureHelp'] = vim.lsp.with(
    vim.lsp.handlers.signature_help,
    { border = 'rounded' }
  ),
}

spec.opts.servers = {}

---@param opts LspConfig
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

  local function lsp_attach(event)
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
          vim.api.nvim_clear_autocmds({
            group = highlight_augroup,
            buffer = _event.buf,
          })
        end,
      })
    end

    --- keymaps
    map({ 'n', 'x' }, { '<f3>', 'gra', '<leader>la' }, function()
      vim.lsp.buf.code_action(opts.buf.code_action)
    end, { desc = 'Code Action' })

    nmap('gD', function()
      vim.lsp.buf.declaration(opts.buf.declaration)
    end, { desc = 'Goto Declaration' })

    nmap('gd', function()
      vim.lsp.buf.definition(opts.buf.definition)
    end, { desc = 'Goto Definition' })

    nmap('gO', function()
      vim.lsp.buf.document_symbol(opts.buf.document_symbol)
    end, { desc = 'Document Symbols' })

    map({ 'n', 'x' }, { '<f4>', 'grf', '<leader>lf' }, function()
      vim.lsp.buf.format(opts.buf.format)
    end, { desc = 'Format' })

    nmap('K', vim.lsp.buf.hover, { desc = 'Symbol Hover' })

    nmap('gri', function()
      vim.lsp.buf.implementation(opts.buf.implementation)
    end, { desc = 'Goto Implementations' })

    nmap({ 'grn', '<f2>', '<leader>lrn' }, function()
      vim.lsp.buf.rename(nil, opts.buf.rename)
    end, { desc = 'Rename' })

    nmap('grr', function()
      vim.lsp.buf.references(opts.buf.references)
    end, { desc = 'Goto References' })

    imap({ '<f1>', '<c-s>' }, vim.lsp.buf.signature_help, { desc = 'Signature Help' })
    nmap('<f1>', vim.lsp.buf.signature_help, { desc = 'Signature Help' })

    nmap('go', function()
      vim.lsp.buf.type_definition(opts.buf.type_definition)
    end, { desc = 'Type Definitions' })

    nmap('grw', function()
      vim.lsp.buf.workspace_symbol(nil, opts.buf.workspace_symbol)
    end)
    ---

    local state = {
      inlay_hint = true,
      codelens = false,
    }

    -- Toggle codelens
    if client.supports_method(vim.lsp.protocol.Methods.textDocument_codeLens) then
      local codelens_augroup = augroup('lsp_attach_codelens', false)

      local function codelens_enable()
        state.codelens = true
        vim.lsp.codelens.refresh()

        autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
          group = codelens_augroup,
          buffer = event.buf,
          callback = vim.lsp.codelens.refresh,
        })
      end

      local function codelens_disable()
        state.codelens = false
        vim.lsp.codelens.clear()

        vim.api.nvim_clear_autocmds({
          group = codelens_augroup,
          buffer = event.buf,
        })
      end

      nmap('<leader>tl', function()
        if state.codelens then
          codelens_disable()
        else
          codelens_enable()
        end
      end, { desc = 'Toggle Codelens' })
    end

    -- Toggle inlay hints
    if client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      local inlayhint_augroup = augroup('lsp_attach_inlayhint', false)

      local function inlayhint_enable()
        state.codelens = true
        vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })

        autocmd({ 'InsertEnter', 'InsertLeave' }, {
          group = inlayhint_augroup,
          buffer = event.buf,
          callback = function()
            local filter = { bufnr = event.buf }
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
          end,
        })
      end

      local function inlayhint_disable()
        state.codelens = false
        vim.lsp.inlay_hint.enable(false, { bufnr = event.buf })

        vim.api.nvim_clear_autocmds({
          group = inlayhint_augroup,
          buffer = event.buf,
        })
      end

      nmap('<leader>th', function()
        if state.inlay_hint then
          inlayhint_disable()
        else
          inlayhint_enable()
        end
      end, { desc = 'Toggle Inlay Hints' })
    end
  end

  autocmd('LspAttach', { group = augroup('lsp_attach'), callback = lsp_attach })

  vim.diagnostic.config(opts.diagnostic)

  for server, config in pairs(opts.servers) do
    config.capabilities = require('blink.cmp').get_lsp_capabilities(
      vim.tbl_deep_extend('force', opts.capabilities, config.capabilities or {})
    )
    config.handlers = vim.tbl_deep_extend('force', opts.handlers, config.handlers or {})

    require('lspconfig')[server].setup(config)
  end
end

return spec
