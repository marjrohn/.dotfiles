-- [[ General Keymappings ]]

local helpers = require('local.helpers')
local map = helpers.map()
local nmap = helpers.map({ mode = 'n' })
local imap = helpers.map({ mode = 'i' })
local xmap = helpers.map({ mode = 'x' })

nmap('<leader>', '<nop>')

-- better up/down
map({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true })
map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true })

-- center when scroll page
nmap('<c-f>', '<c-f>zz')
nmap('<c-u>', '<c-u>zz')
nmap('<c-b>', '<c-b>zz')
nmap('<c-d>', '<c-d>zz')

-- move to window using <ctrl> hjkl keys
nmap('<c-h>', '<c-w>h', { desc = 'Go to Left Window', remap = true })
nmap('<c-j>', '<c-w>j', { desc = 'Go to Lower Window', remap = true })
nmap('<c-k>', '<c-w>k', { desc = 'Go to Upper Window', remap = true })
nmap('<c-l>', '<c-w>l', { desc = 'Go to Right Window', remap = true })

-- scroll window
nmap('<left>', 'zh', { desc = 'Scroll left' })
nmap('<down>', '<c-e>', { desc = 'Scroll down' })
nmap('<up>', '<c-y>', { desc = 'Scroll up' })
nmap('<right>', 'zl', { desc = 'Scroll right' })

-- go to top/bottom of window
nmap('<s-down>', 'L', { desc = 'Go to top of window' })
nmap('<s-up>', 'H', { desc = 'Go to bottom of window' })

-- scroll to far left/right
nmap('<s-left>', 'zH', { desc = 'Scroll to far left' })
nmap('<s-right>', 'zL', { desc = 'Scroll to far right' })

-- resize window using
nmap('<c-up>', '<cmd>resize +2<cr>', { desc = 'Increase Window Height' })
nmap('<c-down>', '<cmd>resize -2<cr>', { desc = 'Decrease Window Height' })
nmap('<c-left>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease Window Width' })
nmap('<c-right>', '<cmd>vertical resize +2<cr>', { desc = 'Increase Window Width' })

-- move lines
nmap('<a-j>', '<cmd>m .+1<cr>==', { desc = 'Move Line Down' })
imap('<a-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Move Line Down' })
xmap('<a-j>', ":m '>+1<cr>gv=gv", { desc = 'Move Line Down' })

nmap('<a-k>', '<cmd>m .-2<cr>==', { desc = 'Move Line Up' })
imap('<a-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Move Line Up' })
xmap('<a-k>', ":m '<-2<cr>gv=gv", { desc = 'Move Line Down' })

-- clear search with <esc>
map({ 'n', 'i' }, '<esc>', '<cmd>noh<cr><esc>', { desc = 'Escape and Clear Hightlight Search' })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map('n', 'n', "'Nn'[v:searchforward].'zzzv'", { desc = 'Next Search Result', expr = true })
map('x', 'n', "'Nn'[v:searchforward]", { desc = 'Next Search Result', expr = true })
map('o', 'n', "'Nn'[v:searchforward]", { desc = 'Next Search Result', expr = true })
map('n', 'N', "'nN'[v:searchforward].'zzzv'", { desc = 'Prev Search Result', expr = true })
map('x', 'N', "'nN'[v:searchforward]", { desc = 'Prev Search Result', expr = true })
map('o', 'N', "'nN'[v:searchforward]", { desc = 'Prev Search Result', expr = true })

-- undo break-points
imap(',', ',<c-g>u')
imap('.', '.<c-g>u')
imap(';', ';<c-g>u')
imap(':', ':<c-g>u')
imap('/', '/<c-g>u')
imap('(', '(<c-g>u')
imap(')', ')<c-g>u')
imap('[', '[<c-g>u')
imap(']', ']<c-g>u')
imap('{', '{<c-g>u')
imap('}', '}<c-g>u')

-- file saving
nmap('<c-s>', '<cmd>w<cr>', { desc = 'Save File' })

-- better indenting
xmap('>', '>gv')
xmap('<tab>', '>gv')
xmap('<', '<gv')
xmap('<s-tab>', '<gv')

