local g = vim.g
local opt = vim.opt

vim.filetype.add({
  filename = {
    ['config'] = 'bash',
  },
})

-- set both `<leader>` and `<localleader>` to the space key
g.mapleader = ' '
g.localmapleader = ' '

-- enable/disable some lsp feature globally
--
-- can be overridden locally using buffer-scoped variables (`b:` or `vim.b`)
-- e.g. any of these commands enable codelens for the current buffer:
-- - `:let b:lsp_codelens_enable = v:true`
-- - `:lua vim.b[0].lsp_codelens_enable = true`
--
-- to fallback to global bahavior just delete the variable:
-- - `:unlet b:lsp_codelens_enable`
-- - `:lua vim.b[0].lsp_codelens_enable = nil`
--
g.lsp_autoformat_enable = true
g.lsp_codelens_enable = false
g.lsp_document_highlight_enable = true
g.lsp_inlay_hint_enable = true

-- in those milliseconds, check if e.g. inlay hints should be enabled/disabled
g.lsp_refresh_time = 1000

-- `scrolloff` and `sidescrolloff` relative to the size of the current window
g.sidescrolloff = 0.2
g.scrolloff = 0.2

-- default size of a floating window
g.win_width = 0.9
g.win_height = 0.8

-- max size of a preview window (e.g. hover/signature)
g.win_preview_max_width = 0.55
g.win_preview_max_height = 0.75

-- silent providers warnings when running `:checkhealth`
g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0
g.loaded_node_provider = 0

-- enable auto save
opt.autowriteall = true

-- don't stop backspece at insert
opt.backspace:append({ 'nostop' })

-- wrap indent
opt.breakindent = true

-- insert mode completion options
opt.completeopt = { 'menu', 'menuone', 'noselect' }

-- copy the previous indentation on autoindenting
opt.copyindent = true

-- hightlight current line
opt.cursorline = true

-- use space insted of tabs
opt.expandtab = true

-- remove '~' char for empty lines and change fold chars
opt.fillchars = {
  foldopen = '󱇬',
  foldclose = '─',
  fold = ' ',
  foldsep = '│',
  diff = '╱',
  eob = ' ',
}

-- folding
opt.foldenable = true
opt.foldmethod = 'expr'
-- TODO: change to lsp foldexpr when nvim-0.11 become stable
opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
opt.foldcolumn = '1'
opt.foldlevel = 99
opt.foldlevelstart = 99

-- dont open a closed fold with horizontal movements
opt.foldopen:remove('hor')

-- preview substituition live as you type
opt.inccommand = 'split'

-- case insentive search
opt.infercase = true
opt.ignorecase = true

-- make the jumplist behavior more intuitive
opt.jumpoptions = { 'view' }

-- make statusline global
opt.laststatus = 3

-- wrap lines at covenients points
opt.linebreak = true

-- enable mouse support for all modes
opt.mouse = 'a'

-- show line numbers
opt.number = true
opt.numberwidth = 3

-- preserve indent structure as much as possible
opt.preserveindent = true

-- make popup menu transparent
opt.pumblend = 12

-- make line numbers relative to current line
-- also is needed to make statuscolumn update properly
opt.relativenumber = true

-- save and restore options
vim.opt.sessionoptions = {
  'blank',
  'buffers',
  'curdir',
  'folds',
  'globals',
  'localoptions',
  'skiprtp',
  'resize',
  'tabpages',
  'winpos',
  'winsize',
}

-- round indentation with `>` (and `<`) to shiftwidth
opt.shiftround = true

-- use the same value of 'tabstop' as indentation size
opt.shiftwidth = 0

-- disable some startup messages
opt.shortmess:append({ W = true, I = true, c = true, C = true })

-- always show signcolumn
opt.signcolumn = 'yes'

-- make search case-sensitive if pattern contain upper case letters
opt.smartcase = true

-- insert indents automatically
opt.smartindent = true

opt.smoothscroll = true

-- window split behavior
opt.splitbelow = true
opt.splitkeep = 'screen'
opt.splitright = true

-- disable swap file
opt.swapfile = false

-- number of space that <tab> count
opt.tabstop = 4

-- enable true color support
opt.termguicolors = true

-- column width
vim.opt.textwidth = 80

-- set terminal title to show filaname and path
opt.title = true

-- automatically saves undo history to a file
opt.undofile = true
opt.undolevels = 10000

-- save content to swap files after 0.4 seconds without typing
opt.updatetime = 400

-- allow cursor to move there is no text in visual block mode
opt.virtualedit = 'block'

-- completion mode
opt.wildmode = { 'longest:full', 'full' }

-- default border for a floating window
opt.winborder = 'single'

-- minimum window width
opt.winminwidth = 8

-- don't wrap line
opt.wrap = false

-- don't backup file before saving
opt.writebackup = false
