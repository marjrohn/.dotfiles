require('config.options')
require('config.keymaps')
require('config.autocmds')
require('config.lazy')

-- temp map to netrw until I setup Oil.nvim
vim.cmd('nnoremap <leader>e :Ex<cr>')
