return {
  {
    'echasnovski/mini.ai',
    opts = function()
      local ai = require('mini.ai')

      local opts = { n_lines = 500, custom_textobjects = {} }

      -- word with case
      opts.custom_textobjects.e = {
        { '%u[%l%d]+%f[^%l%d]', '%f[%S][%l%d]+%f[^%l%d]', '%f[%P][%l%d]+%f[^%l%d]', '^[%l%d]+%f[^%l%d]' },
        '^().*()$',
      }

      -- scope
      opts.custom_textobjects.o = ai.gen_spec.treesitter({
        a = { '@block.outer', '@conditional.outer', '@loop.outer' },
        i = { '@block.inner', '@conditional.inner', '@loop.inner' },
      })

      -- class
      opts.custom_textobjects.c = ai.gen_spec.treesitter({
        a = '@class.outer',
        i = '@class.inner',
      })

      -- function
      opts.custom_textobjects.f = ai.gen_spec.treesitter({
        a = '@function.outer',
        i = '@function.inner',
      })

      -- parameter
      opts.custom_textobjects.a = ai.gen_spec.treesitter({
        a = '@parameter.outer',
        i = '@parameter.inner',
      })

      -- tags
      opts.custom_textobjects.t = ai.gen_spec.treesitter({
        a = '@tag.outer',
        i = '@tag.inner',
      })

      -- extra
      local gen_ai_spec = require('mini.extra').gen_ai_spec

      opts.custom_textobjects.g = gen_ai_spec.buffer()
      opts.custom_textobjects.D = gen_ai_spec.diagnostic()
      opts.custom_textobjects.i = gen_ai_spec.indent()
      opts.custom_textobjects.d = gen_ai_spec.number()
      --

      return opts
    end,
  },
  { 'echasnovski/mini.align', config = true },
  { 'echasnovski/mini.splitjoin', config = true },
  { 'echasnovski/mini.surround', config = true },
  { 'echasnovski/mini.extra' },
}
