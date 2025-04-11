---@diagnostic disable: missing-fields

local helpers = require('local.helpers')
local autocmd = helpers.autocmd
local augroup = helpers.augroup

--
-- [[ LSP Config ]]
--

---@type fun(name: string, cfg: vim.lsp.Config) | table<string, vim.lsp.Config>
local lspconfig = vim.lsp.config

lspconfig('*', {
  capabilities = {
    textDocument = { semanticTokens = { multilineTokenSupport = true } },
    workspace = {
      fileOperations = {
        didCreate = true,
        didDelete = true,
        didRename = true,
        willCreate = true,
        willDelete = true,
        willRename = true,
      },
    },
  },
  root_markers = { '.git' },
})

lspconfig.lua_ls = {
  capabilities = {
    textDocument = {
      formatting = { dynamicRegistration = false },
      rangeFormatting = { rangesSupport = false, dynamicRegistration = false },
    },
  },
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      codeLens = { enable = true },
      completion = { callSnippet = 'Replace' },
      doc = { privateName = { '^_' } },
      format = { enable = false },
      hint = {
        enable = true,
        setType = true,
        paramType = true,
        paramName = 'Disable',
        semicolon = 'Disable',
        arrayIndex = 'Auto',
      },
    },
  },
}

vim.lsp.enable({ 'lua_ls' })

--
-- [[ LSP Attach/Detach ]]
--

---@class State
---@field is_enabled boolean
---@field enable function
---@field disable function

---@class BufferState
---@field document_highlight? State
---@field inlay_hint? State
---@field codelens? State

---@type table<integer, BufferState>
local STATE_PER_ATTACHED_BUFFER = {}

-- help functions to aide avoid large levels of indentation
local H = {
  inlay_hint = {},
  codelens = {},
  document_highlight = {},
}

---@diagnostic disable-next-line: undefined-field
local timer = vim.uv.new_timer()

timer:start(
  tonumber(vim.g.lsp_refresh_time) or 1000,
  tonumber(vim.g.lsp_refresh_time) or 1000,
  vim.schedule_wrap(function()
    local function handler(buf, state, kind)
      if not vim.api.nvim_buf_is_valid(buf) or not (state and state[kind]) then
        return
      end

      if H.should_be_enabled(buf, kind) then
        state[kind].enable()
      else
        state[kind].disable()
      end
    end

    for buf, state in pairs(STATE_PER_ATTACHED_BUFFER) do
      for _, kind in ipairs({ 'document_highlight', 'inlay_hint', 'codelens' }) do
        handler(buf, state, kind)
      end
    end
  end)
)

augroup('lsp_attach')
augroup('lsp_detach')
augroup('lsp_document_highlight_clear')
augroup('lsp_document_highlight', false)
augroup('lsp_inlay_hint', false)
augroup('lsp_codelens', false)