-- yank to system clipboard
for _, key in ipairs({ 'y', 'Y' }) do
  map({ 'n', 'x' }, '<leader>' .. key, function()
    local count = vim.v.count == 0 and '' or vim.v.count

    return '"+' .. count .. key
  end, { desc = 'Yank (System Clipboard)', expr = true })
end

--- paste to system clipboard
for _, key in ipairs({ 'p', 'P' }) do
  nmap('<leader>' .. key, function()
    local count = vim.v.count == 0 and '' or vim.v.count

    return '"+' .. count .. key
  end, { desc = 'Paste (System Clipboard)', expr = true })
end

xmap('p', 'P')
xmap('P', 'p')
xmap('<leader>p', function()
  local count = vim.v.count == 0 and '' or vim.v.count

  return '"+' .. count .. 'P'
end, { desc = 'Paste Without Yank (System Clipboard)', expr = true })

xmap('<leader>P', function()
  local count = vim.v.count == 0 and '' or vim.v.count

  return '"+' .. count .. 'p'
end, { desc = 'Paste (System Clipboard)', expr = true })
---

--- don't yank to register if line is blank
nmap('yy', function()
  if vim.fn.getline('.') ~= '' then
    local count = vim.v.count <= 1 and '' or vim.v.count
    local reg = vim.v.register

    vim.api.nvim_feedkeys('"' .. reg .. count .. 'yy', 'n', false)
  end
end, { desc = 'Yank Current Line' })

nmap('<leader>yy', function()
  if vim.fn.getline('.') ~= '' then
    local count = vim.v.count <= 1 and '' or vim.v.count
    local reg = '+'

    vim.api.nvim_feedkeys('"' .. reg .. count .. 'yy', 'n', false)
  end
end, { desc = 'Yank Current Line (System Clipboard)' })

nmap('dd', function()
  local count = vim.v.count <= 1 and '' or vim.v.count
  local reg = vim.v.register

  if vim.fn.getline('.'):match('^%s*$') then
    reg = '_'
  end

  vim.api.nvim_feedkeys('"' .. reg .. count .. 'dd', 'n', false)
end, { desc = 'Delete Current Line' })

nmap('cc', function()
  local count = vim.v.count <= 1 and '' or vim.v.count
  local reg = vim.v.register

  if vim.fn.getline('.'):match('^%s*$') then
    reg = '_'
  end

  vim.api.nvim_feedkeys('"' .. reg .. count .. 'cc', 'n', false)
end, { desc = 'Change Current Line' })
---

-- don't yank when delete with `x`
map({ 'n', 'x' }, 'x', '"_x')
map({ 'n', 'x' }, 'X', '"_X')
map({ 'n', 'x' }, '<del>', '"_<del>')

-- commenting
nmap('gco', 'o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>', { desc = 'Add Comment Bellow' })
nmap('gcO', 'O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>', { desc = 'Add Comment Above' })
nmap('gcA', function()
  if vim.fn.getline('.'):match('^%s*$') then
    return 'Vcx<esc><cmd><normal gcc<cr>fxa<bs>'
  end

  return '<cmd>normal gcc^"-dW<cr>A <esc>"-Pa'
end, { desc = 'Add Comment to End', expr = true })

-- add a new line below/above the cursor
nmap(']<leader>', ':normal! m`o<esc>``', { desc = 'Add new Line Below' })
nmap('[<leader>', ':normal! m`O<esc>``', { desc = 'Add New Line Above' })

-- delete contents of the current line
nmap('d<leader>', '<cmd>normal! 0d$<cr>', { desc = 'Clear Current Line' })

-- quitting
nmap('<leader>q', '<cmd>confirm q<cr>', { desc = 'Quit' })
nmap('<leader>Q', '<cmd>confirm qall<cr>', { desc = 'Exit Neovim' })

-- quickfix
nmap(']q', '<cmd>cnext<cr>', { desc = 'Next Quickfix' })
nmap('[q', '<cmd>cprev<cr>', { desc = 'Previous Quickfix' })
nmap('[Q', '<cmd>cfirst<cr>', { desc = 'First Quickfix' })
nmap(']Q', '<cmd>clast<cr>', { desc = 'Last Quickfix' })

