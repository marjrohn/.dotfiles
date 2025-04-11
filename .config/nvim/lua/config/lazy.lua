-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

---@diagnostic disable-next-line: undefined-field
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'

  local out = vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    lazyrepo,
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

-- keymaps
local nmap = require('local.helpers').mapping({ mode = 'n', desc_prefix = 'Lazy: ' })

-- stylua: ignore start
nmap('<leader><cr><cr>', '<cmd>Lazy<cr>',         { desc = 'Plugins' })
nmap('<leader><cr>i',    '<cmd>Lazy install<cr>', { desc = 'Install' })
nmap('<leader><cr>u',    '<cmd>Lazy update<cr>',  { desc = 'Update'  })
nmap('<leader><cr>s',    '<cmd>Lazy sync<cr>',    { desc = 'Sync'    })
nmap('<leader><cr>x',    '<cmd>Lazy clean<cr>',   { desc = 'Clean'   })
nmap('<leader><cr>c',    '<cmd>Lazy check<cr>',   { desc = 'Check'   })
nmap('<leader><cr>l',    '<cmd>Lazy log<cr>',     { desc = 'Log'     })
nmap('<leader><cr>r',    '<cmd>Lazy restore<cr>', { desc = 'Restore' })
nmap('<leader><cr>p',    '<cmd>Lazy profile<cr>', { desc = 'Profile' })
nmap('<leader><cr>b',    '<cmd>Lazy debug<cr>',   { desc = 'Debug'   })
nmap('<leader><cr>h',    '<cmd>Lazy help<cr>',    { desc = 'Help'    })
-- stylua: ignore end

-- load plugins
require('lazy').setup({
  spec = {
    -- { import = 'plugins.lang.tools' },
    -- { import = 'plugins.lang' },
    { import = 'plugins' },
  },
  ui = {
    size = { width = vim.g.win_width, height = vim.g.win_height },
    border = require('config.icons').win.border,
    title = ' Lazy ',
  },
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip',
        'matchit',
        'matchparen',
        'netrwPlugin',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
})
