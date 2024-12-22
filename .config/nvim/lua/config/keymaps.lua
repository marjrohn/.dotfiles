-- [[ General Keymappings ]]

local helpers = require('local.helpers')
local map = helpers.mapping()
local nmap = helpers.mapping({ mode = 'n' })
local imap = helpers.mapping({ mode = 'i' })
local xmap = helpers.mapping({ mode = 'x' })

-- Disabled mappings
map({ 'n', 'x' }, { '<leader>', 'q:', 'q/' }, '<nop>', { desc = 'Disabled' })

-- Better up/down
map(
  { 'n', 'x' },
  'j',
  "v:count == 0 ? 'gj' : 'j'",
  { desc = 'Down', expr = true }
)
map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true })

-- Center cursor line when scrolling
nmap('<c-f>', '<c-f>zz')
nmap('<c-u>', '<c-u>zz')
nmap('<c-b>', '<c-b>zz')
nmap('<c-d>', '<c-d>zz')

-- Scroll window with arrow keys
map({ 'n', 'x' }, '<left>', 'zh', { desc = 'Scroll left' })
map({ 'n', 'x' }, '<down>', '<c-e>', { desc = 'Scroll down' })
map({ 'n', 'x' }, '<up>', '<c-y>', { desc = 'Scroll up' })
map({ 'n', 'x' }, '<right>', 'zl', { desc = 'Scroll right' })

map({ 'n', 'x' }, '<s-down>', '<c-f>zz', { desc = 'Scroll window down' })
map({ 'n', 'x' }, '<s-up>', '<c-b>zz', { desc = 'Scroll window up' })
map({ 'n', 'x' }, '<s-left>', 'zH', { desc = 'Scroll to far left' })
map({ 'n', 'x' }, '<s-right>', 'zL', { desc = 'Scroll to far right' })

-- Resize window with ctrl + arrow keys
nmap('<c-left>', '<c-w>>', { desc = 'Decrease Window Width' })
nmap('<c-down>', '<c-w>-', { desc = 'Decrease Window Height' })
nmap('<c-up>', '<c-w>+', { desc = 'Increase Window Height' })
nmap('<c-right>', '<c-w><', { desc = 'Increase Window Width' })

-- Move lines
nmap(
  '<a-j>',
  "<cmd>execute 'move .+' . v:count1<cr>==",
  { desc = 'Move Line Down' }
)
nmap(
  '<a-k>',
  "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==",
  { desc = 'Move Line Up' }
)
imap('<a-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Move Line Down' })
imap('<a-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Move Line Up' })
xmap(
  '<a-j>',
  ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv",
  { desc = 'Move Line Down' }
)
xmap(
  '<a-k>',
  ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv",
  { desc = 'Move Line Up' }
)

-- Clear search with <esc>
map(
  { 'n', 'i' },
  '<esc>',
  '<cmd>noh<cr><esc>',
  { desc = 'Escape and Clear Hightlight Search' }
)

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
nmap(
  'n',
  "'Nn'[v:searchforward].'zzzv'",
  { desc = 'Next Search Result', expr = true }
)
nmap(
  'N',
  "'nN'[v:searchforward].'zzzv'",
  { desc = 'Prev Search Result', expr = true }
)
map(
  { 'x', 'o' },
  'n',
  "'Nn'[v:searchforward]",
  { desc = 'Next Search Result', expr = true }
)
map(
  { 'x', 'o' },
  'N',
  "'nN'[v:searchforward]",
  { desc = 'Prev Search Result', expr = true }
)

-- Undo break-points
-- stylua: ignore
for _, point in ipairs({
  ',', '.', ';', ':', '/', '\\',
  '(', ')', '[', ']', '{', '}'
}) do
  imap(point, point .. '<c-g>u')
end

-- File saving
nmap('<c-s>', '<cmd>w<cr>', { desc = 'Save File' })

-- Better indenting
xmap('>', '>gv')
xmap('<tab>', '>gv')
xmap('<', '<gv')
xmap('<s-tab>', '<gv')

-- The default behavior or `p` will yank the select
-- text after paste. To not yank we use `P` instead
-- The following will exchange this behavior
xmap('p', 'P')
xmap('P', 'p')

-- Yank to system clipboard
vim.iter({ 'y', 'Y' }):each(function(key)
  map({ 'n', 'x' }, '<leader>y' .. key, function()
    local count = vim.v.count < 2 and '' or vim.v.count

    return '"+' .. count .. key
  end, { desc = 'Yank (System Clipboard)', expr = true })
end)

