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
}
---@class LspConfig
spec.opts = {}

---Options for the following `vim.lsp.buf` functions:
---  - [vim.lsp.buf.code_action](lua://LspConfig.buf.code_action)
---  - [vim.lsp.buf.declaration](lua://LspConfig.buf.declaration)
---  - [vim.lsp.buf.definition](lua://LspConfig.buf.definition)
---  - [vim.lsp.buf.document_symbol](lua://LspConfig.buf.document_symbol)
---  - [vim.lsp.buf.implementation](lua://LspConfig.buf.implementation)
---  - [vim.lsp.buf.format](lua://LspConfig.buf.format)
---  - [vim.lsp.buf.rename](lua://LspConfig.buf.rename)
---  - [vim.lsp.buf.references](lua://LspConfig.buf.references)
---  - [vim.lsp.buf.type_definition](lua://LspConfig.buf.type_definition)
---  - [vim.lsp.buf.workspace_symbol](lua://LspConfig.buf.workspace_symbol)
---any `filter` field will be reduced to a single predicate using `and` operator.
---@class LspConfig.buf
spec.opts.buf = {
  ---Options for `vim.lsp.buf.code_action`.
  ---@alias LspConfig.byf.code_action vim.lsp.buf.code_action.Opts?
  ---@type LspConfig.byf.code_action
  code_action = {
    ---@type (fun(x: lsp.CodeAction|lsp.Command):boolean)[]?
    filter = {},
    apply = true,
  },
  ---Options for `vim.lsp.buf.declaration`.
  ---@type vim.lsp.LocationOpts?
  declaration = {},
  ---Options for `vim.lsp.buf.definition`.
  ---@type vim.lsp.LocationOpts?
  definition = {},
  ---Options for `vim.lsp.buf.document_symbol`.
  ---@type vim.lsp.ListOpts?
  document_symbol = {},
  ---Options for `vim.lsp.buf.implematation`.
  ---@type vim.lsp.LocationOpts?
  implementation = {},
  ---Options for `vim.lsp.buf.format`.
  ---@alias LspConfig.buf.format vim.lsp.buf.format.Opts?
  ---@type LspConfig.buf.format
  format = {
    ---@type (fun(client: vim.lsp.Client):boolean)[]?
    filter = {},
    async = true,
  },
  ---Options for `vim.lsp.buf.references`.
  ---@type vim.lsp.ListOpts?
  references = {},
  ---Options for `vim.lsp.buf.rename`
  ---@alias LspConfig.buf.rename vim.lsp.buf.rename.Opts?
  ---@type LspConfig.buf.rename
  rename = {
    ---@type (fun(client: vim.lsp.Client): boolean)[]?
    filter = {},
  },
  ---Options for `vim.lsp.buf.type_definition`.
  ---@type vim.lsp.LocationOpts?
  type_definition = {},
  ---Options for `vim.lsp.buf.workspace_symbol`.
  ---@type vim.lsp.ListOpts?
  workspace_symbol = {},
}

---Global capabilities options that will be pass to each server,
---capabilities defined in the server can override any option defined here.
---Exemple:
---```lua
---  servers = {
---    lua_ls = {
---      capabilities = {
---         -- this will be overridden
---         foldingRange = { lineFoldingOnly = False }
---      }
---    }
---  }
---```
---@class LspConfig.capabilities: lsp.ClientCapabilities?
spec.opts.capabilities = {
  workspace = {
    fileOperations = { didRename = true, willRename = true },
  },
  textDocument = {
    foldingRange = { dynamicRegistration = false, lineFoldingOnly = true },
  },
}

---Options for `vim.diagnostic.config()`.
---@class LspConfig.diagnostic: vim.diagnostic.Opts?
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

local function float_win_handler(method)
  local handler = vim.lsp.handlers[method]

  ---@type lsp.Handler
  return function(...)
    local args = { ... }
    local config = args[4] or {}

    vim.g.win_width = math.min(math.max(vim.g.win_width or 1, 0), 1)
    vim.g.win_height = math.min(math.max(vim.g.win_height or 1, 0), 1)

    config.border = require('local.icons').win.border
    config.max_width = math.floor(vim.g.win_width * vim.o.columns + 0.5)
    config.max_height = math.floor(vim.g.win_height * vim.o.lines + 0.5)

    args[4] = config
    return handler(unpack(args))
  end
end

---Global handlers options that will be pass to each server.
---Any option defined here can be override by the specific server configuration,
---as describe in [LspConfig.capabilities](lua://LspConfig.capabilities)
---@alias LspConfig.handlers table<string, function>
---@type LspConfig.handlers?
spec.opts.handlers = {
  ['textDocument/hover'] = float_win_handler('textDocument/hover'),
  ['textDocument/signatureHelp'] = float_win_handler('textDocument/signatureHelp'),
}

---Server configuration. Any key defined here will be pass to `nvim-lspconfig`
---setup function. To see a list of all availabre LSP run `:h lspconfig-all`.
---Exemple:
---```lua
---  servers = {
---    -- lua
---    lua_ls = {
---      capabilities = { ... },
---      settings = { ... },
---      on_attach = function(client) ... end,
---      ...
---    },
---    -- python
---    basedpyright = { ... },
---    -- rust
---    rust_analyzer = { ... },
---    ...
---  }
---```
---@alias LspConfig.servers table<string, lspconfig.Config>
---@type LspConfig.servers?
spec.opts.servers = {}

---@param opts LspConfig
function spec.config(_, opts)
  local helpers = require('local.helpers')
  local autocmd = helpers.autocmd
  local augroup = helpers.augroup

  -- reduce filters with operator `and`
  for _, name in ipairs({ 'code_action', 'format', 'rename' }) do
    local predicates = vim.deepcopy(opts.buf[name].filter)
    opts.buf[name].filter = function(x)
      return vim.iter(predicates):all(function(predicate)
        return predicate(x)
      end)
    end
  end

  -- see `:h vim.diagnostic.Opts`
  vim.diagnostic.config(opts.diagnostic)

  -- default lsp attach, regardless of server
  local function lsp_attach(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if not client then
      return
    end

    -- set the client rootdir as cwd for the current tab (tcd)
    -- but if the root is the homedir (or nil) then do nothing
    if not vim.fn.expand('~/'):match(client.root_dir or '') then
      vim.cmd.tcd(client.root_dir)
    end

    -- the following two autocommands are used to highlight references of the
    -- word under the cursor when the cursor rests there for a little while
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
        callback = function(event_)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({
            group = highlight_augroup,
            buffer = event_.buf,
          })
        end,
      })
    end

    -- keymaps
    local map = helpers.mapping({ buffer = event.buf })
    local nmap = helpers.mapping({ mode = 'n', buffer = event.buf })
    local imap = helpers.mapping({ mode = 'i', buffer = event.buf })

    local b = vim.lsp.buf
    local ob = opts.buf
    local with = function(fn, ...)
      local args = { ... }
      return function()
        fn(unpack(args))
      end
    end

    map(
      { 'n', 'x' },
      { '<f3>', 'gra', '<leader>la' },
      with(b.code_action, ob.code_action),
      { desc = 'Code Action' }
    )
    map(
      { 'n', 'x' },
      { '<f4>', 'grf', '<leader>lf' },
      with(b.format, ob.format),
      { desc = 'Format' }
    )
    nmap('gD', with(b.declaration, ob.declaration), { desc = 'Goto Declaration' })
    nmap('gd', with(b.definition, ob.definition), { desc = 'Goto Definition' })
    nmap('gO', with(b.document_symbol, ob.document_symbol), { desc = 'Document Symbols' })
    nmap('K', with(b.hover), { desc = 'Symbol Hover' })
    nmap('gri', with(b.implementation, ob.implementation), { desc = 'Goto Implementations' })
    nmap({ 'grn', '<f2>', '<leader>lrn' }, with(b.rename, nil, ob.rename), { desc = 'Rename' })
    nmap('grr', with(b.references, ob.references), { desc = 'Goto References' })
    -- Todo: remove <c-s> in v0.11, since it will be the default
    imap({ '<f1>', '<c-s>' }, b.signature_help, { desc = 'Signature Help' })
    nmap('<f1>', vim.lsp.buf.signature_help, { desc = 'Signature Help' })
    nmap('go', with(b.type_definition, ob.type_definition), { desc = 'Type Definitions' })
    nmap('grw', with(b.workspace_symbol, nil, ob.workspace_symbol))

    local state = {}
    -- Toggle codelens
    state.codelens = false

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
    state.inlay_hint = true

    if client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      local inlayhint_augroup = augroup('lsp_attach_inlayhint', false)
      local function inlayhint_enable()
        state.inlay_hint = true
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
        state.inlay_hint = false
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

  autocmd('LspAttach', {
    group = augroup('lsp_attach'),
    callback = lsp_attach,
  })

  -- set config for each client server
  for server, config in pairs(opts.servers) do
    config.capabilities = require('blink.cmp').get_lsp_capabilities(
      vim.tbl_deep_extend('force', opts.capabilities, config.capabilities or {}),
      true
    )
    config.handlers = vim.tbl_deep_extend('force', opts.handlers, config.handlers or {})

    -- TODO: impl a custom setup handler
    require('lspconfig')[server].setup(config)
  end
end

return spec
