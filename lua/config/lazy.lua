-- Bootstrap lazy.nvim

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

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

-- mappings
local nmap = require('local.helpers').map({ mode = 'n' })

-- stylua: ignore start
nmap('<leader><cr><cr>', ':Lazy<cr>',         { desc = 'Lazy'    })
nmap('<leader><cr>i',    ':Lazy install<cr>', { desc = 'Install' })
nmap('<leader><cr>u',    ':Lazy update<cr>',  { desc = 'Update'  })
nmap('<leader><cr>s',    ':Lazy sync<cr>',    { desc = 'Sync'    })
nmap('<leader><cr>x',    ':Lazy clean<cr>',   { desc = 'Clean'   })
nmap('<leader><cr>c',    ':Lazy check<cr>',   { desc = 'Check'   })
nmap('<leader><cr>l',    ':Lazy log<cr>',     { desc = 'Log'     })
nmap('<leader><cr>r',    ':Lazy restore<cr>', { desc = 'Restore' })
nmap('<leader><cr>p',    ':Lazy profile<cr>', { desc = 'Profile' })
nmap('<leader><cr>b',    ':Lazy debug<cr>',   { desc = 'Debug'   })
nmap('<leader><cr>h',    ':Lazy help<cr>',    { desc = 'Help'    })
-- stylua: ignore end

-- load plugins
require('lazy').setup({
  spec = {
    { import = 'plugins.coding' },
    { import = 'plugins.editor' },
    { import = 'plugins.lang' },
    { import = 'plugins.lang-tools' },
    { import = 'plugins.treesitter' },
    { import = 'plugins.ui' },
    { import = 'plugins.util' },
  },
})
