local mini = {}

for _, name in ipairs({
  'ai',
  'align',
  'icons',
  'notify',
  'operators',
  'pairs',
  'splitjoin',
  'surround',
  'extra',
}) do
  mini[name] = { 'echasnovski/mini.' .. name }
  mini[name].opts = name ~= 'extra' and {} or nil
end

mini.ai.opts = function(_, opts)
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

  return vim.tbl_deep_extend('force', opts or {}, {
    n_lines = 500,
    custom_textobjects = textobjects,
  })
end

mini.icons.priority = 900
mini.icons.lazy = false
function mini.icons.config(_, opts)
  require('mini.icons').setup(opts)
  MiniIcons.mock_nvim_web_devicons()
end

mini.notify.opts = {
  lsp_progress = { enable = false },
  window = { winblend = 0 },
}

function mini.notify.config(_, opts)
  require('mini.notify').setup(opts)
  vim.notify = MiniNotify.make_notify()

  local autocmd = require('local.helpers').autocmd
  local augroup = require('local.helpers').augroup
  local map = require('local.helpers').mapping({ mode = 'n', desc = 'Notification History' })

  autocmd({ 'UiEnter', 'ColorScheme' }, {
    group = augroup('mini-notify-highlights'),
    callback = function()
      vim.cmd('hi! link MiniNotifyNormal Normal')
      vim.cmd('hi MiniNotifyBorder guibg=none guifg=' .. vim.g.terminal_color_6)
      vim.cmd('hi MiniNotifyTitle gui=bold,italic guibg=none guifg=' .. vim.g.terminal_color_14)
    end,
  })

  map('<leader>n', function()
    vim.cmd.tabnew()
    MiniNotify.show_history()
  end)
end

mini.operators.opts = {
  -- Evaluate text and replace with output
  evaluate = {
    prefix = 's=',
  },
  -- Exchange text regions
  exchange = {
    prefix = 'se',
  },
  -- Multiply (duplicate) text
  multiply = {
    prefix = 'sm',
  },
  -- Replace text with register
  replace = {
    prefix = 'S',
  },
  -- Sort text
  sort = {
    prefix = 'so',
  },
}

mini.pairs.opts = {
  modes = { insert = true, command = false, terminal = false },

  mappings = {
    ['('] = { action = 'open', pair = '()', neigh_pattern = '.[%s%z%)]' },
    [')'] = { action = 'close', pair = '()', neigh_pattern = '[^\\].' },

    ['['] = { action = 'open', pair = '[]', neigh_pattern = '.[%s%z%)}%]]' },
    [']'] = { action = 'close', pair = '[]', neigh_pattern = '[^\\].' },

    ['{'] = { action = 'open', pair = '{}', neigh_pattern = '.[%s%z%)}%]]' },
    ['}'] = { action = 'close', pair = '{}', neigh_pattern = '[^\\].' },

    -- Single quote: Prevent pairing if either side is a letter
    ['"'] = {
      action = 'closeopen',
      pair = '""',
      neigh_pattern = '[^%w\\][^%w]',
      register = { cr = false },
    },
    ["'"] = {
      action = 'closeopen',
      pair = "''",
      neigh_pattern = '[^%w\\][^%w]',
      register = { cr = false },
    },
    ['`'] = {
      action = 'closeopen',
      pair = '``',
      neigh_pattern = '[^%w\\][^%w]',
      register = { cr = false },
    },
  },
  -- skip autopair when next character is one of these
  skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
  -- skip autopair when the cursor is inside these treesitter nodes
  skip_ts = { 'string' },
  -- skip autopair when next character is closing pair
  -- and there are more closing pairs than opening pairs
  skip_unbalanced = true,
  -- better deal with markdown code blocks
  markdown = true,
}

-- Override mini-pairs open function. Taken from Lazyvim
function mini.pairs.config(_, opts)
  local pairs = require('mini.pairs')
  pairs.setup(opts)
  local og_open = pairs.open

  ---@diagnostic disable-next-line: duplicate-set-field
  pairs.open = function(pair, neigh_pattern)
    if vim.fn.getcmdline() ~= '' then
      return og_open(pair, neigh_pattern)
    end

    local o, c = pair:sub(1, 1), pair:sub(2, 2)
    local line = vim.api.nvim_get_current_line()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local next = line:sub(cursor[2] + 1, cursor[2] + 1)
    local before = line:sub(1, cursor[2])

    if opts.markdown and o == '`' and vim.bo.filetype == 'markdown' and before:match('^%s*``') then
      return '`\n```' .. vim.api.nvim_replace_termcodes('<up>', true, true, true)
    end

    if opts.skip_next and next ~= '' and next:match(opts.skip_next) then
      return o
    end

    if opts.skip_ts and #opts.skip_ts > 0 then
      local ok, captures =
        pcall(vim.treesitter.get_captures_at_pos, 0, cursor[1] - 1, math.max(cursor[2] - 1, 0))
      for _, capture in ipairs(ok and captures or {}) do
        if vim.tbl_contains(opts.skip_ts, capture.capture) then
          return o
        end
      end
    end

    if opts.skip_unbalanced and next == c and c ~= o then
      local _, count_open = line:gsub(vim.pesc(pair:sub(1, 1)), '')
      local _, count_close = line:gsub(vim.pesc(pair:sub(2, 2)), '')
      if count_close > count_open then
        return o
      end
    end

    return og_open(pair, neigh_pattern)
  end
end

mini.surround.opts = {
  search_method = 'cover_or_next',
}
return vim.tbl_values(mini)
