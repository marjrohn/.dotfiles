local lint = {
  'mfussenegger/nvim-lint',
  event = { 'BufNewFile', 'BufReadPost', 'BufWritePre' },
  opts = {},
}

lint.opts.events = {
  'BufReadPost',
  'BufWritePost',
  'InsertLeave',
  'LspAttach',
  'TextChanged',
  'CursorHold',
}

lint.opts.linters_by_ft = {
  lua = { 'selene' },
  -- ['*'] = { 'cspell' }
}

lint.opts.linters = {
  -- Example of using selene only when a selene.toml file is present
  -- selene = {
  --   -- dynamically enable/disable linters based on the context.
  --   condition = function(ctx)
  --     return vim.fs.find({ "selene.toml" }, { path = ctx.filename, upward = true })[1]
  --   end,
  -- },
}

function lint.config(_, opts)
  local lint_ = require('lint')

  for name, linter in pairs(opts.linters or {}) do
    if type(linter) == 'table' and type(lint_.linters[name]) == 'table' then
      ---@diagnostic disable-next-line: param-type-mismatch
      lint_.linters[name] = vim.tbl_deep_extend('force', lint_.linters[name], linter)
      if type(linter.prepend_args) == 'table' then
        lint_.linters[name].args = lint_.linters[name].args or {}
        vim.list_extend(lint_.linters[name].args, linter.prepend_args)
      end
    else
      lint_.linters[name] = linter
    end
  end

  lint_.linters_by_ft = opts.linters_by_ft

  local function debounce(ms, fn)
    ---@diagnostic disable-next-line: undefined-field
    local timer = vim.uv.new_timer()

    return function(...)
      local argv = { ... }
      timer:start(ms, 0, function()
        timer:stop()
        vim.schedule_wrap(fn)(unpack(argv))
      end)
    end
  end

  local function try_lint(buf)
    if not vim.api.nvim_buf_is_valid(tonumber(buf) or -1) then
      return
    end

    -- Use nvim-lint's logic first:
    -- - checks if linters exist for the full filetype first
    -- - otherwise will split filetype by "." and add all those linters
    -- - this differs from conform.nvim which only uses the first filetype that has a formatter
    local names = lint_._resolve_linter_by_ft(vim.bo[buf].filetype)

    -- Create a copy of the names table to avoid modifying the original.
    names = vim.list_extend({}, names)

    -- Add fallback linters.
    if #names == 0 then
      vim.list_extend(names, lint_.linters_by_ft['_'] or {})
    end

    -- Add global linters.
    vim.list_extend(names, lint_.linters_by_ft['*'] or {})

    -- Filter out linters that don't exist or don't match the condition.
    local ctx = { filename = vim.api.nvim_buf_get_name(buf) }
    ctx.dirname = vim.fn.fnamemodify(ctx.filename, ':h')
    names = vim.tbl_filter(function(name)
      local linter = lint_.linters[name]

      if not linter then
        vim.notify(
          string.format('[nvim-lint] Linter not found: `%s`', vim.trim(name)),
          vim.log.levels.WARN
        )
      end

      return linter
        ---@diagnostic disable-next-line: undefined-field
        and not (type(linter) == 'table' and linter.condition and not linter.condition(ctx))
    end, names)

    -- Only run the linter in buffers that you can modify in order to avoid noise
    if #names > 0 then
      vim.b[buf].tried_diagnostics = true
      if not vim.bo[buf].readonly and vim.bo[buf].modifiable then
        lint_.try_lint(names)
      end
    end
  end

  vim.api.nvim_create_autocmd(opts.events, {
    group = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
    callback = debounce(300, function(ev)
      try_lint(ev.buf)
    end),
  })
end

return lint