autocmd('LspAttach', {
  group = 'lsp_attach',
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    if not client then
      return
    end

    -- set the client rootdir as cwd for the current tab (tcd)
    -- but if the root is the homedir (or nil) then do nothing
    if not vim.fn.expand('~/'):match(client.root_dir or '') then
      vim.cmd.tcd(client.root_dir)
    end

    -- folding
    if client:supports_method('textDocument/foldingRange', ev.buf) then
      local win = vim.api.nvim_get_current_win()
      vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
      -- TODO: implement my own foldtext
      vim.wo[win][0].foldtext = 'v:lua.vim.lsp.foldtext()'
    end

    -- disable diagnostics if the buffer is readonly or not modifiable in order to avoid noise
    local not_allowed = vim.bo[ev.buf].readonly or not vim.bo[ev.buf].modifiable

    -- pull (request) diagnostics
    if client:supports_method('textDocument/diagnostic', ev.buf) then
      vim.b[ev.buf].tried_diagnostics = true

      if not_allowed then
        vim.diagnostic.enable(false, {
          bufnr = ev.buf,
          namespace = vim.lsp.diagnostic.get_namespace(client.id, true),
        })
      end
    end

    -- push (notification) diagnostics
    if client:supports_method('textDocument/publishDiagnostic', ev.buf) then
      vim.b[ev.buf].tried_diagnostics = true

      if not_allowed then
        vim.diagnostic.enable(false, {
          bufnr = ev.buf,
          namespace = vim.lsp.diagnostic.get_namespace(client.id, false),
        })
      end
    end

    -- document highlight, inlay hints and codelens
    for kind, method in pairs({
      document_highlight = 'textDocument/documentHighlight',
      inlay_hint = 'textDocument/inlayHint',
      codelens = 'textDocument/codeLens',
    }) do
      if client:supports_method(method, ev.buf) then
        STATE_PER_ATTACHED_BUFFER[ev.buf] = STATE_PER_ATTACHED_BUFFER[ev.buf] or {}
        STATE_PER_ATTACHED_BUFFER[ev.buf][kind] = STATE_PER_ATTACHED_BUFFER[ev.buf][kind] or {}

        local state = STATE_PER_ATTACHED_BUFFER[ev.buf][kind]

        function state.enable()
          H[kind].enable(ev.buf, state)
        end

        function state.disable()
          H[kind].disable(ev.buf, state)
        end

        if H.should_be_enabled(ev.buf, kind) then
          state.enable()
        else
          state.is_enabled = false
        end
      end
    end

    -- keymaps

    -- local function with_config(fn, ...)
    --   local argv = { ... }
    --   return function()
    --     fn(unpack(argv))
    --   end
    -- end
    --
    -- local fzf, _ = pcall(require, 'fzf-lua')
    -- local conform, _ = pcall(require, 'conform')
    -- -- keymaps
    -- local map = helpers.mapping({ buffer = event.buf })
    -- local nmap = helpers.mapping({ mode = 'n', buffer = event.buf })
    -- local imap = helpers.mapping({ mode = 'i', buffer = event.buf })
    --
    -- local b = vim.lsp.buf
    -- local ob = opts.buf
    -- local with = function(fn, ...)
    --   local args = { ... }
    --   return function()
    --     fn(unpack(args))
    --   end
    -- end
    --
    -- map(
    --   { 'n', 'x' },
    --   { '<f3>', 'gra', '<leader>la' },
    --   with(b.code_action, ob.code_action),
    --   { desc = 'Code Action' }
    -- )
    -- map(
    --   { 'n', 'x' },
    --   { '<f4>', 'grf', '<leader>lf' },
    --   with(b.format, ob.format),
    --   { desc = 'Format' }
    -- )
    -- nmap('gD', with(b.declaration, ob.declaration), { desc = 'Goto Declaration' })
    -- nmap('gd', with(b.definition, ob.definition), { desc = 'Goto Definition' })
    -- nmap('gO', with(b.document_symbol, ob.document_symbol), { desc = 'Document Symbols' })
    -- nmap('K', with(b.hover), { desc = 'Symbol Hover' })
    -- nmap('gri', with(b.implementation, ob.implementation), { desc = 'Goto Implementations' })
    -- nmap({ 'grn', '<f2>', '<leader>lrn' }, with(b.rename, nil, ob.rename), { desc = 'Rename' })
    -- nmap('grr', with(b.references, ob.references), { desc = 'Goto References' })
    -- imap('<f1>', b.signature_help, { desc = 'Signature Help' })
    -- nmap('<f1>', vim.lsp.buf.signature_help, { desc = 'Signature Help' })
    -- nmap('go', with(b.type_definition, ob.type_definition), { desc = 'Type Definitions' })
    -- nmap('grw', with(b.workspace_symbol, nil, ob.workspace_symbol))
  end,
})