-- Paste to system clipboard
vim.iter({ 'p', 'P' }):each(function(key)
  nmap('<leader>' .. key, function()
    local count = vim.v.count < 2 and '' or vim.v.count

    return '"+' .. count .. key
  end, { desc = 'Paste (System Clipboard)', expr = true })

  xmap('<leader>' .. key, function()
    local count = vim.v.count < 2 and '' or vim.v.count

    -- swap `p` with `P`
    local key_lower = key:lower()
    if key == key_lower then
      key = key:upper()
    else
      key = key_lower
    end

    return '"+' .. count .. key
  end, { desc = 'Paste (System Clipboard)', expr = true })
end)

-- Select the latest yanked contents
nmap('vy', '`[v`]', { desc = 'Select the latest yanked text' })

--- Don't yank to register if line(s) is blank
local function is_line_blank(pattern)
  local first = vim.fn.line('.') - 1
  local last = first + vim.v.count1
  local lines = vim.api.nvim_buf_get_lines(0, first, last, false)

  return vim.iter(lines):all(function(line)
    return line:match(pattern) and true or false
  end)
end

local function fn(key, pattern, register)
  return function()
    local count = vim.v.count < 2 and '' or vim.v.count

    if is_line_blank(pattern) then
      register = '_'
    else
      register = register or vim.v.register
    end

    vim.api.nvim_feedkeys('"' .. register .. count .. key, 'n', false)
  end
end

vim.iter({ 'yy', 'dd', 'cc', 'Y', 'D', 'C' }):each(function(key)
  if key:match('^[yY]') then
    local rhs = key == 'Y' and 'y$' or key -- Y dont work with :norm!
    nmap('<leader>' .. key, fn(rhs, '^$', '+'))
    nmap(key, fn(rhs, '^$'))
  else
    nmap(key, fn(key, '^%s*$'))
  end
end)
---

-- Copy contents of `v:register` to `+` register
nmap(
  'yc',
  "<cmd>silent! call setreg('+', getreg(v:register))<cr>",
  { desc = 'Copy to system clipboard' }
)

-- Don't yank when delete with `x` or '<del>'
map({ 'n', 'x' }, 'x', '"_x')
map({ 'n', 'x' }, 'X', '"_X')
map({ 'n', 'x' }, '<del>', '"_<del>')

-- Commenting
nmap(
  'gco',
  'o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>',
  { desc = 'Add Comment Bellow' }
)
nmap(
  'gcO',
  'O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>',
  { desc = 'Add Comment Above' }
)
nmap({ 'gca', 'gcA' }, function()
  local line = 'x' .. vim.api.nvim_get_current_line()
  vim.api.nvim_set_current_line(line)
  vim.cmd.normal('gcc$')
  line = vim.api.nvim_get_current_line()

  local comment = line:match('[^ ]*')
  local pattern = string.format('%%s?^%s%%s?', comment)
  line = line:gsub(pattern, '')
  line = vim.trim(line):sub(2)

  vim.api.nvim_set_current_line(string.format('%s %s ', line, comment))

  local keys = line:match('^%s*$') and '==A' or 'A'
  vim.api.nvim_feedkeys(keys, 'n', false)
end, { desc = 'Add Comment to End' })

--- Add a new line above/below the cursor
local function add_lines(dir)
  return function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local lines = { vim.api.nvim_get_current_line() }

    for _ = 1, vim.v.count1 do
      if dir == 'below' then
        table.insert(lines, '')
      else
        table.insert(lines, 1, '')
      end
    end

    vim.api.nvim_buf_set_lines(0, cursor[1] - 1, cursor[1], false, lines)
    cursor[1] = dir == 'above' and cursor[1] + vim.v.count1 or cursor[1]
    vim.api.nvim_win_set_cursor(0, cursor)
  end
end

nmap('[<leader>', add_lines('above'), { desc = 'Add New Line Above' })
nmap(']<leader>', add_lines('below'), { desc = 'Add New Line Below' })
---

-- Delete contents of the current line
nmap('d<leader>', '<cmd>normal! 0d$<cr>', { desc = 'Clear Current Line' })

-- Quitting
nmap('<leader>q', '<cmd>confirm q<cr>', { desc = 'Quit' })
nmap('<leader>Q', '<cmd>confirm qall<cr>', { desc = 'Exit Neovim' })

-- Windows
nmap('<c-w><tab>', '<c-w>T', { desc = 'Move Windows to a New Tab' })
nmap('<leader>w', '<c-w>', { desc = 'Windows', remap = true })
nmap('<leader>\\', '<c-w>s', { desc = 'Split Window Below' })
nmap('<leader>|', '<c-w>v', { desc = 'Split Window Right' })

