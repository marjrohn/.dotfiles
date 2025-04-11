local M = {
  vim = '',
  neovim = '',
}

M.clock = ''
M.directory = ''
M.dots = ''
M.close = ''

M.file = {
  modified_active = '󱇧',
  modified_inactive = '󱇨',
}

M.git = {
  logo = '',
  branch = '',
  commit = '',
  merge = '',
  compare = '',
}

M.git.diff = {
  added = '',
  ignored = '',
  modified = '',
  removed = '',
  renamed = '',
}

M.diagnostics = {
  error = '',
  warn = '',
  info = '',
  hint = '',
}

M.win = {
  border = { '🭽', '▔', '🭾', '▕', '🭿', '▁', '🭼', '▏' },
}

M.tab = {
  head = ' 󰓩 ',
  active = '',
  inactive = '',
}

return M
