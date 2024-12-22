local mini = {}

for _, name in ipairs({
  'ai',
  'align',
  'bracketed',
  'splitjoin',
  'surround',
  'extra',
}) do
  mini[name] = { 'echasnovski/mini.' .. name }
end

mini.ai.opts = function()
  local ai = require('mini.ai')

  local textobjects = {}

  -- word with case
  textobjects.e = {
    {
      '%u[%l%d]+%f[^%l%d]',
      '%f[%S][%l%d]+%f[^%l%d]',
      '%f[%P][%l%d]+%f[^%l%d]',
      '^[%l%d]+%f[^%l%d]',
    },
    '^().*()$',
  }

  -- scope
  textobjects.o = ai.gen_spec.treesitter({
    a = { '@block.outer', '@conditional.outer', '@loop.outer' },
    i = { '@block.inner', '@conditional.inner', '@loop.inner' },
  })

  -- class
  textobjects.c = ai.gen_spec.treesitter({
    a = '@class.outer',
    i = '@class.inner',
  })

  -- function
  textobjects.f = ai.gen_spec.treesitter({
    a = '@function.outer',
    i = '@function.inner',
  })

  -- parameter
  textobjects.a = ai.gen_spec.treesitter({
    a = '@parameter.outer',
    i = '@parameter.inner',
  })

  -- tags
  textobjects.t = ai.gen_spec.treesitter({
    a = '@tag.outer',
    i = '@tag.inner',
  })

  -- extra
  local gen_ai_spec = require('mini.extra').gen_ai_spec

  textobjects.g = gen_ai_spec.buffer()
  textobjects.D = gen_ai_spec.diagnostic()
  textobjects.i = gen_ai_spec.indent()
  textobjects.d = gen_ai_spec.number()
  --

  return {
    n_lines = 500,
    custom_textobjects = textobjects,
  }
end

mini.align.config = true

mini.bracketed.opts = {
  comment = { suffix = '' },
  file = { suffix = '' },
  treesitter = { suffix = '' },
}

mini.splitjoin.config = true
mini.surround.config = true

local specs = vim.tbl_values(mini)

return specs
