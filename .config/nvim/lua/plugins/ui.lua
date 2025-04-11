local autocmd = require('local.helpers').autocmd
local augroup = require('local.helpers').augroup
local icons = require('config.icons')

-- set terminal colors for the default theme
-- TODO: also need to set for `vim` colorscheme
autocmd('ColorScheme', {
  pattern = { 'default' },
  group = augroup('default_terminal_colors'),
  callback = function()
    local function get_color(name)
      return string.format('#%06x', vim.api.nvim_get_color_by_name(name))
    end

    -- stylua: ignore start
    vim.g.terminal_color_0  = get_color('NvimDarkGrey1')
    vim.g.terminal_color_1  = get_color('NvimDarkRed')
    vim.g.terminal_color_2  = get_color('NvimDarkGreen')
    vim.g.terminal_color_3  = get_color('NvimDarkYellow')
    vim.g.terminal_color_4  = get_color('NvimDarkBlue')
    vim.g.terminal_color_5  = get_color('NvimDarkMagenta')
    vim.g.terminal_color_6  = get_color('NvimDarkCyan')
    vim.g.terminal_color_7  = get_color('NvimLightGrey4')

    vim.g.terminal_color_8  = get_color('NvimDarkGrey4')
    vim.g.terminal_color_9  = get_color('NvimLightRed')
    vim.g.terminal_color_10 = get_color('NvimLightGreen')
    vim.g.terminal_color_11 = get_color('NvimLightYellow')
    vim.g.terminal_color_12 = get_color('NvimLightBlue')
    vim.g.terminal_color_13 = get_color('NvimLightMagenta')
    vim.g.terminal_color_14 = get_color('NvimLightCyan')
    vim.g.terminal_color_15 = get_color('NvimLightGrey1')
    -- stylua: ignore end
  end,
})

-- expose theme to vim.ui_theme. Will be assumed that the coloscheme set
-- vim.g.terminal_color_* (usually configurable by the colorscheme plugin)
autocmd('ColorScheme', {
  group = augroup('define_ui_theme'),
  callback = function()
    local is_light = vim.o.background == 'light'
    -- stylua: ignore
    vim.g.ui_theme = {
      normal  = vim.g['terminal_color_' .. (is_light and 8  or 7 )],
      insert  = vim.g['terminal_color_' .. (is_light and 4  or 12)],
      replace = vim.g['terminal_color_' .. (is_light and 3  or 11)],
      visual  = vim.g['terminal_color_' .. (is_light and 5  or 13)],
      command = vim.g['terminal_color_' .. (is_light and 1  or 9 )],
      text    = vim.g['terminal_color_' .. (is_light and 15 or 0 )],
    }

    vim.cmd.highlight(string.format('FloatBorder guifg=%s', vim.g.ui_theme.normal))
    vim.cmd.highlight(
      string.format(
        'FloatTitle guibg=%s guifg=%s gui=bold',
        vim.g.ui_theme.normal,
        vim.g.ui_theme.text
      )
    )
  end,
})

-- clear vim.g.ui_theme before a new coloscheme is loaded
autocmd('ColorSchemePre', {
  group = augroup('clear_ui_theme'),
  callback = function()
    local theme = {}

    for i = 0, 15 do
      theme['terminal_color_' .. i] = 'NONE'
    end

    vim.ui_theme = theme
  end,
})

local onedark = { 'navarasu/onedark.nvim', lazy = true }

-- create colorscheme for each style (only `onedark` is available)
-- e.g. to load `warmer` flavor run `:colorscheme onedark-warmer`
onedark.build = [[
for style in dark darker cool deep warm warmer light; do
  file_path="colors/onedark-$style.lua"
  echo "local cfg = vim.g.onedark_config or {}" > $file_path
  echo "cfg.style = '$style'" >> $file_path
  echo "vim.g.onedark_config = cfg\n" >> $file_path
  cat colors/onedark.lua >> $file_path
done
]]

onedark.opts = {
  -- Main options --
  -- Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
  style = 'deep',
  -- Options are italic, bold, underline, none
  -- You can configure multiple style with comma separated, For e.g., keywords = 'italic,bold'
  code_style = {
    comments = 'italic',
    keywords = 'bold,italic',
    functions = 'italic',
    strings = 'none',
    variables = 'none',
  },
  -- Custom Highlights --
  colors = {},
  highlights = {
    FoldColumn = { bg = 'none' },
  },
  -- Plugins Config --
  diagnostics = {
    darker = true, -- darker colors for diagnostic
    undercurl = true, -- use undercurl instead of underline for diagnostics
  },
}

local ef_themes = {
  'oonamo/ef-themes.nvim',
  priority = 1000,
  lazy = false,
}

