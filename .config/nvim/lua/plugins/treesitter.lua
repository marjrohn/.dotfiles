local treesitter = {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  opts_extend = { 'ensure_installed' },
}

local treesitter_context = {
  'nvim-treesitter/nvim-treesitter-context',
  opts = {},
}

local textobjects = {}

treesitter.opts = {
  sync_install = true,
  auto_install = true,
  highlight = { enable = true },
  indent = { enable = true },
  -- stylua: ignore
  ensure_installed = {
    'bash', 'c', 'diff', 'html', 'json', 'lua', 'luadoc', 'luap', 'luau', 'markdown',
    'markdown_inline', 'printf', 'query', 'regex', 'toml', 'vim', 'vimdoc', 'yaml',
  },

  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = false,
      node_decremental = '<bs>',
    },
  },
  textobjects = textobjects,
}

textobjects.swap = {
  enable = true,
  swap_next = { ['<a-l>'] = '@parameter.inner' },
  swap_previous = { ['<a-h>'] = '@parameter.inner' },
}

textobjects.move = {
  enable = true,
  goto_next_start = {
    [']]'] = '@block.outer',
    [']c'] = '@comment.outer',
    [']a'] = '@parameter.inner',
    [']f'] = '@function.outer',
    [']m'] = '@class.outer',
  },
  goto_next_end = {
    [']['] = '@block.outer',
    [']C'] = '@comment.outer',
    [']F'] = '@function.outer',
    [']M'] = '@class.outer',
    [']A'] = '@parameter.inner',
  },
  goto_previous_start = {
    ['[['] = '@block.outer',
    ['[c'] = '@comment.outer',
    ['[f'] = '@function.outer',
    ['[m'] = '@class.outer',
    ['[a'] = '@parameter.inner',
  },
  goto_previous_end = {
    ['[]'] = '@block.outer',
    ['[C'] = '@comment.outer',
    ['[F'] = '@function.outer',
    ['[M'] = '@class.outer',
    ['[A'] = '@parameter.inner',
  },
}

function treesitter.config(_, opts)
  require('nvim-treesitter.configs').setup(opts)

  local map = require('local.helpers').mapping({ mode = { 'n', 'x', 'o' } })
  local ts_repeat_move = require('nvim-treesitter.textobjects.repeatable_move')

  -- repeat movement with ; and ,
  map(';', ts_repeat_move.repeat_last_move_next, { desc = 'Repeat last move forward' })
  map(',', ts_repeat_move.repeat_last_move_previous, { desc = 'Repeat last move backwards' })

  -- make builtin f, F, t, T also repeatable with ; and ,
  map('f', ts_repeat_move.builtin_f_expr, { expr = true })
  map('F', ts_repeat_move.builtin_F_expr, { expr = true })
  map('t', ts_repeat_move.builtin_t_expr, { expr = true })
  map('T', ts_repeat_move.builtin_T_expr, { expr = true })

  -- jumping to context (upwards)
  map('<leader>c', function()
    require('treesitter-context').go_to_context(vim.v.count1)
  end, { desc = 'Go to context' })
end

treesitter_context.opts = {
  max_lines = 3,
}

function treesitter_context.init()
  local autocmd = require('local.helpers').autocmd
  local augroup = require('local.helpers').augroup

  autocmd('ColorScheme', {
    group = augroup('treesitter_context_highlight'),
    callback = function()
      vim.defer_fn(function()
        vim.cmd.highlight('TreesitterContextBottom gui=underline guisp=' .. vim.g.ui_theme.normal)
        vim.cmd([[
          hi! link TreesitterContextLineNumber TreesitterContext
          hi! link TreesitterContextLineNumberBottom TreesitterContextBottom
        ]])
      end, 50)
    end,
  })
end

return {
  treesitter,
  treesitter_context,
  { 'nvim-treesitter/nvim-treesitter-textobjects' },
  { 'windwp/nvim-ts-autotag', config = true },
  { 'HiPhish/rainbow-delimiters.nvim' },
}
