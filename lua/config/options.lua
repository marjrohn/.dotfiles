-- [[ General Settings ]]

local g = vim.g
local opt = vim.opt

-- set leader to space key
g.mapleader = ' '
g.localmapleader = ' '

-- implematation in 'plugins/ui/colorscheme.lua'
g.colorscheme = 'kanagawa'

-- used by a auto command in 'config.autocmds.lua'
-- will make 'scrolloff' and 'sidescrolloff' relative
-- to window current width/height
g.sidescrolloff = 0.25
g.scrolloff = 0.25

-- silent providers warning when running ':checkhealth'
g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0
g.loaded_node_provider = 0

-- fix markdown indentation settings and enable folding
g.markdown_folding = 1
g.markdown_recommended_style = 0

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
  foldopen = '',
  foldclose = '',
  fold = ' ',
  foldsep = '│',
  diff = '╱',
  eob = ' ',
}

-- folding
opt.foldenable = true
opt.foldmethod = 'expr'
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

-- preserve indent structure as much as possible
opt.preserveindent = true

-- make popup menu transparent
opt.pumblend = 8

-- make line numbers relative to current line
opt.relativenumber = true

-- save and restore options
vim.opt.sessionoptions = {
  'blank',
  'buffers',
  'curdir',
  'folds',
  'globals',
  'skiprtp',
  'resize',
  'tabpages',
  'winpos',
  'winsize',
}

-- round indentation with '>' ('<') to shiftwidth
opt.shiftround = true

-- use the same value of 'tabstop' as indentation size
opt.shiftwidth = 0

-- disable some startup messages
opt.shortmess:append({ W = true, I = true, c = true, C = true })

-- always show signcolumn, otherwise it would shift the text each time
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

-- make float windows transparent
opt.winblend = 8

-- minimum window width
opt.winminwidth = 8

-- don't wrap line
opt.wrap = false

-- don't backup file before saving
opt.writebackup = false
