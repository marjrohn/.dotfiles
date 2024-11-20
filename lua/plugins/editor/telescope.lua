local spec = {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },
  cmd = 'Telescope',
  opts = { extensions = {} },
  keys = {},
}

--- options
spec.opts.defaults = {
  file_ignore_patterns = { '^%.git[/\\]', '[/\\]%.git[/\\]' },
  path_display = { 'filename_first', 'truncate' },
  sorting_strategy = 'ascending',
  layout_strategy = 'flex',
  layout_config = {
    width = 0.87,
    height = 0.80,
    horizontal = { prompt_position = 'top', preview_width = 0.45 },
    vertical = { mirror = false },
    preview_cutoff = 120,
  },
}
---

--- Keymaps
local helpers = require('local.helpers')
local nmap = helpers.map({ mode = 'n', key_list = spec.keys })

-- Find
nmap('<leader>:', function()
  require('telescope.builtin').command_history()
end, { desc = 'Command History' })

nmap('<leader>/', function()
  require('telescope.builtin').search_history()
end, { desc = 'Search History' })

nmap('<leader>f<cr>', function()
  require('telescope.builtin').resume()
end, { desc = 'Resume Last Search' })

nmap("<leader>f'", function()
  require('telescope.builtin').marks()
end, { desc = 'Find Marks' })

nmap('<leader>f/', function()
  require('telescope.builtin').current_buffer_fuzzy_find()
end, { desc = 'Find Words in Current Buffer' })

nmap('<leader>fb', function()
  require('telescope.builtin').buffers({ show_all_buffers = false })
end, { desc = 'Find Buffers' })

nmap('<leader><leader>', function()
  require('telescope.builtin').buffers({ show_all_buffers = false })
end, { desc = 'Find Buffers' })

nmap('<leader>ff', function()
  require('telescope.builtin').find_files()
end, { desc = 'Find Files' })

nmap('<leader>fF', function()
  require('telescope.builtin').find_files({ hidden = true, no_ignore = true })
end, { desc = 'Find All Files' })

nmap('<leader>fg', function()
  require('telescope.builtin').git_files()
end, { desc = 'Find Git Files' })

nmap('<leader>fh', function()
  require('telescope.builtin').help_tags()
end, { desc = 'Find Help' })

nmap('<leader>fk', function()
  require('telescope.builtin').keymaps()
end, { desc = 'Find Keymaps' })

nmap('<leader>fm', function()
  require('telescope.builtin').man_pages()
end, { desc = 'Find Man Pages' })

nmap('<leader>fo', function()
  require('telescope.builtin').oldfiles()
end, { desc = 'Find Old Files' })

nmap('<leader>fr', function()
  require('telescope.builtin').registers()
end, { desc = 'Find Registers' })

nmap('<leader>fT', function()
  require('telescope.builtin').tags()
end, { desc = 'Find Tags (cwd)' })

nmap('<leader>ft', function()
  require('telescope.builtin').current_buffer_tags()
end, { desc = 'Find Tags' })

nmap('<leader>fc', function()
  require('telescope.builtin').colorscheme({ enable_preview = true })
end, { desc = 'Find Colorschemes' })

nmap('<leader>fl', function()
  require('telescope.builtin').live_grep()
end, { desc = 'Live Grep' })

nmap('<leader>fw', function()
  require('telescope.builtin').grep_string()
end, { desc = 'Find Word Under Cursor' })

nmap('<leader>fL', function()
  require('telescope.builtin').live_grep({
    aditional_args = function(args)
      return vim.list_extend(args, { '--hidden', '--no-ignore' })
    end,
  })
end, { desc = 'Live Grep (All Files)' })

nmap('<leader>fW', function()
  require('telescope.builtin').grep_string({
    aditional_args = function(args)
      return vim.list_extend(args, { '--hidden', '--no-ignore' })
    end,
  })
end, { desc = 'Find Word Under Cursor (All Files)' })

-- Git
nmap('<leader>gb', function()
  require('telescope.builtin').git_branches({ use_file_path = true })
end, { desc = 'Git Branches' })

nmap('<leader>gc', function()
  require('telescope.builtin').git_commits({ use_file_path = true })
end, { desc = 'Git Commits (Repository)' })

nmap('<leader>gC', function()
  require('telescope.builtin').git_bcommits({ use_file_path = true })
end, { desc = 'Git Commits (Current File)' })

nmap('<leader>gs', function()
  require('telescope.builtin').git_status({ use_file_path = true })
end, { desc = 'Git Status' })

-- LSP
local augroup = helpers.augroup
local autocmd = helpers.autocmd

nmap('<leader>lD', function()
  require('telescope.builtin').diagnostics()
end, { desc = 'Find Diagnostics' })

autocmd('LspAttach', {
  group = augroup('telescope_lsp'),
  callback = function(event)
    local nmap = helpers.map({ mode = 'n', buffer = event.buf })

    -- Jump to the definition of the word under your cursor.
    nmap('<leader>ld', function()
      require('telescope.builtin').lsp_definitions()
    end, { desc = 'Goto To Definition' })

    -- Find references for the word under your cursor.
    nmap('<leader>lr', function()
      require('telescope.builtin').lsp_references()
    end, { desc = 'Goto References' })

    -- Jump to the implementation of the word under your cursor.
    nmap('<leader>li', function()
      require('telescope.builtin').lsp_implementations()
    end, { desc = 'Goto Implementation' })

    -- Jump to the type of the word under your cursor.
    nmap('<leader>ltd', function()
      require('telescope.builtin').lsp_type_definitions()
    end, { desc = 'Type Definition' })

    -- Fuzzy find all the symbols in your current document.
    nmap('<leader>ls', function()
      require('telescope.builtin').lsp_document_symbols()
    end, { desc = 'Document Symbols' })

    -- Fuzzy find all the symbols in your current workspace.
    nmap('<leader>lw', function()
      require('telescope.builtin').lsp_dynamic_workspace_symbols()
    end, { desc = 'Workspace Symbols' })
  end,
})
---

return spec