ef_themes.opts = {
  light = 'ef-frost',
  dark = 'ef-winter',
  styles = {
    keywords = { bold = true, italic = true },
    functions = { italic = true },

    pickers = 'borderless',
  },

  modules = {
    -- Enable/Disable highlights for a module
    -- See `h: ef-themes-modules` for the list of available modules
    blink = true,
    cmp = false,
    fzf = false,
    gitsigns = true,
    mini = true,
    neogit = true,
    render_markdown = false,
    semantic_tokens = true,
    snacks = true,
    telescope = false,
    treesitter = true,
    which_key = false,
  },

  -- Override specific highlights
  -- on_highlights = function()
  --   return {
  --     TabLineFill = { bg = 'none' }
  --   }
  -- end,
}

function ef_themes.config(_, opts)
  require('ef-themes').setup(opts)
  vim.cmd.colorscheme('ef-theme')
end

local lualine = {
  'nvim-lualine/lualine.nvim',
  opts = {},
}

lualine.opts.options = {
  globalstatus = vim.o.laststatus == 3,
  component_separators = '',
  section_separators = { left = '', right = '' },
}

lualine.opts.sections = {
  lualine_a = {
    {
      'mode',
      icon = icons.neovim,
      separator = { left = '', right = '' },
      padding = { left = 1, right = 0 },
    },
  },
  lualine_b = {
    { 'branch', icon = icons.git.branch },
  },
  lualine_c = {
    { '%=', padding = 0 },
    {
      'datetime',
      icon = icons.clock,
      style = '%H:%M ',
      separator = { left = '', right = '' },
      padding = 0,
      color = function()
        local mode = require('local.theme').get_mode()

        return 'lualine_a_' .. mode
      end,
    },
  },
  lualine_x = {},
  lualine_y = {
    {
      'filetype',
      fmt = function(name)
        return string.upper(name)
      end,
    },
  },
  lualine_z = {
    {
      function()
        local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))
        local max_lnum = vim.api.nvim_buf_line_count(0)

        local ruler
        if lnum == 1 then
          ruler = 'TOP'
        elseif lnum == max_lnum then
          ruler = 'BOT'
        else
          ruler = string.format('%2d%%%%', math.floor(100 * lnum / max_lnum))
        end

        return string.format('%' .. string.len(vim.bo.textwidth) .. 'd %s', col + 1, ruler)
      end,
      separator = { left = '', right = '' },
      padding = { left = 0, right = 1 },
    },
  },
}

function lualine.config(_, opts)
  vim.opt.showmode = false
  vim.opt.fillchars:append({
    stl = '━',
    stlnc = '━',
  })

  local function lualine_theme()
    vim.cmd.highlight('clear StatusLine')

    local theme = {}
    local ui_theme = vim.g.ui_theme

    local normal = vim.api.nvim_get_hl(0, { link = false, name = 'Normal' })
    local stl_fg = normal.fg and string.format('#%06x', normal.fg) or 'NONE'

    for _, mode in pairs({
      'normal',
      'insert',
      'visual',
      'replace',
      'command',
    }) do
      theme[mode] = {
        a = { bg = ui_theme[mode], fg = ui_theme.text, gui = 'bold' },
        b = { bg = 'NONE', fg = stl_fg },
        c = { bg = 'NONE', fg = ui_theme[mode], gui = 'bold' },
      }
    end

    return theme
  end

  autocmd('ColorScheme', {
    group = augroup('lualine_reload'),
    callback = function()
      vim.defer_fn(
        vim.schedule_wrap(function()
          local cfg = require('lualine').get_config()
          cfg.options.theme = lualine_theme()
          -- force reload
          package.loaded.lualine = nil
          require('lualine').setup(cfg)
        end),
        100
      )
    end,
  })

  local theme = lualine_theme()

  opts.options = opts.options or {}
  opts.options.theme = theme

  require('lualine').setup(opts)
end

local tabby = {
  'nanozuki/tabby.nvim',
  event = 'UiEnter',
  cmd = 'Tabby',
  keys = {},
  opts = {},
}

