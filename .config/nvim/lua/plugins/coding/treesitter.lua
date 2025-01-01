local treesitter = {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  opts_extend = { 'ensure_installed' },
  opts = {},
}

local spec = {
  { 'nvim-treesitter/nvim-treesitter-textobjects', dependencies = treesitter },
  { 'windwp/nvim-ts-autotag', config = true },
  { 'HiPhish/rainbow-delimiters.nvim' },
}

treesitter.opts = {
  sync_install = true,
  auto_install = true,
  highlight = { enable = true },
  indent = { enable = true },
  textobjects = {},
}

treesitter.opts.ensure_installed = {
  'vim',
  'vimdoc',
  'bash',
  'c',
  'diff',
  'printf',
  'query',
  'regex',
  'markdown',
  'markdown_inline',
  'json',
  'toml',
  'html',
}

treesitter.opts.incremental_selection = {
  enable = true,
  keymaps = {
    init_selection = '<c-space>',
    node_incremental = '<c-space>',
    scope_incremental = false,
    node_decremental = '<bs>',
  },
}

local textobjects = treesitter.opts.textobjects

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
  map(';', ts_repeat_move.repeat_last_move, { desc = 'Repeat last move' })
  map(
    ',',
    ts_repeat_move.repeat_last_move_opposite,
    { desc = 'Repeat last move opposite' }
  )

  -- make builtin f, F, t, T also repeatable with ; and ,
  map('f', ts_repeat_move.builtin_f_expr, { expr = true })
  map('F', ts_repeat_move.builtin_F_expr, { expr = true })
  map('t', ts_repeat_move.builtin_t_expr, { expr = true })
  map('T', ts_repeat_move.builtin_T_expr, { expr = true })
end

return spec
