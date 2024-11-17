return {
  'stevearc/resession.nvim',
  opts = {
    autoload = {
      enabled = true,
      interval = 10,
      notify = false,
    },
  },
  config = function(_, opts)
    local resession = require('resession')
    local helpers = require('local.helpers')

    local map = helpers.map({ mode = 'n' })
    local autocmd = helpers.autocmd
    local augroup = helpers.augroup

    resession.setup(opts)

    map('<leader>ss', resession.save)
    map('<leader>sl', resession.load)
    map('<leader>sd', resession.delete)

    -- automatically save a session named "last" when exiting
    autocmd('VimLeavePre', {
      group = augroup('resession_save'),
      callback = function()
        resession.save('last')
      end,
    })

    autocmd('VimEnter', {
      group = augroup('resession_load'),
      callback = function()
        -- only load if nvim was started with no args
        if vim.fn.argc(-1) == 0 then
          local ok, _ = pcall(resession.load, 'last')

          if not ok then
            vim.notify("Could not load session 'last'", 'warn', {
              title = 'Resession',
            })
          end
        end
      end,
    })
  end,
}
