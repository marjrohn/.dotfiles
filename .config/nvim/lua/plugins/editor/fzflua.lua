local spec = {
  'ibhagwan/fzf-lua',
  cmd = 'FzfLua',
}

function spec.opts(_, opts)
  local config = require('fzf-lua.config')
  local actions = require('fzf-lua.actions')

  -- Quickfix
  config.defaults.keymap.fzf['ctrl-q'] = 'select-all+accept'
  config.defaults.keymap.fzf['ctrl-u'] = 'half-page-up'
  config.defaults.keymap.fzf['ctrl-d'] = 'half-page-down'
  config.defaults.keymap.fzf['ctrl-x'] = 'jump'
  config.defaults.keymap.fzf['ctrl-f'] = 'preview-page-down'
  config.defaults.keymap.fzf['ctrl-b'] = 'preview-page-up'
  config.defaults.keymap.builtin['<c-f>'] = 'preview-page-down'
  config.defaults.keymap.builtin['<c-b>'] = 'preview-page-up'

  local img_previewer = { 'chafa', '{file}', '--format=symbols' }

  return vim.tbl_deep_extend('force', {
    'default-title',
    fzf_colors = true,
    fzf_opts = {
      ['--no-scrollbar'] = true,
    },
    defaults = {
      formatter = 'path.dirname_first',
    },
    previewers = {
      builtin = {
        extensions = {
          ['png'] = img_previewer,
          ['jpg'] = img_previewer,
          ['jpeg'] = img_previewer,
          ['gif'] = img_previewer,
          ['webp'] = img_previewer,
        },
      },
    },
    -- custom option for vim.ui.select
    ui_select = function(fzf_opts, items)
      return vim.tbl_deep_extend('force', fzf_opts, {
        prompt = ' ',
        winopts = {
          title = ' ' .. vim.trim((fzf_opts.prompt or 'Select'):gsub('%s*:%s*$', '')) .. ' ',
          title_pos = 'center',
        },
      }, fzf_opts.kind == 'codeaction' and {
        winopts = {
          layout = 'vertical',
          -- height is number of items minus 15 lines for the preview, with a max of 85% screen height
          height = math.floor(math.min(vim.o.lines * 0.85 - 16, #items + 2) + 0.5) + 16,
          width = 0.55,
          preview = {
            layout = 'vertical',
            vertical = 'down:15,border-top',
          },
        },
      } or {
        winopts = {
          width = 0.55,
          -- height is number of items, with a max of 85% screen height
          height = math.floor(math.min(vim.o.lines * 0.85, #items + 2) + 0.5),
        },
      })
    end,
    winopts = {
      width = 0.85,
      height = 0.85,
      row = 0.5,
      col = 0.5,
      backdrop = 100,
      treesitter = {
        enabled = true,
        fzf_colors = false,
      },
    },
    files = {
      cwd_prompt = false,
      actions = {
        ['alt-i'] = { actions.toggle_ignore },
        ['alt-h'] = { actions.toggle_hidden },
      },
    },
    grep = {
      actions = {
        ['alt-i'] = { actions.toggle_ignore },
        ['alt-h'] = { actions.toggle_hidden },
      },
    },
    lsp = {
      code_actions = {
        previewer = vim.fn.executable('delta') == 1 and 'codeaction_native' or nil,
      },
    },
  }, opts or {})
end

function spec.config(_, opts)
  require('fzf-lua').register_ui_select(opts.ui_select or nil)
  opts.ui_select = nil

  if opts[1] == 'default-title' then
    -- use the same prompt for all pickers for profile `default-title` and
    -- profiles that use `default-title` as base profile
    local function fix(t)
      t.prompt = t.prompt ~= nil and ' ' or nil
      for _, v in pairs(t) do
        if type(v) == 'table' then
          fix(v)
        end
      end
      return t
    end
    opts = vim.tbl_deep_extend('force', fix(require('fzf-lua.profiles.default-title')), opts)
    opts[1] = nil
  end

  require('fzf-lua').setup(opts)
end

local helpers = require('local.helpers')
local autocmd = helpers.autocmd
local augroup = helpers.augroup
local nmap = helpers.mapping({ mode = 'n' })
local xmap = helpers.mapping({ mode = 'x' })

-- buffers and files
nmap({ '<leader><leader>', '<leader>fb' }, '<cmd>FzfLua buffers<cr>', { desc = 'Find Buffers' })
nmap('<leader>ff', '<cmd>FzfLua files<cr>', { desc = 'Find Files' })
nmap('<leader>fr', '<cmd>FzfLua oldfiles<cr>', { desc = 'Find Recent Files' })
nmap('<leader>fq', '<cmd>FzfLua quickfix<cr>', { desc = 'Find Quickfix' })
nmap('<leader>fl', '<cmd>FzfLua loclist<cr>', { desc = 'Find Location' })
nmap('<leader>fT', '<cmd>FzfLua treesitter<cr>', { desc = 'Find Treesitter Symbols' })

-- search
nmap('<leader>fg', '<cmd>FzfLua grep<cr>', { desc = 'Search For Pattern' })
nmap('<leader>fG', '<cmd>FzfLua grep_last<cr>', { desc = 'Search For Pattern Again' })
nmap('<leader>fw', '<cmd>FzfLua grep_cword<cr>', { desc = 'Search For Word Under Cursor' })
nmap('<leader>fW', '<cmd>FzfLua grep_cWORD<cr>', { desc = 'Search For WORD Under Cursor' })
xmap('<leader>fv', '<cmd>FzfLua grep_visual<cr>', { desc = 'Search Visual Selection' })
nmap('<leader>fQ', '<cmd>FzfLua lgrep_quickfix<cr>', { desc = 'Find Quickfix (live grep)' })
nmap('<leader>fL', '<cmd>FzfLua lgrep_loclist<cr>', { desc = 'Find Location (live grep)' })
nmap('<leader>/', '<cmd>FzfLua live_grep<cr>', { desc = 'Live Grep' })
nmap('<leader>=', '<cmd>FzfLua live_grep_resume<cr>', { desc = 'Live Grep' })
nmap('<leader>b/', '<cmd>FzfLua lgrep_curbuf<cr>', { desc = 'Live Grep Current Buffer' })

-- tags
nmap('<leader>ftt', '<cmd>FzfLua tags<cr>', { desc = 'Find Tags' })
nmap('<leader>ftb', '<cmd>FzfLua btags<cr>', { desc = 'Find Tags (current buffer)' })
nmap('<leader>ftw', '<cmd>FzfLua tags_grep_cword<cr>', { desc = 'Find Tags Word Under Cursor' })
nmap('<leader>ftW', '<cmd>FzfLua tags_grep_cword<cr>', { desc = 'Find Tags WORD Under Cursor' })
xmap('<leader>ftv', '<cmd>FzfLua tags_grep_visual', { desc = 'Find Tags (visual selection)' })
nmap('<leader>ftg', '<cmd>FzfLua tags_live_grep<cr>', { desc = 'Find Tags (live grep)' })

-- git
nmap('<leader>gf', '<cmd>FzfLua git_files<cr>', { desc = 'Git Files' })
nmap('<leader>gs', '<cmd>FzfLua git_status<cr>', { desc = 'Git Status' })
nmap('<leader>gC', '<cmd>FzfLua git_commits<cr>', { desc = 'Git Commits' })
nmap('<leader>gc', '<cmd>FzfLua git_bcommits<cr>', { desc = 'Git Commits (buffer)' })
nmap('<leader>gb', '<cmd>FzfLua git_blame<cr>', { desc = 'Git Blame' })
nmap('<leader>gB', '<cmd>FzfLua git_branches<cr>', { desc = 'Git Branches' })
nmap('<leader>gt', '<cmd>FzfLua git_tags<cr>', { desc = 'Git Tags' })
nmap('<leader>gh', '<cmd>FzfLua git_stash<cr>', { desc = 'Git Stash' })

-- misc
nmap('<leader>tr', '<cmd>FzfLua resume<cr>', { desc = 'Resume FzfLua' })
nmap('<leader>fH', '<cmd>FzfLua helptags<cr>', { desc = 'Find Help Tags' })
nmap('<leader>fM', '<cmd>FzfLua manpages<cr>', { desc = 'Find Man Pages' })
nmap('<leader>fC', '<cmd>FzfLua colorschemes<cr>', { desc = 'Find Colorschemes' })
nmap('<leader>fh', '<cmd>FzfLua highlights<cr>', { desc = 'Find Highlights' })
nmap('<leader>fc', '<cmd>FzfLua commands<cr>', { desc = 'Find Commands' })
nmap('<leader>:', '<cmd>FzfLua command_history<cr>', { desc = 'Command History' })
nmap('<leader>?', '<cmd>FzfLua search_history<cr>', { desc = 'Search History' })
nmap('<leader>fm', '<cmd>FzfLua marks<cr>', { desc = 'Find Marks' })
nmap('<leader>fj', '<cmd>FzfLua jumps<cr>', { desc = 'Find Jumps' })
nmap('<leader>f<c-r>', '<cmd>FzfLua registers<cr>', { desc = 'Find Registers' })
nmap('<leader>fa', '<cmd>FzfLua autocmds<cr>', { desc = 'Find Autocmds' })
nmap('<leader>fk', '<cmd>FzfLua keymaps<cr>', { desc = 'Find Keymaps' })

-- lsp
autocmd('LspAttach', {
  group = augroup('lsp_attach_fzflua'),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if not client then
      return
    end

    nmap = helpers.mapping({ mode = 'n', buffer = event.buf })

    if client.supports_method(vim.lsp.protocol.Methods.textDocument_references) then
      nmap('<leader>lrr', '<cmd>FzfLua lsp_references<cr>', { desc = 'LSP References ' })
    end

    if client.supports_method(vim.lsp.protocol.Methods.textDocument_definition) then
      nmap('<leader>lld', '<cmd>FzfLua lsp_definitions<cr>', { desc = 'LSP Definitions' })
    end

    if client.supports_method(vim.lsp.protocol.Methods.textDocument_declaration) then
      nmap('<leader>llD', '<cmd>FzfLua lsp_declarations<cr>', { desc = 'LSP Declarations' })
    end

    if client.supports_method(vim.lsp.protocol.Methods.textDocument_typeDefinition) then
      nmap('<leader>lt', '<cmd>FzfLua lsp_typedefs<cr>', { desc = 'LSP Type Definitions' })
    end

    if client.supports_method(vim.lsp.protocol.Methods.textDocument_implementation) then
      nmap('<leader>li', '<cmd>FzfLua lsp_implementations<cr>', { desc = 'LSP Implementations' })
    end

    if client.supports_method(vim.lsp.protocol.Methods.textDocument_documentSymbol) then
      nmap('<leader>lds', '<cmd>FzfLua lsp_document_symbols<cr>', { desc = 'LSP Document Symbols' })
    end

    if client.supports_method(vim.lsp.protocol.Methods.workspace_symbol) then
      nmap('<leader>lwS', '<cmd>FzfLua lsp_workspace_symbols<cr>', { desc = 'LSP Workspace Symbols' })
      nmap('<leader>lws', '<cmd>FzfLua lsp_live_workspace_symbols<cr>', { desc = 'LSP Workspace Symbols (live grep)' })
    end

    if client.supports_method(vim.lsp.protocol.Methods.callHierarchy_incomingCalls) then
      nmap('<leader>lci', '<cmd>FzfLua lsp_incoming_calls<cr>', { desc = 'LSP Incoming Calls' })
    end

    if client.supports_method(vim.lsp.protocol.Methods.callhierarchy_outgoingcalls) then
      nmap('<leader>lco', '<cmd>FzfLua lsp_outgoing_calls<cr>', { desc = 'LSP Outgoing Calls' })
    end

    if client.supports_method(vim.lsp.protocol.Methods.textDocument_diagnostic) then
      nmap('<leader>ldd', '<cmd>FzfLua lsp_document_diagnostics<cr>', { desc = 'lsp Document Diagnostics' })
    end

    if client.supports_method(vim.lsp.protocol.Methods.workspace_diagnostic) then
      nmap('<leader>ldd', '<cmd>FzfLua lsp_workspace_diagnostics<cr>', { desc = 'lsp Workspace Diagnostics' })
    end
  end,
})

return spec
