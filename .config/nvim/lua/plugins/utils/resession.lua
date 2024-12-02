return {
  'stevearc/resession.nvim',
  opts = {},
  config = function(_, opts)
    local resession = require('resession')
    local helpers = require('local.helpers')

    local map = helpers.map({ mode = 'n' })
    local autocmd = helpers.autocmd
    local augroup = helpers.augroup

    resession.setup(opts)

    local function session_load(name, _opts)
      resession.load(name, _opts)

      vim.iter(require('local.buffer').buf_list()):each(function(buf)
        require('editorconfig').config(buf)
      end)
    end

    map('<leader>ss', resession.save)
    map('<leader>sl', session_load)
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
          local ok, _ = pcall(session_load, 'last')

          if not ok then
            vim.notify("Could not load session 'last'", vim.log.levels.WARN, { title = 'Resession' })
          end
        end
      end,
    })
  end,
}
