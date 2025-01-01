local M = {}

---@alias _lines.register string?
---@alias _lines.n 0 | 1
---@alias _lines.type 'y' | 'd' | 'c'

---@param register _lines.register
---@param linewise boolean
---@param type _lines.type
local function yank_helper(register, linewise, type)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local first = cursor[1] - 1
  local last = first + vim.v.count1
  local lines = vim.api.nvim_buf_get_lines(0, first, last, false)

  register = register or vim.v.register
  local pattern = type == 'y' and '^$' or '^%s*$'

  local count = vim.v.count - 1
  local length = 1
  local cmd = ''

  if
    vim.iter(lines):all(function(line)
      length = math.max(length, line:len())
      return line:match(pattern) and true or false
    end)
  then
    register = '_'
  end

  length = length - cursor[2] - 1

  if count >= 1 then
    cmd = cmd .. count .. 'j'
  end

  cmd = cmd .. 'o"' .. register .. type

  if linewise then
    cmd = 'V' .. cmd
  else
    cmd = '' .. length .. 'l' .. cmd
  end

  vim.cmd('norm! ' .. cmd)
  pcall(vim.api.nvim_win_set_cursor, 0, cursor)
end

---@param register _lines.register
---@param type _lines.type
local function visual_helper(register, type)
  local mode = vim.api.nvim_get_mode()

  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes('<c-\\><c-n>', true, false, true),
    'n',
    false
  )

  local cursor = vim.api.nvim_win_get_cursor(0)
  local pattern = type == 'y' and '^$' or '^%s*$'
  register = register or vim.v.register

  local first = vim.api.nvim_buf_get_mark(0, '<')
  local last = vim.api.nvim_buf_get_mark(0, '>')
  local lines = vim.fn.getregion(first, last, { type = mode })

  if
    vim.iter(lines):all(function(line)
      return line:match(pattern) and true or false
    end)
  then
    register = '_'
  end

  vim.cmd('gv"' .. register .. type)
  pcall(vim.api.nvim_win_set_cursor, 0, cursor)
end

---@param n _lines.n
local function lines_helper(n)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local lines = { vim.api.nvim_get_current_line() }

  for _ = 1, vim.v.count1 do
    if n == 1 then
      table.insert(lines, '')
    else
      table.insert(lines, 1, '')
    end
  end

  vim.api.nvim_buf_set_lines(0, cursor[1] - 1, cursor[1], false, lines)
  cursor[1] = n == 0 and cursor[1] + vim.v.count1 or cursor[1]
  vim.api.nvim_win_set_cursor(0, cursor)
end

---@param n _lines.n
local function comment_helper(n)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_line = vim.api.nvim_get_current_line()
  local lines = n == 0 and { 'x', current_line } or { current_line, 'x' }

  vim.api.nvim_buf_set_lines(0, cursor[1] - 1, cursor[1], false, lines)
  cursor[1] = cursor[1] + n
  vim.api.nvim_win_set_cursor(0, cursor)
  vim.cmd([[
    norm gcc==
    silent! substitute/x/
    startinsert!
  ]])
end

---@param register _lines.register
function M.yank_lines(register)
  return function()
    yank_helper(register, true, 'y')
  end
end

---@param register _lines.register
function M.yank_til_end(register)
  return function()
    yank_helper(register, false, 'y')
  end
end

---@param register _lines.register
function M.delete_lines(register)
  return function()
    yank_helper(register, true, 'd')
  end
end

---@param register _lines.register
function M.delete_til_end(register)
  return function()
    yank_helper(register, false, 'd')
  end
end

---@param register _lines.register
function M.change_lines(register)
  return function()
    yank_helper(register, true, 'c')

    local ctrl_f = ''
    if vim.o.indentexpr ~= '' then
      ctrl_f = vim.api.nvim_replace_termcodes('<c-f>', true, false, true)
    end
    vim.api.nvim_feedkeys('a' .. ctrl_f, 'n', false)
  end
end

---@param register _lines.register
function M.change_til_end(register)
  return function()
    yank_helper(register, false, 'c')
    vim.cmd.startinsert({ bang = true })
  end
end

---@param register _lines.register
function M.visual_yank(register)
  return function()
    visual_helper(register, 'y')
  end
end

---@param register _lines.register
function M.visual_delete(register)
  return function()
    visual_helper(register, 'd')
  end
end

---@param register _lines.register
function M.visual_change(register)
  return function()
    visual_helper(register, 'c')

    local ctrl_f = ''
    if vim.o.indentexpr ~= '' then
      ctrl_f = vim.api.nvim_replace_termcodes('<c-f>', true, false, true)
    end
    vim.api.nvim_feedkeys('a' .. ctrl_f, 'n', false)
  end
end

function M.add_lines_above()
  lines_helper(0)
end

function M.add_lines_below()
  lines_helper(1)
end

function M.comment_above()
  comment_helper(0)
end

function M.comment_below()
  comment_helper(1)
end

function M.comment_at_end()
  local current_line = vim.api.nvim_get_current_line():match('(.-)%s*$')

  vim.api.nvim_set_current_line('%%__MARKER__%%')
  vim.cmd.norm('gcc')

  local commented_line = vim.api.nvim_get_current_line()
  local start, _ = commented_line:find('%%__MARKER__%%')
  local cursor = vim.api.nvim_win_get_cursor(0)

  cursor[2] = 1 + start + current_line:len()

  local comment = vim.trim(commented_line):gsub('%%%%__MARKER__%%%%', '')

  vim.api.nvim_set_current_line(current_line .. ' ' .. comment)
  vim.api.nvim_win_set_cursor(0, cursor)

  local ctrl_f = ''
  if vim.o.indentexpr ~= '' then
    ctrl_f = vim.api.nvim_replace_termcodes('<c-f>', true, false, true)
  end
  vim.api.nvim_feedkeys('a' .. ctrl_f, 'n', false)
end

return M
