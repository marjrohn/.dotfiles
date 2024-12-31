local spec = {
  'ibhagwan/fzf-lua',
  cmd = 'FzfLua',
  opts = { 'default-title' },
}

spec.opts.defaults = {
  formatter = 'path.filename_first',
  no_header = true,
}

spec.opts.keymap = {
  fzf = {
    ['ctrl-q'] = 'select-all+accept',
  },
}

spec.opts.winopts = {
  width = 0.85,
  height = 0.85,
  row = 0.5,
  col = 0.5,
  backdrop = 100,
  treesitter = {
    enabled = true,
    fzf_colors = false,
  },
}

spec.opts.fzf_colors = true
spec.opts.fzf_opts = {
  ['--no-scrollbar'] = true,
}

spec.opts.grep = {
  rg_glob = true,
  glob_flag = '--iglob',
  glob_separator = '%s%s',
}

spec.opts.oldfiles = {
  include_current_session = true,
}

if vim.fn.executable('delta') == 1 then
  spec.opts.lsp = {
    code_actions = { previewer = 'codeaction_native' },
  }
end

if vim.fn.executable('chafa') == 1 then
  local img_preview = { 'chafa', '{file}', '--format=symbols' }

  spec.opts.previewers = {
    builtin = vim
      .iter({ 'png', 'jpg', 'jpeg', 'gif', 'webp' })
      :fold({}, function(tbl, ext)
        tbl[ext] = img_preview
        return tbl
      end),
  }
end

spec.opts.previewers.builtin.syntax_limit_b = 1024 * 100 -- 100Kib

