-- [[ General Auto Commands]]

local augroup = require('local.helpers').augroup
local autocmd = require('local.helpers').autocmd

if vim.env.TERM == 'xterm-kitty' then
  local kitty_cmd = 'kitty'
  if vim.env.CONTAINER_ID ~= nil then
    kitty_cmd = 'distrobox-host-exec ' .. kitty_cmd
  end

  -- remove kitty padding when neovim lauch/resume
  autocmd({ 'VimEnter', 'VimResume' }, {
    group = augroup('kitty_padding_disable'),
    callback = function()
      vim.cmd('silent !' .. kitty_cmd .. ' @ --to=$KITTY_LISTEN_ON set-spacing padding=0')
    end,
  })

  -- restore kitty padding when leaving/suspending
  autocmd({ 'VimLeave', 'VimSuspend' }, {
    group = augroup('kitty_padding_enable'),
    callback = function()
      vim.cmd('silent !' .. kitty_cmd .. ' @ --to=$KITTY_LISTEN_ON set-spacing padding=default')
    end,
  })
end

-- Check if we need to reload the file when it changed
autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  group = augroup('checktime'),
  callback = function()
    if vim.o.buftype ~= 'nofile' then
      vim.cmd('checktime')
    end
  end,
})

-- Highlight on yank
autocmd('TextYankPost', {
  group = augroup('highlight_yank'),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- resize splits if window got resized
autocmd({ 'VimResized' }, {
  group = augroup('resize_splits'),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd('tabdo wincmd =')
    vim.cmd('tabnext ' .. current_tab)
  end,
})

-- go to last loc when opening a buffer
autocmd('BufReadPost', {
  group = augroup('last_loc'),
  callback = function(event)
    local exclude = { 'gitcommit' }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- close some filetypes with <q>
autocmd('FileType', {
  group = augroup('close_with_q'),
  pattern = {
    'PlenaryTestPopup',
    'grug-far',
    'help',
    'lspinfo',
    'notify',
    'qf',
    'spectre_panel',
    'startuptime',
    'tsplayground',
    'neotest-output',
    'checkhealth',
    'neotest-summary',
    'neotest-output-panel',
    'dbout',
    'gitsigns.blame',
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<cr>', {
      buffer = event.buf,
      silent = true,
      desc = 'Quit buffer',
    })
  end,
})

-- make it easier to close man-files when opened inline
autocmd('FileType', {
  group = augroup('man_unlisted'),
  pattern = { 'man' },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- wrap and check for spell in text filetypes
autocmd('FileType', {
  group = augroup('wrap_spell'),
  pattern = { 'text', 'plaintex', 'typst', 'gitcommit', 'markdown' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Fix conceallevel for json files
autocmd({ 'FileType' }, {
  group = augroup('json_conceal'),
  pattern = { 'json', 'jsonc', 'json5' },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
autocmd({ 'BufWritePre' }, {
  group = augroup('auto_create_dir'),
  callback = function(event)
    if event.match:match('^%w%w+:[\\/][\\/]') then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- dont insert comment leader when add a new line with 'o' or 'O'
autocmd('FileType', {
  group = augroup('no_auto_comment'),
  callback = function()
    vim.opt_local.formatoptions:remove('o')
  end,
})

-- make 'scrolloff' and 'sidescrolloff' relative
autocmd({ 'WinEnter', 'WinResized' }, {
  group = augroup('win_scrolloff'),
  callback = function()
    local update_scrolloff = function(win)
      local w = vim.api.nvim_win_get_width(win)
      local h = vim.api.nvim_win_get_height(win)

      vim.wo[win].sidescrolloff = math.floor(vim.g.sidescrolloff * w + 0.5)
      vim.wo[win].scrolloff = math.floor(vim.g.scrolloff * h + 0.5)
    end

    if vim.v.event.windows then
      for _, win in pairs(vim.v.event.windows) do
        update_scrolloff(win)
      end
    end

    update_scrolloff(vim.api.nvim_get_current_win())
  end,
})
