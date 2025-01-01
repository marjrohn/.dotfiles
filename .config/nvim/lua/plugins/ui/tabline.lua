local spec = { 'nanozuki/tabby.nvim' }

spec.opts = {
  line = function(line)
    local mode = require('local.theme').get_mode()
    local curr_tabnr = vim.fn.tabpagenr()
    local last_tabnr = vim.fn.tabpagenr('$')

    local icons = require('local.icons')
    local left_sep = ''
    local right_sep = ''
    local sep_hl_inv = 'tabby_tab_sep'

    -- don't show name of non current tab if the terminal was small width
    local show_name = last_tabnr <= math.floor(vim.o.columns / 24 + 0.5)

    local tabs_segment = line.tabs().foreach(function(tab)
      local tabnr = tab.number()
      local is_current = tab.is_current()
      local is_last_tab = tabnr == last_tabnr
      local is_before = (tabnr <= curr_tabnr)
      local is_after = (tabnr >= curr_tabnr)

      local name = (is_current or show_name) and tab.name() .. ' ' or ''
      local icon = is_current and icons.tab.active or icons.tab.inactive

      local hl = is_current and 'lualine_a_' .. mode or 'lualine_a_inactive'
      local sep_hl = 'lualine_c_' .. (is_current and mode or 'inactive')

      return {
        hl = hl,

        is_before and { left_sep, hl = sep_hl_inv },
        is_before and { left_sep, hl = sep_hl },
        is_after and not is_current and ' ',
        icon .. ' ',
        tabnr .. ': ',
        name,
        tab.close_btn(icons.close),
        is_before and not is_current and ' ',
        is_after and { right_sep, hl = sep_hl },
        (not is_last_tab) and is_after and { right_sep, hl = sep_hl_inv },
      }
    end)

    local severity = vim.diagnostic.severity
    local diag_count = vim.diagnostic.count(0)
    local diag_signs_segment = {
      ' ',
      diag_count[severity.ERROR]
          and {
            string.format('%s %d ', icons.diagnostics.error, diag_count[severity.ERROR]),
            hl = 'DiagnosticError',
          }
        or '',
      diag_count[severity.WARN]
          and {
            string.format('%s %d ', icons.diagnostics.warn, diag_count[severity.WARN]),
            hl = 'DiagnosticWarn',
          }
        or '',
      diag_count[severity.INFO]
          and {
            string.format('%s %d ', icons.diagnostics.info, diag_count[severity.INFO]),
            hl = 'DiagnosticInfo',
          }
        or '',
      diag_count[severity.HINT]
          and {
            string.format('%s %d ', icons.diagnostics.hint, diag_count[severity.HINT]),
            hl = 'DiagnosticHint',
          }
        or '',
    }
    return {
      hl = 'lualine_b_normal',

      { icons.tab.head, hl = 'tabby_tab_head' },
      tabs_segment,
      line.spacer(),
      diag_signs_segment,
    }
  end,
}

function spec.config(_, opts)
  vim.opt.showtabline = 2

  local tab_sep_fg = vim.api.nvim_get_hl(0, { name = 'Normal' }).bg
  local tab_sep_bg = vim.api.nvim_get_hl(0, { name = 'lualine_c_inactive' }).fg
  local head_fg = vim.api.nvim_get_hl(0, { name = 'lualine_c_command' }).fg

  vim.api.nvim_set_hl(0, 'tabby_tab_sep', { bg = tab_sep_bg, fg = tab_sep_fg })
  vim.api.nvim_set_hl(0, 'tabby_tab_head', { bg = tab_sep_bg, fg = head_fg })

  require('tabby').setup(opts)
end

return spec