-- loclist
nmap(']l', '<cmd>lnext<cr>', { desc = 'Next Loclist' })
nmap('[l', '<cmd>lprev<cr>', { desc = 'Previous Loclist' })
nmap('[L', '<cmd>lfirst<cr>', { desc = 'First Loclist' })
nmap(']L', '<cmd>llast<cr>', { desc = 'Last Loclist' })

--- diagnostics
local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil

  return function()
    go({ severity = severity })
  end
end

nmap(']d', diagnostic_goto(true), { desc = 'Next Diagnostic' })
nmap('[d', diagnostic_goto(false), { desc = 'Previous Diagnostic' })
nmap(']e', diagnostic_goto(true, 'ERROR'), { desc = 'Next Diagnostic Error' })
nmap('[e', diagnostic_goto(false, 'ERROR'), { desc = 'Previous Diagnostic Error' })
nmap(']w', diagnostic_goto(true, 'WARN'), { desc = 'Next Diagnostic Warning' })
nmap('[w', diagnostic_goto(false, 'WARN'), { desc = 'Previous Diagnostic Warning' })
---

--- buffers
nmap('<s-h>', '<cmd>bprevious<cr>', { desc = 'Prev Buffer' })
nmap('<s-l>', '<cmd>bnext<cr>', { desc = 'Next Buffer' })
nmap('[b', '<cmd>bprevious<cr>', { desc = 'Prev Buffer' })
nmap(']b', '<cmd>bnext<cr>', { desc = 'Next Buffer' })
nmap('<leader>bn', '<cmd>enew<cr>', { desc = 'New Buffer' })
nmap('<leader>bb', '<cmd>edit #<cr>', { desc = 'Switch to Other Buffer' })
nmap('<leader>bD', '<cmd>:bdelete<cr>', { desc = 'Delete Buffer and Window' })
-- nmap('<leader>bd', require('utils').buf_remove, { desc = 'Delete Buffer' })
---

-- windows
nmap('<c-w><tab>', '<c-w>T', { desc = 'Move Windows to a New Tab' })
nmap('<leader>w', '<c-w>', { desc = 'Windows', remap = true })
nmap('<leader>\\', '<c-w>s', { desc = 'Split Window Below' })
nmap('<leader>|', '<c-w>v', { desc = 'Split Window Right' })

--- tabs
nmap('<leader><tab><tab>', '<cmd>tabnew<cr>', { desc = 'New Tab' })
nmap('<leader><tab>n', '<cmd>tabnew<cr>', { desc = 'New Tab' })

nmap('<leader><tab>0', '<cmd>tabfirst<cr>', { desc = 'Go to First Tab' })
nmap('<leader><tab>$', '<cmd>tablast<cr>', { desc = 'Go to Last Tab' })

nmap('<leader><tab>]', '<cmd>tabnext<cr>', { desc = 'Next Tab' })
nmap('<leader><tab>[', '<cmd>tabprevious<cr>', { desc = 'Previous Tab' })
nmap('<leader><tab>l', '<cmd>tabnext<cr>', { desc = 'Next Tab' })
nmap('<leader><tab>h', '<cmd>tabprevious<cr>', { desc = 'Previous Tab' })

nmap('<leader><tab>0', '<cmd>0tabmove<cr>', { desc = 'Move Tab to the First' })
nmap('<leader><tab>$', '<cmd>$tabmove<cr>', { desc = 'Move Tab to the Last' })

nmap('<leader><tab>k', '<cmd>+tabmove<cr>', { desc = 'Move Tab to the Right' })
nmap('<leader><tab>j', '<cmd>-tabmove<cr>', { desc = 'Move Tab to the Left' })

nmap('<leader><tab>D', '<cmd>tabonly<cr>', { desc = 'Close Other Tabs' })
nmap('<leader><tab>d', '<cmd>tabclose<cr>', { desc = 'Close Tab' })

for i = 1, 9 do
  nmap('<leader><tab>' .. i, '<cmd>silent! tabnext ' .. i .. '<cr>', { desc = 'Go to Tab ' .. i })
  nmap('<a-' .. i .. '>', '<cmd>silent! tabnext ' .. i .. '<cr>', { desc = 'Go to Tab ' .. i })
end
---
