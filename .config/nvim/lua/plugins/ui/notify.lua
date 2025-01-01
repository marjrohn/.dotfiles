local spec = { 'rcarriga/nvim-notify' }

spec.opts = {
  stages = 'fade',
  timeout = 4000,
  max_height = function()
    return math.floor(vim.o.lines * 0.75)
  end,
  max_width = function()
    return math.floor(vim.o.columns * 0.75)
  end,
  on_open = function(win)
    vim.api.nvim_win_set_config(win, { zindex = 100 })
  end,
}

function spec.config(_, opts)
  local notify = require('notify')
  local nmap = require('local.helpers').mapping({ mode = 'n' })

  notify.setup(opts)
  vim.notify = notify

  nmap('<leader>nn', '<cmd>Notifications<cr>', { desc = 'Show Notifications Log' })

  nmap('<leader>nd', function()
    notify.dismiss({ silent = true, pending = true })
  end, { desc = 'Dismiss All Notifications' })

  nmap('<leader>nh', function()
    notify.history()
  end, { desc = 'Show Past Notifications' })
end

return spec
