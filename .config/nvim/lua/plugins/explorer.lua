local yazi = { 'mikavilpas/yazi.nvim', keys = {} }

local state = {
  open = false,
  reopen = false,
}

---@module 'yazi'
---@type YaziConfig
yazi.opts = {
  clipboard_register = '+',
  enable_mouse_support = true,
  integrations = {
    grep_in_directory = 'fzf-lua',
    grep_in_selected_files = 'fzf-lua',
  },
  -- highlight_hovered_buffers_in_same_directory = false,
  highlight_groups = {
    hovered_buffer = { fg = 'none', bg = 'none' },
  },
  ---@diagnostic disable-next-line: missing-fields
  hooks = {
    -- properly center the window taking the border in consideration
    yazi_opened = function()
      local win = vim.api.nvim_get_current_win()
      local win_cfg = vim.api.nvim_win_get_config(win)
      local has_border = not vim.tbl_contains({ '', 'none' }, win_cfg.border or vim.o.winborder)
      local factor_scale = {
        width = vim.g.win_width,
        height = vim.g.win_height,
      }

      win_cfg.title = { { ' Yazi ', 'YaziFloatTitle' } }
      win_cfg.title_pos = 'center'

      local function round(x)
        return math.floor(x + 0.5)
      end

      win_cfg.anchor = 'NW'
      -- floor will keep the window close to the top
      win_cfg.row = math.floor(0.5 * (1 - factor_scale.height) * vim.o.lines)
      win_cfg.col = round(0.5 * (1 - factor_scale.width) * vim.o.columns)
      win_cfg.width = round(vim.o.columns * factor_scale.width - (has_border and 2 or 0))
      win_cfg.height = round(vim.o.lines * factor_scale.height - (has_border and 2 or 0))

      vim.api.nvim_win_set_config(win, win_cfg)

      state.open = true
    end,

    yazi_closed_successfully = function()
      state.open = false
      -- open yazi again to force the window to resize
      -- `reopen` state is setting when neovim itself resize
      -- we could resize the yazi win, but this breaks the layout
      if state.reopen then
        state.reopen = false
        vim.schedule(function()
          require('yazi').toggle()
        end)
      end
    end,
  },
  yazi_floating_window_border = 'single',
}

local helpers = require('local.helpers')
local autocmd = helpers.autocmd
local augroup = helpers.augroup
local nmap = helpers.mapping({ mode = 'n', key_list = yazi.keys })

nmap('<leader>e', '<cmd>Yazi toggle<cr>', { desc = 'Open Yazi' })
nmap('<leader>E', '<cmd>yazi cwd<cr>', { desc = 'Open Yazi (cwd)' })

autocmd('ColorScheme', {
  group = augroup('yazi_float_border'),
  callback = function()
    vim.cmd.highlight('YaziFloatBorder guibg=bg guifg=' .. vim.g.terminal_color_6)
    vim.cmd.highlight('YaziFloatTitle gui=bold,italic guibg=bg guifg=' .. vim.g.terminal_color_14)
  end,
})

autocmd('VimResized', {
  group = augroup('yazi_win_resize'),
  callback = function()
    if state.open then
      vim.api.nvim_feedkeys('q', 'm', false) -- close yazi
      state.reopen = true -- opens again as soon as it closes and thus resizes
    end
  end,
})

return yazi
