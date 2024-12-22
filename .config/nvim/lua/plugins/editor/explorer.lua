local helpers = require('local.helpers')
local nmap

local mini_files = { 'echasnovski/mini.files', opts = {}, keys = {} }

mini_files.opts = {
  window = {
    preview = true,
    width_focus = 30,
    width_preview = 30,
  },
  options = { use_as_default_explorer = false },
}

nmap = helpers.mapping({ mode = 'n', key_list = mini_files.keys })
nmap('<leader>ef', function()
  require('mini.files').open(vim.api.nvim_buf_get_name(0), true)
end, { desc = 'Open MiniFiles (file)' })

nmap('<leader>eF', function()
  require('mini.files').open(vim.uv.cwd(), true)
end, { desc = 'Open MiniFiles (cwd)' })

function mini_files.config(_, opts)
  require('mini.files').setup(opts)

  local show_dotfiles = false

  local filter_show = function()
    return true
  end

  local filter_hide = function(fs_entry)
    return not vim.startswith(fs_entry.name, '.')
  end

  local toggle_dotfiles = function()
    local new_filter = show_dotfiles and filter_show or filter_hide

    show_dotfiles = not show_dotfiles

    require('mini.files').refresh({ content = { filter = new_filter } })
  end

  vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniFilesBufferCreate',
    callback = function(event)
      local buf_id = event.data.buf_id
      nmap(
        'g.',
        toggle_dotfiles,
        { buffer = buf_id, desc = 'Toggle Hidden Files' }
      )
    end,
  })
end

local yazi = { 'mikavilpas/yazi.nvim', opts = {}, keys = {} }
nmap = helpers.mapping({ mode = 'n', key_list = yazi.keys })

nmap('<leader>ey', '<cmd>Yazi<cr>', { desc = 'Open Yazi (file)' })
nmap('<leader>eY', '<cmd>yazi cwd<cr>', { desc = 'Open yazi (cwd)' })
nmap('<leader>ty', '<cmd>Yazi toggle<cr>', { desc = 'Toggle yazi ' })

return { mini_files, yazi }