--- Buffers
nmap('<leader>bn', '<cmd>enew<cr>', { desc = 'New Buffer' })
nmap('<leader>bv', '<cmd>vnew<cr>', { desc = 'New Buffer in a Vertical Split' })
nmap('<leader>bh', '<cmd>new<cr>', { desc = 'New Buffer in a Horizontal Split' })

nmap(
  { '<leader>bb', "<leader>'" },
  '<cmd>edit #<cr>',
  { desc = 'Go to Last Accessed Buffer' }
)

nmap(
  { '<leader>b[', 'H' },
  "<cmd>execute 'bprev' . v:count1<cr>",
  { desc = 'Previous Buffer' }
)
nmap(
  { '<leader>b]', 'L' },
  "<cmd>execute 'bnext' . v:count1<cr>",
  { desc = 'Next Buffer' }
)

nmap('<leader>bD', '<cmd>bdelete', { desc = 'Delete Buffer and Window' })
nmap(
  '<leader>bd',
  require('local.buffer').buf_remove,
  { desc = 'Delete Buffer' }
)
nmap('<leader>bo', require('local.buffer').buf_only, { desc = 'Buffer Only' })
---

--- Tabs
nmap('<leader><tab>n', '<cmd>tabnew<cr>', { desc = 'New Tab' })

nmap(
  { '<leader><tab>0', '<a-1>' },
  '<cmd>tabfirst<cr>',
  { desc = 'Go to First Tab' }
)
nmap(
  { '<leader><tab>$', '<a-0>' },
  '<cmd>tablast<cr>',
  { desc = 'Go to Last Tab' }
)

nmap(
  { '<leader><tab><tab>', "<a-'>" },
  '<cmd>silent! tabnext #<cr>',
  { desc = 'Go to Last Accessed Tab' }
)

nmap(
  { '<leader><tab>h', '<a-h>' },
  "<cmd>execute 'tabnext -' . v:count1<cr>",
  { desc = 'Previous Tab' }
)
nmap(
  { '<leader><tab>l', '<a-l>' },
  "<cmd>execute 'tabnext +' . v:count1<cr>",
  { desc = 'Next Tab' }
)

nmap(
  { '<a-s-1>', '<leader><s-tab>0', '<leader><s-tab>)' },
  '<cmd>0tabmove<cr>',
  { desc = 'Move Tab to the First' }
)
nmap(
  { '<a-s-0>', '<leader><s-tab>4', '<leader><s-tab>$' },
  '<cmd>$tabmove<cr>',
  { desc = 'Move Tab to the Last' }
)

nmap({
  '<a-">',
  '<leader><tab><s-tab>',
  '<leader><s-tab><tab>',
  '<leader><s-tab><s-tab>',
}, '<cmd>silent! tabmove #', { desc = 'Move To Last Accessed Tab' })

nmap(
  { '<leader><tab>j', '<a-s-h>' },
  "<cmd>execute 'tabmove -' . v:count1<cr>",
  { desc = 'Move Tab to the Left' }
)
nmap(
  { '<leader><tab>k', '<a-s-l>' },
  "<cmd>execute 'tabmove +' . v:count1<cr>",
  { desc = 'Move Tab to the Right' }
)

nmap('<leader><tab>o', '<cmd>tabonly<cr>', { desc = 'Tab Only' })
nmap('<leader><tab>d', '<cmd>tabclose<cr>', { desc = 'Close Tab' })

local lhs, rhs
for idx = 2, 9 do
  lhs = string.format('<a-%s>', idx)
  rhs = string.format('<cmd>silent! tabnext %s<cr>', idx)
  nmap(lhs, rhs, { desc = 'Go to Tab ' .. idx })

  lhs = string.format('<a-s-%s>', idx)
  rhs = string.format('<cmd>silent! tabmove %s<cr>', idx)
  nmap(lhs, rhs, { desc = 'Go to Tab ' .. idx })
end

-- toggle tabline
nmap('<leader><tab>t', function()
  if vim.o.tabline == 1 then
    if vim.fn.tabpagenr('$') > 1 then
      vim.opt.showtabline = 0
    else
      vim.opt.showtabline = 2
    end
  else
    -- Cycle between 0 and 2
    vim.opt.showtabline = 2 * ((vim.o.showtabline / 2 + 1) % 2)
  end
end, { desc = 'Toggle Tab Line' })
---
