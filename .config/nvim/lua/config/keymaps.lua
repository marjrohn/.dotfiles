-- [[ General Keymaps ]]

local buffer = require('local.buffer')
local lines = require('local.lines')
local helpers = require('local.helpers')

local map = helpers.mapping()
local nmap = helpers.mapping({ mode = 'n' })
local imap = helpers.mapping({ mode = 'i' })
local xmap = helpers.mapping({ mode = 'x' })

-- Disabled mappings
map({ 'n', 'x' }, { '<leader>', 's', 'q:', 'q/', 'q?' }, '<nop>', { desc = 'Disabled' })

-- save to jump list when using j/k with count
map({ 'n', 'x' }, 'j', function()
  return vim.v.count1 > 1 and "m'" .. vim.v.count1 .. 'j' or 'gj'
end, { expr = true })
map({ 'n', 'x' }, 'k', function()
  return vim.v.count1 > 1 and "m'" .. vim.v.count1 .. 'k' or 'gk'
end, { expr = true })
-- map({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true })
-- map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true })

-- Center cursor line when scrolling
nmap('<c-f>', '<c-f>zz')
nmap('<c-u>', '<c-u>zz')
nmap('<c-b>', '<c-b>zz')
nmap('<c-d>', '<c-d>zz')

--- Scroll window with arrow keys
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

-- Navigate between splits with alt + wasd keys
nmap('<a-a>', '<c-w>h', { desc = 'Move Focus to the Left Window' })
nmap('<a-s>', '<c-w>j', { desc = 'Move Focus to the Lower Window' })
nmap('<a-w>', '<c-w>k', { desc = 'Move Focus to the Upper Window' })
nmap('<a-d>', '<c-w>l', { desc = 'Move Focus to the Right Window' })

