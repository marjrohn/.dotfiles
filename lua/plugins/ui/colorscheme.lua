local colorschemes = {
  ['rose-pine'] = { 'rose-pine/neovim' },
  ['kanagawa'] = { 'rebelot/kanagawa.nvim' },
}

--- kanagawa config
local kanagawa = colorschemes['kanagawa']

kanagawa.variants = { 'kanagawa-wave', 'kanagawa-dragon', 'kanagawa-lotus' }

kanagawa.opts = {
  compile = true,
  terminalColors = not vim.o.termguicolors,
  colors = {
    theme = { all = { ui = { bg_gutter = 'none' } } },
  },
  background = { dark = 'dragon' },
  overrides = function(colors)
    local theme = colors.theme

    local makeDiagnosticColor = function(color)
      local c = require('kanagawa.lib.color')
      return { fg = color, bg = c(color):blend(theme.ui.bg, 0.95):to_hex() }
    end

    return {
      NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },

      LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
      MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },

      TelescopeTitle = { fg = theme.ui.special, bold = true },
      TelescopePromptNormal = { bg = theme.ui.bg_p1 },
      TelescopePromptBorder = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
      TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m1 },
      TelescopeResultsBorder = { fg = theme.ui.bg_m1, bg = theme.ui.bg_m1 },
      TelescopePreviewNormal = { bg = theme.ui.bg_dim },
      TelescopePreviewBorder = { bg = theme.ui.bg_dim, fg = theme.ui.bg_dim },

      Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
      PmenuSel = { fg = 'NONE', bg = theme.ui.bg_p2 },
      PmenuSbar = { bg = theme.ui.bg_m1 },
      PmenuThumb = { bg = theme.ui.bg_p2 },

      DiagnosticVirtualTextHint = makeDiagnosticColor(theme.diag.hint),
      DiagnosticVirtualTextInfo = makeDiagnosticColor(theme.diag.info),
      DiagnosticVirtualTextWarn = makeDiagnosticColor(theme.diag.warning),
      DiagnosticVirtualTextError = makeDiagnosticColor(theme.diag.error),

      LspReferenceText = { bg = 'none', underline = true },
      LspReferenceRead = { bg = 'none', underline = true },
    }
  end,
}
---

--- setup plugin spec

-- if not in the `colorchemes` table then try to load a builtin one
if not vim.iter(colorschemes):any(function(name)
  return name == vim.g.colorscheme
end) then
  local ok, _ = pcall(vim.cmd.colorscheme, 'vim.g.colorscheme')

  if not ok then
    vim.notify(string.format("Invalid colorscheme: '%s'.", vim.g.colorscheme), vim.log.levels.WARN)
  end
end

return vim
  .iter(colorschemes)
  :map(function(name, spec)
    local names = vim.deepcopy(spec.variants) or {}
    table.insert(names, 1, name)
    spec.variants = nil

    spec.name = name
    spec.lazy = false
    spec.priority = 1000
    spec.cond = vim.list_contains(names, vim.g.colorscheme)

    if spec.cond and not spec.config then
      function spec.config(_, opts)
        require(name).setup(opts)

        vim.cmd.colorscheme(vim.g.colorscheme)
      end
    end

    return spec
  end)
  :totable()
---