autocmd('LspDetach', {
  group = 'lsp_detach',
  callback = function(ev)
    for kind, method in pairs({
      document_highlight = 'textDocument/documentHighlight',
      inlay_hint = 'textDocument/inlayHint',
      codelens = 'textDocument/codeLens',
    }) do
      if
        not vim.iter(vim.lsp.get_clients({ bufnr = ev.buf })):any(function(client)
          return client.id ~= ev.data.client_id and client:supports_method(method, ev.buf)
        end)
      then
        STATE_PER_ATTACHED_BUFFER[ev.buf][kind] = nil
      end
    end

    if vim.tbl_isempty(STATE_PER_ATTACHED_BUFFER[ev.buf]) then
      STATE_PER_ATTACHED_BUFFER[ev.buf] = nil
    end
  end,
})

function H.should_be_enabled(buf, kind)
  local index = 'lsp_' .. kind .. '_enable'
  local b_var = vim.b[buf][index]
  local g_var = vim.g[index]

  return (b_var == nil) and (g_var == true) or (b_var == true)
end

function H.document_highlight.enable(buf, state)
  if not state.is_enabled then
    state.is_enabled = true

    autocmd({ 'CursorHold', 'CursorHoldI' }, {
      buffer = buf,
      group = 'lsp_document_highlight',
      callback = vim.lsp.buf.document_highlight,
    })

    autocmd({ 'CursorMoved', 'CursorMovedI', 'LspDetach' }, {
      buffer = buf,
      group = 'lsp_document_highlight',
      callback = vim.lsp.buf.clear_references,
    })

    autocmd('LspDetach', {
      group = 'lsp_document_highlight_clear',
      buffer = buf,
      callback = function(ev)
        -- remove the above autocmds if the buffer does not have any
        -- attached client that supports document highlight
        if
          not vim.iter(vim.lsp.get_clients({ bufnr = ev.buf })):any(function(client)
            return client.id ~= ev.data.client_id
              and client:supports_method('textDocument/documentHighlight', ev.buf)
          end)
        then
          vim.api.nvim_clear_autocmds({
            buffer = ev.buf,
            group = 'lsp_document_highlight',
          })
        end
      end,
    })
  end
end

function H.document_highlight.disable(buf, state)
  if state.is_enabled then
    state.is_enabled = false

    vim.api.nvim_buf_call(buf, function()
      vim.lsp.buf.clear_references()
    end)

    vim.api.nvim_clear_autocmds({
      buffer = buf,
      group = 'lsp_document_highlight',
    })

    vim.api.nvim_clear_autocmds({
      buffer = buf,
      group = 'lsp_document_highlight_clear',
    })
  end
end

function H.inlay_hint.enable(buf, state)
  if not state.is_enabled then
    state.is_enabled = true

    vim.lsp.inlay_hint.enable(true, { bufnr = buf })

    autocmd('InsertEnter', {
      group = 'lsp_inlay_hint',
      buffer = buf,
      callback = function()
        vim.lsp.inlay_hint.enable(false, { bufnr = buf })
      end,
    })

    autocmd('InsertLeave', {
      group = 'lsp_inlay_hint',
      buffer = buf,
      callback = function()
        vim.lsp.inlay_hint.enable(true, { bufnr = buf })
      end,
    })
  end
end

function H.inlay_hint.disable(buf, state)
  if state.is_enabled then
    state.is_enabled = false
    vim.lsp.inlay_hint.enable(false, { bufnr = buf })
    vim.api.nvim_clear_autocmds({
      group = 'lsp_inlay_hint',
      buffer = buf,
    })
  end
end

function H.codelens.enable(buf, state)
  if not state.is_enabled then
    state.is_enabled = true

    vim.lsp.codelens.refresh({ bufnr = buf })

    autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
      group = 'lsp_codelens',
      buffer = buf,
      callback = function()
        vim.lsp.codelens.refresh({ bufnr = buf })
      end,
    })

    autocmd('InsertEnter', {
      group = 'lsp_codelens',
      buffer = buf,
      callback = function()
        vim.lsp.codelens.clear(nil, buf)
      end,
    })
  end
end

function H.codelens.disable(buf, state)
  if state.is_enabled then
    state.is_enabled = false
    vim.lsp.codelens.clear(nil, buf)

    vim.api.nvim_clear_autocmds({
      group = 'lsp_codelens',
      buffer = buf,
    })
  end
end