-- Move lines
nmap('<a-j>', "<cmd>execute 'move .+' . v:count1<cr>==", { desc = 'Move Line Down' })
nmap('<a-k>', "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = 'Move Line Up' })
imap('<a-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Move Line Down' })
imap('<a-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Move Line Up' })
xmap('<a-j>', ":<c-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = 'Move Line Down' })
xmap(
  '<a-k>',
  ":<c-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv",
  { desc = 'Move Line Up' }
)

-- Clear search highlight with <esc>
map({ 'n', 'i' }, '<esc>', '<cmd>nohl<cr><esc>', { desc = 'Escape and Clear Hightlight Search' })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
nmap('n', "'Nn'[v:searchforward].'zzzv'", { desc = 'Next Search Result', expr = true })
nmap('N', "'nN'[v:searchforward].'zzzv'", { desc = 'Prev Search Result', expr = true })
map({ 'x', 'o' }, 'n', "'Nn'[v:searchforward]", { desc = 'Next Search Result', expr = true })
map({ 'x', 'o' }, 'N', "'nN'[v:searchforward]", { desc = 'Prev Search Result', expr = true })

-- Undo break-points
for _, point in ipairs({ ',', '.', ';', ':', '/' }) do
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
nmap('vv', '`[v`]', { desc = 'Select the latest yanked text' })

--- Don't yank to register if line(s) is blank
nmap('yy', lines.yank_lines(), { desc = 'Yank [count] Lines' })
nmap('<leader>yy', lines.yank_lines('+'), { desc = 'Yank Lines (System Clipboard)' })
nmap('Y', lines.yank_til_end(), { desc = 'Yank Til End' })
nmap('<leader>Y', lines.yank_til_end('+'), { desc = 'Yank Til End (System Clipboard)' })
nmap('dd', lines.delete_lines(), { desc = 'Delete [count] Lines' })
nmap('D', lines.delete_til_end(), { desc = 'Delete Til End' })
nmap('cc', lines.change_lines(), { desc = 'Change [count] Lines' })
nmap('C', lines.change_til_end(), { desc = 'Change Til End' })

-- Copy contents of `v:register` to `+` register
nmap('yc', function()
  vim.fn.setreg('+', vim.fn.getreg(vim.v.register))
end, { desc = 'Copy to System Clipboard' })

-- Don't yank when deleting with `x` or '<del>'
map({ 'n', 'x' }, 'x', '"_x')
map({ 'n', 'x' }, 'X', '"_X')
map({ 'n', 'x' }, '<del>', '"_<del>')

-- Commenting
nmap('gcO', lines.comment_above, { desc = 'Add Comment Above' })
nmap('gco', lines.comment_below, { desc = 'Add Comment Below' })
nmap({ 'gca', 'gcA' }, lines.comment_at_end, { desc = 'Add Comment at End' })

-- Delete contents of the current line
nmap('d<space>', '<cmd>call setline(".", "")<cr>', { desc = 'Clear Current Line' })

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

nmap({ '<leader>bb', "<leader>'" }, '<cmd>edit #<cr>', { desc = 'Go to Last Accessed Buffer' })

nmap({ '<leader>b[', 'H' }, "<cmd>execute 'bprev' . v:count1<cr>", { desc = 'Previous Buffer' })
nmap({ '<leader>b]', 'L' }, "<cmd>execute 'bnext' . v:count1<cr>", { desc = 'Next Buffer' })

nmap('<leader>bD', '<cmd>bdelete', { desc = 'Delete Buffer and Window' })
nmap('<leader>bd', buffer.buf_remove, { desc = 'Delete Buffer' })
nmap('<leader>bo', buffer.buf_only, { desc = 'Buffer Only' })
---

--- Tabs
local function tab_do(args)
  local tabs = vim.api.nvim_list_tabpages()
  local cmd = args[1]
  local first = args.first
  local last = args.last

  if args.index then
    local to = math.min(math.max(args.index, 1), #tabs)

    if to == 1 then
      return string.format('<cmd>silent! %s<cr>', first)
    end

    if to == #tabs then
      return string.format('<cmd>silent! %s<cr>', last)
    end

    return string.format('<cmd>silent! %s %d<cr>', cmd, to)
  end

  local currtab = vim.api.nvim_get_current_tabpage()
  local tabnr = vim.api.nvim_tabpage_get_number(currtab)
  local dir = args.dir

  if dir == 1 and tabnr == #tabs then
    return string.format('<cmd>silent! %s<cr>', first)
  end

  if dir == -1 and tabnr == 1 then
    return string.format('<cmd>silent! %s<cr>', last)
  end

  local dir_sym = dir == 1 and '+' or '-'

  local max_count = dir == 1 and (#tabs - tabnr) or (tabnr - 1)

  return string.format('<cmd>silent! %s %s%d<cr>', cmd, dir_sym, math.min(vim.v.count1, max_count))
end

local function tabnav(args)
  return function()
    return tab_do({
      'tabnext',
      dir = args.dir,
      index = args.index,
      first = 'tabfist',
      last = 'tablast',
    })
  end
end

local function tabmov(args)
  return function()
    return tab_do({
      'tabmove',
      dir = args.dir,
      index = args.index,
      first = '0tabmove',
      last = '$tabmove',
    })
  end
end

nmap('<leader><tab>n', '<cmd>tabnew<cr>', { desc = 'New Tab' })

nmap({ '<leader><tab>0', '<leader>1' }, '<cmd>tabfirst<cr>', { desc = 'Go to First Tab' })
nmap({ '<leader><tab>$', '<leader>0' }, '<cmd>tablast<cr>', { desc = 'Go to Last Tab' })

nmap(
  { '<leader><tab><tab>', "<leader>'" },
  '<cmd>silent! tabnext #<cr>',
  { desc = 'Go to Last Accessed Tab' }
)

nmap({ '<leader><tab>h', '<c-h>' }, tabnav({ dir = -1 }), { desc = 'Previous Tab', expr = true })
nmap({ '<leader><tab>l', '<c-l>' }, tabnav({ dir = 1 }), { desc = 'Next Tab', expr = true })

nmap(
  { '<leader>!', '<leader><s-tab>0', '<leader><s-tab>)' },
  '<cmd>0tabmove<cr>',
  { desc = 'Move Tab to the First' }
)
nmap(
  { '<leader>)', '<leader><s-tab>4', '<leader><s-tab>$' },
  '<cmd>$tabmove<cr>',
  { desc = 'Move Tab to the Last' }
)
nmap({
  '<leader>"',
  '<leader><tab><s-tab>',
  '<leader><s-tab><tab>',
  '<leader><s-tab><s-tab>',
}, '<cmd>silent! tabmove #<cr>', { desc = 'Move To Last Accessed Tab' })

nmap(
  { '<leader><tab>j', '<c-j>' },
  tabmov({ dir = -1 }),
  { desc = 'Move Tab to the Left', expr = true }
)
nmap(
  { '<leader><tab>k', '<c-k>' },
  tabmov({ dir = 1 }),
  { desc = 'Move Tab to the Right', expr = true }
)

nmap('<leader><tab>o', '<cmd>tabonly<cr>', { desc = 'Tab Only' })
nmap('<leader><tab>d', '<cmd>tabclose<cr>', { desc = 'Close Tab' })

for idx = 2, 9 do
  nmap(
    string.format('<leader>%d', idx),
    tabnav({ index = idx }),
    { desc = 'Go to Tab ' .. idx, expr = true }
  )
  nmap(
    string.format('<leader><s-%d>', idx),
    tabmov({ index = idx }),
    { desc = 'Move to Tab ' .. idx, expr = true }
  )
end

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
end, { desc = 'Toggle Tabline' })
---