spec.opts.ui_select = function(opts, items)
  local prompt = opts.prompt
  opts.prompt = ' '

  if opts.kind == 'codeaction' then
    opts.winopts = {
      layout = 'vertical',
      -- height is number of items minus 15 lines for the preview, with a max of 80% screen height
      height = math.floor(math.min(vim.o.lines * 0.8 - 16, #items + 2) + 0.5)
        + 16,
      width = 0.6,
      preview = {
        layout = 'vertical',
        vertical = 'down:15,border-top',
      },
    }
  else
    opts.winopts = {
      width = 0.6,
      -- height is number of items, with a max of 80% screen height
      height = math.floor(math.min(vim.o.lines * 0.8, #items + 2) + 0.5),
    }
  end

  opts.winopts.title = ' '
    .. vim.trim((prompt or 'Select'):gsub('%s*:%s*$', ''))
    .. ' '
  opts.winopts.title_pos = 'center'

  return opts
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

    opts = vim.tbl_deep_extend(
      'force',
      fix(require('fzf-lua.profiles.default-title')),
      opts
    )
    opts[1] = nil
  end

  require('fzf-lua').setup(opts)
end

local helpers = require('local.helpers')
local autocmd = helpers.autocmd
local augroup = helpers.augroup
local nmap = helpers.mapping({ mode = 'n' })
local xmap = helpers.mapping({ mode = 'x' })

-- stylua: ignore start

-- buffers and files
nmap({ '<leader><leader>', '<leader>fb' }, '<cmd>FzfLua buffers<cr>', { desc = 'Find Buffers' })

nmap('<leader>ff', '<cmd>FzfLua files<cr>',      { desc = 'Find Files'              })
nmap('<leader>fr', '<cmd>FzfLua oldfiles<cr>',   { desc = 'Find Recent Files'       })
nmap('<leader>fq', '<cmd>FzfLua quickfix<cr>',   { desc = 'Find Quickfix'           })
nmap('<leader>fl', '<cmd>FzfLua loclist<cr>',    { desc = 'Find Location'           })
nmap('<leader>fT', '<cmd>FzfLua treesitter<cr>', { desc = 'Find Treesitter Symbols' })

-- search
nmap('<leader>fg', '<cmd>FzfLua grep<cr>',             { desc = 'Search For Pattern'           })
nmap('<leader>fG', '<cmd>FzfLua grep_last<cr>',        { desc = 'Search For Pattern Again'     })
nmap('<leader>fw', '<cmd>FzfLua grep_cword<cr>',       { desc = 'Search For Word Under Cursor' })
nmap('<leader>fW', '<cmd>FzfLua grep_cWORD<cr>',       { desc = 'Search For WORD Under Cursor' })
xmap('<leader>fv', '<cmd>FzfLua grep_visual<cr>',      { desc = 'Search Visual Selection'      })
nmap('<leader>fQ', '<cmd>FzfLua lgrep_quickfix<cr>',   { desc = 'Find Quickfix (live grep)'    })
nmap('<leader>fL', '<cmd>FzfLua lgrep_loclist<cr>',    { desc = 'Find Location (live grep)'    })
nmap('<leader>/',  '<cmd>FzfLua live_grep<cr>',        { desc = 'Live Grep'                    })
nmap('<leader>=',  '<cmd>FzfLua live_grep_resume<cr>', { desc = 'Live Grep'                    })
nmap('<leader>b/', '<cmd>FzfLua lgrep_curbuf<cr>',     { desc = 'Live Grep Current Buffer'     })

-- tags
nmap('<leader>ftt', '<cmd>FzfLua tags<cr>',            { desc = 'Find Tags'                    })
nmap('<leader>ftb', '<cmd>FzfLua btags<cr>',           { desc = 'Find Tags (current buffer)'   })
nmap('<leader>ftw', '<cmd>FzfLua tags_grep_cword<cr>', { desc = 'Find Tags Word Under Cursor'  })
nmap('<leader>ftW', '<cmd>FzfLua tags_grep_cword<cr>', { desc = 'Find Tags WORD Under Cursor'  })
xmap('<leader>ftv', '<cmd>FzfLua tags_grep_visual',    { desc = 'Find Tags (visual selection)' })
nmap('<leader>ftg', '<cmd>FzfLua tags_live_grep<cr>',  { desc = 'Find Tags (live grep)'        })

-- git
nmap('<leader>gf', '<cmd>FzfLua git_files<cr>',    { desc = 'Git Files'            })
nmap('<leader>gs', '<cmd>FzfLua git_status<cr>',   { desc = 'Git Status'           })
nmap('<leader>gC', '<cmd>FzfLua git_commits<cr>',  { desc = 'Git Commits'          })
nmap('<leader>gc', '<cmd>FzfLua git_bcommits<cr>', { desc = 'Git Commits (buffer)' })
nmap('<leader>gb', '<cmd>FzfLua git_blame<cr>',    { desc = 'Git Blame'            })
nmap('<leader>gB', '<cmd>FzfLua git_branches<cr>', { desc = 'Git Branches'         })
nmap('<leader>gt', '<cmd>FzfLua git_tags<cr>',     { desc = 'Git Tags'             })
nmap('<leader>gh', '<cmd>FzfLua git_stash<cr>',    { desc = 'Git Stash'            })

-- misc
nmap('<leader>tr',     '<cmd>FzfLua resume<cr>',          { desc = 'Resume FzfLua'     })
nmap('<leader>fH',     '<cmd>FzfLua helptags<cr>',        { desc = 'Find Help Tags'    })
nmap('<leader>fM',     '<cmd>FzfLua manpages<cr>',        { desc = 'Find Man Pages'    })
nmap('<leader>fC',     '<cmd>FzfLua colorschemes<cr>',    { desc = 'Find Colorschemes' })
nmap('<leader>fh',     '<cmd>FzfLua highlights<cr>',      { desc = 'Find Highlights'   })
nmap('<leader>fc',     '<cmd>FzfLua commands<cr>',        { desc = 'Find Commands'     })
nmap('<leader>:',      '<cmd>FzfLua command_history<cr>', { desc = 'Command History'   })
nmap('<leader>?',      '<cmd>FzfLua search_history<cr>',  { desc = 'Search History'    })
nmap('<leader>fm',     '<cmd>FzfLua marks<cr>',           { desc = 'Find Marks'        })
nmap('<leader>fj',     '<cmd>FzfLua jumps<cr>',           { desc = 'Find Jumps'        })
nmap('<leader>f<c-r>', '<cmd>FzfLua registers<cr>',       { desc = 'Find Registers'    })
nmap('<leader>fa',     '<cmd>FzfLua autocmds<cr>',        { desc = 'Find Autocmds'     })
nmap('<leader>fk',     '<cmd>FzfLua keymaps<cr>',         { desc = 'Find Keymaps'      })

-- stylua ignore end

-- lsp
local function lsp_attach(event)
  nmap = helpers.mapping({ mode = 'n', buffer = event.buf })

  -- stylua: ignore start
  nmap('<leader>lrr', '<cmd>FzfLua lsp_references<cr>',             { desc = 'LSP References'                    })
  nmap('<leader>lld', '<cmd>FzfLua lsp_definitions<cr>',            { desc = 'LSP Definitions'                   })
  nmap('<leaderllD',  '<cmd>FzfLua lsp_declarations<cr>',           { desc = 'LSP Declarations'                  })
  nmap('<leader>lt',  '<cmd>FzfLua lsp_typedefs<cr>',               { desc = 'LSP Type Definitions'              })
  nmap('<leader>li',  '<cmd>FzfLua lsp_implementations<cr>',        { desc = 'LSP Implementations'               })
  nmap('<leader>lds', '<cmd>FzfLua lsp_document_symbols<cr>',       { desc = 'LSP Document Symbols'              })
  nmap('<leader>lwS', '<cmd>FzfLua lsp_workspace_symbols<cr>',      { desc = 'LSP Workspace Symbols'             })
  nmap('<leader>lws', '<cmd>FzfLua lsp_live_workspace_symbols<cr>', { desc = 'LSP Workspace Symbols (live grep)' })
  nmap('<leader>lci', '<cmd>FzfLua lsp_incoming_calls<cr>',         { desc = 'LSP Incoming Calls'                })
  nmap('<leader>lco', '<cmd>FzfLua lsp_outgoing_calls<cr>',         { desc = 'LSP Outgoing Calls'                })
  nmap('<leader>ldd', '<cmd>FzfLua lsp_document_diagnostics<cr>',   { desc = 'LSP Document Diagnostics'          })
  nmap('<leader>ldd', '<cmd>FzfLua lsp_workspace_diagnostics<cr>',  { desc = 'LSP Workspace Diagnostics'         })
  -- stylua: ignore end
end

autocmd('LspAttach', {
  group = augroup('lsp_attach_fzflua'),
  callback = lsp_attach,
})

return spec
