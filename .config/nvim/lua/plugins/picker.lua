local fzf = { 'ibhagwan/fzf-lua', keys = {} }
local namu = { 'bassamsdata/namu.nvim', opts = {} }

fzf.build = 'mkdir -p ' .. vim.fn.stdpath('data') .. '/fzf-lua/history/'
fzf.cmd = 'FzfLua'
fzf.opts = { 'default-title' }

function fzf.init()
  ---@diagnostic disable-next-line: duplicate-set-field
  function vim.ui.select(...)
    require('lazy').load({ plugins = { 'fzf-lua' } })
    -- what is being returned is a different ui.select
    -- that is registered after fzf-lua is loaded
    return vim.ui.select(...)
  end
end

function fzf.config(_, opts)
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

  require('fzf-lua').register_ui_select(function(fzf_opts, items)
    local extend_opts = {}

    if fzf_opts.kind == 'codeaction' then
      extend_opts.winopts = {
        layout = 'vertical',
        height = math.floor(math.min(vim.o.lines * vim.g.win_height - 16, #items + 2) + 0.5) + 16,
        preview = {
          layout = 'vertical',
          vertical = 'down:15,border-top',
        },
      }
    else
      extend_opts.winopts = {
        height = math.floor(math.min(vim.o.lines * vim.g.win_height, #items + 2) + 0.5),
      }
    end

    return vim.tbl_deep_extend('force', fzf_opts, {
      prompt = ' ',
      winopts = {
        width = 0.66,
        title = ' ' .. vim.trim((fzf_opts.prompt or 'Select'):gsub('%s*:%s*$', '')) .. ' ',
        title_pos = 'center',
      },
    }, extend_opts)
  end)
end

local opt = fzf.opts

opt.fzf_colors = true

opt.fzf_opts = {
  ['--cycle'] = true,
  ['--history'] = vim.fn.stdpath('data') .. '/fzf-lua/history/all',
  ['--keep-right'] = true,
  ['--no-scrollbar'] = true,
  ['--preview-border'] = 'none',
  ['--tabstop'] = 2,
}

opt.winopts = {
  backdrop = 100,
  border = 'single',
  col = 0.5,
  heigth = vim.g.win_heigth,
  row = 0.5,
  width = vim.g.win_width,
  preview = {
    border = 'single',
    delay = 50,
    horizontal = 'right:50%',
    vertical = 'down:50%',
    wrap = true,
  },
}

if vim.fn.executable('chafa') == 1 then
  opt.previwers = { builtin = {} }
  for _, ext in ipairs({ 'png', 'jpg', 'jpeg', 'gif', 'webp' }) do
    opt.previwers.builtin[ext] = { 'chafa', '{file}' }
  end
end

if vim.fn.executable('delta') == 1 then
  opt.lsp = { code_actions = { previewer = 'codeaction_native' } }
end

opt.defaults = {
  formatter = 'path.filename_first',
  header = false,
  hidden = false,
}

opt.files = {
  cwd_prompt = false,
  git_icons = true,
  fzf_opts = { ['--history'] = vim.fn.stdpath('data') .. '/fzf-lua/history/files' },
}

opt.grep = {
  fzf_opts = { ['--history'] = vim.fn.stdpath('data') .. '/fzf-lua/history/grep' },
  multiline = 1,
}

opt.buffers = {
  sort_lastused = true,
  sort_mru = true,
}

opt.manpage = {
  previewer = { 'man_native' },
}

opt.helptags = {
  previewer = { 'help_native' },
  fzf_opts = { ['--wrap'] = false },
}

opt.keymap = {
  builtin = { true },
  fzf = { true },
  winopts = {
    preview = { wrap = false },
  },
}

opt.keymap.builtin = {
  ['<c-f>'] = 'preview-page-down',
  ['<c-b>'] = 'preview-page-up',
}

opt.keymap.fzf = {
  ['ctrl-b'] = 'preview-page-up',
  ['ctrl-d'] = 'half-page-down',
  ['ctrl-f'] = 'preview-page-down',
  ['ctrl-g'] = 'toggle-all',
  ['ctrl-n'] = 'down',
  ['ctrl-p'] = 'up',
  ['ctrl-q'] = 'select-all+accept',
  ['ctrl-u'] = 'half-page-up',
  ['ctrl-x'] = 'jump',
  ['ctrl-y'] = 'accept',
}

local helpers = require('local.helpers')
local autocmd = helpers.autocmd
local augroup = helpers.augroup

local nmap = helpers.mapping({
  mode = 'n',
  key_list = fzf.keys,
  desc_prefix = 'FzfLua: ',
})
local xmap = helpers.mapping({
  mode = 'x',
  key_list = fzf.keys,
  desc_prefix = 'FzfLua: ',
})

-- stylua: ignore start

-- find
nmap('<leader>ff',     '<cmd>FzfLua files<cr>',     { desc = 'Files'        })
nmap('<leader>fg',     '<cmd>FzfLua git_files<cr>', { desc = 'Git Files'    })
nmap('<leader>fr',     '<cmd>FzfLua oldfiles<cr>',  { desc = 'Recent Files' })
nmap('<leader>fb',     '<cmd>FzfLua buffers<cr>',   { desc = 'Buffers'      })
nmap('<leader>f<tab>', '<cmd>FzfLua tabs<cr>',      { desc = 'Tabs'         })

-- search (grep or live grep)
xmap('<leader>s', '<cmd>FzfLua grep_visual<cr>', { desc = 'Search Visual Selection' })

nmap('<leader>sf', '<cmd>FzfLua live_grep<cr>',        { desc = 'Search Files'                })
nmap('<leader>sF', '<cmd>FzfLua grep<cr>',             { desc = 'Search Files (grep)'         })
nmap('<leader>sr', '<cmd>fzflua live_grep_resume<cr>', { desc = 'Search Files (resume)'       })
nmap('<leader>sR', '<cmd>FzfLua grep_last<cr>',        { desc = 'Search Files (grep resume)'  })
nmap('<leader>sw', '<cmd>FzfLua grep_cword<cr>',       { desc = 'Search Word Under Cursor'    })
nmap('<leader>sW', '<cmd>FzfLua grep_cWORD<cr>',       { desc = 'Search WORD Under Cursor'    })
nmap('<leader>sb', '<cmd>FzfLua lgrep_curbuf<cr>',     { desc = 'Search Buffer'               })
nmap('<leader>sB', '<cmd>fzflua grep_curbuf<cr>',      { desc = 'Search Buffer (grep)'        })
nmap('<leader>sq', '<cmd>fzflua lgrep_quickfix<cr>',   { desc = 'search Quickfix List'        })
nmap('<leader>sQ', '<cmd>fzflua grep_quickfix<cr>',    { desc = 'Search Quickfix List (grep)' })
nmap('<leader>sl', '<cmd>fzflua lgrep_loclist<cr>',    { desc = 'Search Location List'       })
nmap('<leader>sL', '<cmd>fzflua grep_loclist<cr>',     { desc = 'Search Location List (grep)' })


-- buffers
nmap({ '<leader>bl', '<leader>/' }, '<cmd>FzfLua blines<cr>',     { desc = 'Current Buffer Lines' })
nmap({ '<leader>bL', '<leader>?' }, '<cmd>FzfLua lines<cr>',      { desc = 'Buffers Lines'        })
nmap('<leader>st',                  '<cmd>FzfLua treesitter<cr>', { desc = 'Treesitter Symbols'   })

-- git
nmap('<leader>gs', '<cmd>FzfLua git_status<cr>',   { desc = 'Git Status'              })
nmap('<leader>gl', '<cmd>FzfLua git_bcommits<cr>', { desc = 'Git Commit Log (buffer)' })
nmap('<leader>gL', '<cmd>FzfLua git_commits<cr>',  { desc = 'Git Commit Log (root)'   })
nmap('<leader>gb', '<cmd>FzfLua git_blame<cr>',    { desc = 'Git Blame'               })
nmap('<leader>gr', '<cmd>FzfLua git_branches<cr>', { desc = 'Git Branches'            })
nmap('<leader>gt', '<cmd>FzfLua git_tags<cr>',     { desc = 'Git Tags'                })

-- misc
nmap('<leader>R',  '<cmd>FzfLua resume<cr>',          { desc = 'Resume'             })
nmap('<leader>:',  '<cmd>FzfLua command_history<cr>', { desc = 'Command History'    })
nmap('<leader>zq', '<cmd>FzfLua quickfix<cr>',        { desc = 'Quickfix List'      })
nmap('<leader>zQ', '<cmd>FzfLua quickfix_stack<cr>',  { desc = 'Quickfix Stack'     })
nmap('<leader>zl', '<cmd>FzfLua loclist<cr>',         { desc = 'Location List'      })
nmap('<leader>zL', '<cmd>FzfLua loclist_stack<cr>',   { desc = 'Location Stack'     })
nmap('<leader>zh', '<cmd>FzfLua helptags<cr>',        { desc = 'Help Tags'          })
nmap('<leader>zi', '<cmd>FzfLua highlights<cr>',      { desc = 'Highlights'         })
nmap('<leader>zp', '<cmd>FzfLua manpages<cr>',        { desc = 'Man Pages'          })
nmap('<leader>zc', '<cmd>FzfLua colorschemes<cr>',    { desc = 'Colorschemes'       })
nmap('<leader>zm', '<cmd>FzfLua marks<cr>',           { desc = 'Marks'              })
nmap('<leader>zj', '<cmd>FzfLua jumps<cr>',           { desc = 'Jumps'              })
nmap('<leader>zr', '<cmd>FzfLua registers<cr>',       { desc = 'Registers'          })
nmap('<leader>za', '<cmd>FzfLua autocmds<cr>',        { desc = 'Autocmds'           })
nmap('<leader>zk', '<cmd>FzfLua keymaps<cr>',         { desc = 'Autocmds'           })
nmap('<leader>zz', '<cmd>FzfLua zoxides<cr>',         { desc = 'Recent Directories' })

-- dap

-- lsp
autocmd('LspAttach', {
  group = augroup('fzflua_lsp_keymaps'),
  -- stylua: ignore
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then return end
    local map = helpers.mapping({ mode = 'n', desc_prefix = 'FzfLua (LSP): ', buffer = ev.buf })

    map({ 'gd',   '<leader>ld' }, '<cmd>FzfLua lsp_definitions<cr>',  { desc = 'Definitions'  })
    map({ 'gD',   '<leader>lD' }, '<cmd>FzfLua lsp_declarations<cr>', { desc = 'Declarations' })
    map({ '<f3>', '<leader>la' }, '<cmd>FzfLua lsp_code_actions<cr>', { desc = 'Code Actions' })

    map('<leader>li', '<cmd>FzfLua lsp_implementations<cr>',   { desc = 'Implementations'   })
    map('<leader>lr', '<cmd>FzfLua lsp_references<cr>',        { desc = 'References'        })
    map('<leader>ls', '<cmd>FzfLua lsp_document_symbols<cr>',  { desc = 'Document Symbols'  })
    map('<leader>lS', '<cmd>FzfLua lsp_workspace_symbols<cr>', { desc = 'Workspace Symbols' })
    map('<leader>lt', '<cmd>FzfLua lsp_typedefs<cr>',          { desc = 'Type Definitions'  })
  end
})
-- stylua: ignore end

return { fzf, namu }
