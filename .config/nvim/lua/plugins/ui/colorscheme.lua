local mini = {
  base16 = { 'echasnovski/mini.base16' },
  icons = { 'echasnovski/mini.icons' },
}

mini.base16.priority = 1000
mini.base16.dependencies = mini.icons[1]
function mini.base16.config()
  vim.cmd.colorscheme('ghostty')
  require('mini.icons').mock_nvim_web_devicons()
end

mini.icons.opts = {}

return vim.tbl_values(mini)