tabby.opts = {
  line = function(line)
    local mode = require('local.theme').get_mode()
    local curr_tabnr = vim.fn.tabpagenr()
    local last_tabnr = vim.fn.tabpagenr('$')

    local left_sep = ''
    local right_sep = ''
    local sep_hl = 'tabby_sep'

    local diag_count = vim.diagnostic.count(0)

    return {
      hl = 'TabLineFill',

      {
        string.format(' %s %s ', icons.directory, vim.fn.fnamemodify(vim.fn.getcwd(0, 0), ':t')),
        hl = 'tabby_' .. mode,
      },
      line.tabs().foreach(function(tab)
        local tabnr = tab.number()
        local is_current = tab.is_current()
        local is_first_tab = tabnr == 1
        local is_last_tab = tabnr == last_tabnr
        local is_before = tabnr <= curr_tabnr
        local is_after = tabnr >= curr_tabnr

        local icon = is_current and icons.tab.active or icons.tab.inactive

        local _, win = pcall(vim.api.nvim_tabpage_get_win, tabnr)
        local _, buf = pcall(vim.api.nvim_win_get_buf, win)
        local ok, modified = pcall(vim.api.nvim_get_option_value, 'modified', { buf = buf })

        if ok then
          modified = modified
            and (is_current and icons.file.modified_active or icons.file.modified_inactive)
        else
          modified = nil
        end

        local hl = is_current and ('tabby_' .. mode) or 'TabLine'
        local sep_hl_inv = is_current and ('tabby_' .. mode .. '_inv') or 'TabLineInv'

        return {
          hl = hl,

          is_first_tab and { left_sep, hl = 'tabby_sep_' .. mode } or '',
          is_before and not is_first_tab and { left_sep, hl = sep_hl } or '',
          is_before and { left_sep, hl = sep_hl_inv } or '',
          (tabnr > curr_tabnr) and ' ' or '',
          (modified or icon) .. ' ',
          tabnr .. ': ',
          tab.name() .. ' ',
          tab.close_btn(icons.close),
          (tabnr < curr_tabnr) and ' ' or '',
          is_after and { right_sep, hl = sep_hl_inv } or '',
          (not is_last_tab) and is_after and { right_sep, hl = sep_hl } or '',
        }
      end),
      line.spacer(),
      diag_count[vim.diagnostic.severity.ERROR]
          and {
            icons.diagnostics.error .. ' ' .. diag_count[vim.diagnostic.severity.ERROR] .. ' ',
            hl = 'DiagnosticError',
          }
        or '',
      diag_count[vim.diagnostic.severity.WARN]
          and {
            icons.diagnostics.warn .. ' ' .. diag_count[vim.diagnostic.severity.WARN] .. ' ',
            hl = 'DiagnosticWarn',
          }
        or '',
      diag_count[vim.diagnostic.severity.INFO]
          and {
            icons.diagnostics.info .. ' ' .. diag_count[vim.diagnostic.severity.INFO] .. ' ',
            hl = 'DiagnosticInfo',
          }
        or '',
      diag_count[vim.diagnostic.severity.HINT]
          and {
            icons.diagnostics.hint .. ' ' .. diag_count[vim.diagnostic.severity.HINT] .. ' ',
            hl = 'DiagnosticHint',
          }
        or '',
    }
  end,
}

local function tabby_highlights()
  local ui_theme = vim.g.ui_theme
  local normal = vim.api.nvim_get_hl(0, { link = false, name = 'Normal' })
  local tabline = vim.api.nvim_get_hl(0, { link = false, name = 'TabLine' })
  local tabline_fill = vim.api.nvim_get_hl(0, { link = false, name = 'TabLineFill' })

  local tab_bg = tabline[tabline.reverse and 'fg' or 'bg'] or normal.bg
  local tabfill_bg = tabline_fill[tabline_fill.reverse and 'fg' or 'bg'] or normal.bg

  vim.api.nvim_set_hl(0, 'tabby_sep', {
    bg = tab_bg,
    fg = tabfill_bg,
  })

  vim.api.nvim_set_hl(0, 'TabLineInv', {
    bg = tabfill_bg,
    fg = tab_bg,
  })

  for _, mode in ipairs({
    'normal',
    'insert',
    'replace',
    'visual',
    'command',
  }) do
    vim.api.nvim_set_hl(0, 'tabby_' .. mode, {
      bg = ui_theme[mode],
      fg = ui_theme.text,
      bold = true,
    })
    vim.api.nvim_set_hl(0, 'tabby_sep_' .. mode, {
      bg = ui_theme[mode],
      fg = tabfill_bg,
    })
    vim.api.nvim_set_hl(0, 'tabby_' .. mode .. '_inv', {
      bg = tabfill_bg,
      fg = ui_theme[mode],
    })
  end
end

function tabby.config(_, opts)
  autocmd('ColorScheme', {
    group = augroup('tabby_highlights'),
    callback = function()
      -- defer to make sure vim.g.ui_theme is available
      vim.defer_fn(tabby_highlights, 100)
    end,
  })

  tabby_highlights()

  autocmd({ 'ModeChanged', 'BufModifiedSet', 'DiagnosticChanged' }, {
    group = augroup('tabby_redraw'),
    callback = function()
      vim.api.nvim__redraw({ tabline = true })
    end,
  })

  require('tabby').setup(opts)
  vim.opt.showtabline = 2 -- always show
end

local nmap = require('local.helpers').mapping({ mode = 'n', key_list = tabby.keys })

nmap('<leader><tab>r', function()
  vim.ui.input({ prompt = 'New Tab Name: ' }, function(input)
    if input then
      vim.cmd('Tabby rename_tab ' .. vim.trim(input))
    end
  end)
end, { desc = 'Rename Tab' })

nmap('<leader><tab>u', '<cmd>Tabby rename_tab<cr>', { desc = 'Undo Tab Rename' })

return {
  onedark,
  ef_themes,
  lualine,
  tabby,
}
