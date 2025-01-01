local palette = (function()
  local theme
  local p = { base16 = {} }
  local bg_type = vim.o.background == '' and 'dark' or vim.o.background

  local file = io.open(vim.fn.expand('$XDG_CONFIG_HOME/ghostty/config'))

  if not file then
    return
  end

  for line in file:lines() do
    if line:match('theme') then
      theme = vim.iter(vim.split(line:match('.-=(.-)$'), ',')):fold({}, function(tbl, name)
        name = vim.trim(name)
        if name:match('dark') then
          tbl.dark = name:match('dark:%s*(.-)')
        elseif name:match('light') then
          tbl.light = name:match('light:%s*(.-)')
        else
          tbl[bg_type] = name
        end

        return tbl
      end)
      break
    end
  end

  file:close()
  if not theme or not theme[bg_type] then
    return
  end

  local fmt_color = function(color)
    return '#' .. color:gsub('#', ''):lower()
  end
  local pattern1 = '.-=%s*([0-9][0-5]?)%s*=%s*(#?'
    .. string.rep('[0-9a-fA-F]', 6)
    .. ')%s*$'
  local pattern2 = '%s*([a-z%-]+)%s=%s*(#?' .. string.rep('[0-9a-fA-F]', 6) .. ')%s*$'

  file = io.open(vim.fn.expand('$XDG_DATA_HOME/ghostty/themes/' .. theme[bg_type]))

  if not file then
    return
  end

  for line in file:lines() do
    if line:match('palette') then
      local nr, color = line:match(pattern1)

      if not nr or not color then
        return
      end

      local base = string.format('base%02X', nr)
      p.base16[base] = fmt_color(color)
    else
      local name, color = line:match(pattern2)

      if not name or not color then
        return
      end

      p[name:gsub('-', '_')] = fmt_color(color)
    end
  end

  file:close()
  if not p then
    return
  end

  if not p.base16 then
    return
  end

  p.float_background = p.base16.base00
  p.float_foreground = p.base16.base05
  p.base16.base00 = p.background
  p.base16.base05 = p.foreground
  p.background = nil
  p.foreground = nil

  local b = vim.deepcopy(p.base16)
  p.base16.base01 = b.base0A
  p.base16.base08 = b.base09
  p.base16.base09 = b.base08
  p.base16.base0A = b.base01
  p.base16.base0B = b.base0E
  p.base16.base0C = b.base0D
  p.base16.base0D = b.base0C
  p.base16.base0E = b.base0B

  if -- validate
    not p.base16.base00
    or not p.base16.base01
    or not p.base16.base02
    or not p.base16.base03
    or not p.base16.base04
    or not p.base16.base05
    or not p.base16.base06
    or not p.base16.base07
    or not p.base16.base08
    or not p.base16.base09
    or not p.base16.base0A
    or not p.base16.base0B
    or not p.base16.base0C
    or not p.base16.base0D
    or not p.base16.base0E
    or not p.base16.base0F
    or not p.cursor_color
    or not p.cursor_text
    or not p.float_background
    or not p.float_foreground
    or not p.selection_background
    or not p.selection_foreground
  then
    return
  end

  return p
end)()

if not palette then
  palette = { -- catppuccin-mocha
    base16 = {
      base00 = '#1e1e2e',
      base01 = '#89d88b',
      base02 = '#a6e3a1',
      base03 = '#f9e2af',
      base04 = '#89b4fa',
      base05 = '#f5c2e7',
      base06 = '#94e2d5',
      base07 = '#a6adc8',
      base08 = '#585b70',
      base09 = '#f37799',
      base0A = '#f38ba8',
      base0B = '#ebd391',
      base0C = '#74a8fc',
      base0D = '#f2aede',
      base0E = '#6bd7ca',
      base0F = '#bac2de',
    },
    cursor_color = '#f5e0dc',
    cursor_text = '#cdd6f4',
    float_background = '#45475a',
    float_foreground = '#cdd6f4',
    selection_background = '#585b70',
    selection_foreground = '#cdd6f4',
  }
end

require('mini.base16').setup({
  palette = palette.base16,
  use_cterm = false,
  plugins = {
    default = false,
    ['echasnovski/mini.nvim'] = true,
    ['folke/trouble.nvim'] = true,
    ['HiPhish/rainbow-delimiters.nvim'] = true,
    ['kevinhwang91/nvim-ufo'] = true,
    ['lewis6991/gitsigns.nvim'] = true,
    -- ['NeogitOrg/neogit'] = true,
    ['nvim-lualine/lualine.nvim'] = true,
    ['rcarriga/nvim-dap-ui'] = true,
    ['rcarriga/nvim-notify'] = true,
    ['stevearc/aerial.nvim'] = true,
    -- ['williamboman/mason.nvim'] = true,
  },
})

local p = palette.base16
p.cur_fg = palette.cursor_text
p.cur_bg = palette.cursor_color
p.flt_bg = palette.float_background
p.flt_fg = palette.float_foreground
p.slt_bg = palette.selection_background
p.slt_fg = palette.selection_foreground

local function hi(group, args)
  local command
  if args.link ~= nil then
    command = string.format('highlight! link %s %s', group, args.link)
  else
    command = string.format(
      'highlight %s guifg=%s guibg=%s gui=%s guisp=%s blend=%s',
      group,
      args.fg or 'NONE',
      args.bg or 'NONE',
      args.attr or 'NONE',
      args.sp or 'NONE',
      args.blend or 'NONE'
    )
  end
  vim.cmd(command)
end

-- stylua: ignore start
-- overrides
--
hi('CurSearch',      { fg = p.base00, bg = p.base01, attr = nil,            sp = nil })
hi('Cursor',         { fg = p.cur_fg, bg = p.cur_bg, attr = nil,            sp = nil })
hi('CursorIM',       { fg = p.cur_fg, bg = p.cur_bg, attr = nil,            sp = nil })
hi('CursorLine',     { fg = nil,      bg = p.slt_bg, attr = nil,            sp = nil })
hi('CursorLineFold', { fg = p.cur_bg, bg = nil,      attr = 'bold',         sp = nil })
hi('CursorLineNr',   { fg = p.base07, bg = nil,      attr = 'bold',         sp = nil })
hi('CursorLineSign', { fg = p.base03, bg = nil,      attr = nil,            sp = nil })
hi('FloatBorder',    { fg = p.flt_fg, bg = p.flt_bg, attr = nil,         sp = nil })
hi('FloatTitle',     { fg = p.flt_bg, bg = p.flt_fg, attr = nil,            sp = nil })
hi('FloatFooter',    { fg = p.flt_bg, bg = p.flt_fg, attr = nil,            sp = nil })
hi('Folded',         { fg = p.slt_fg, bg = p.slt_bg, attr = nil,            sp = nil })
hi('FoldColumn',     { fg = p.cur_bg, bg = nil,      attr = 'bold',         sp = nil })
hi('IncSearch',      { fg = p.base00, bg = p.base01, attr = nil,            sp = nil })
hi('lCursor',        { fg = p.cur_fg, bg = p.cur_bg, attr = nil,            sp = nil })
hi('LineNr',         { fg = p.flt_bg, bg = nil,      attr = nil,            sp = nil })
hi('LineNrAbove',    { fg = p.flt_bg, bg = nil,      attr = nil,            sp = nil })
hi('LineNrBelow',    { fg = p.flt_bg, bg = nil,      attr = nil,            sp = nil })
hi('NormalFloat',    { fg = p.flt_fg, bg = p.flt_bg, attr = nil,            sp = nil })
hi('Pmenu',          { fg = p.flt_fg, bg = p.flt_bg, attr = nil,            sp = nil })
hi('PmenuExtra',     { fg = p.flt_fg, bg = p.flt_bg, attr = nil,            sp = nil })
hi('PmenuExtraSel',  { fg = p.flt_fg, bg = p.flt_bg, attr = 'reverse',      sp = nil })
hi('PmenuKind',      { fg = p.flt_fg, bg = p.flt_bg, attr = nil,            sp = nil })
hi('PmenuKindSel',   { fg = p.flt_fg, bg = p.flt_bg, attr = 'reverse',      sp = nil })
hi('PmenuMatch',     { fg = p.flt_fg, bg = p.flt_bg, attr = 'bold',         sp = nil })
hi('PmenuMatchSel',  { fg = p.flt_fg, bg = p.flt_bg, attr = 'bold,reverse', sp = nil })
hi('PmenuSel',       { fg = p.flt_fg, bg = p.flt_bg, attr = 'reverse',      sp = nil })
hi('Search',         { fg = p.base00, bg = p.base01, attr = nil,            sp = nil })
hi('SignColumn',     { fg = p.base03, bg = nil,      attr = nil,            sp = nil })
hi('StatusLine',     { fg = p.base04, bg = p.flt_bg, attr = nil,            sp = nil })
hi('StatusLineNC',   { fg = p.base03, bg = p.flt_bg, attr = nil,            sp = nil })
hi('Substitute',     { fg = p.base00, bg = p.base0A, attr = nil,            sp = nil })
hi('TabLine',        { fg = p.base03, bg = p.flt_bg, attr = nil,            sp = nil })
hi('TabLineFill',    { fg = p.base03, bg = nil,      attr = nil,            sp = nil })
hi('TabLineSel',     { fg = p.base0B, bg = p.flt_bg, attr = nil,            sp = nil })
hi('TermCursor',     { fg = p.cur_fg, bg = p.cur_bg, attr = nil,            sp = nil })
hi('TermCursorNC',   { fg = p.cur_fg, bg = p.cur_bg, attr = nil,            sp = nil })
hi('VertSplit',      { fg = p.flt_fg, bg = p.flt_bg, attr = nil,            sp = nil })
hi('Visual',         { fg = p.slt_fg, bg = p.slt_bg, attr = nil,            sp = nil })
hi('VisualNOS',      { fg = p.slt_fg, bg = p.slt_bg, attr = nil,            sp = nil })
hi('WinBar',         { fg = p.base04, bg = nil,      attr = nil,            sp = nil })
hi('WinBarNC',       { fg = p.base03, bg = nil,      attr = nil,            sp = nil })
hi('WinSeparator',   { fg = p.flt_fg, bg = p.flt_bg, attr = nil,            sp = nil })

hi('Boolean',     { fg = p.base08, bg = nil,      attr = 'bold',   sp = nil })
hi('Comment',     { fg = p.base09, bg = nil,      attr = 'italic', sp = nil })
hi('Conditional', { fg = p.base0C, bg = nil,      attr = 'bold',   sp = nil })
hi('Function',    { fg = p.base0C, bg = nil,      attr = 'bold', sp = nil })
hi('Identifier',  { fg = p.base0E, bg = nil,      attr = nil,      sp = nil })
hi('Keyword',     { fg = p.base0A, bg = nil,      attr = 'italic', sp = nil })
hi('Label',       { fg = p.base0A, bg = nil,      attr = 'bold',   sp = nil })
hi('Repeat',      { fg = p.base0C, bg = nil,      attr = 'bold',   sp = nil })
hi('Statement',   { fg = p.base08, bg = nil,      attr = 'bold',   sp = nil })
hi('Special',     { fg = p.base0D, bg = nil,      attr = nil,      sp = nil })
hi('String',      { fg = p.base0B, bg = nil,      attr = nil,      sp = nil })
hi('Todo',        { fg = p.base08, bg = p.base01, attr = 'bold',   sp = nil })

hi('DiagnosticFloatingError', { fg = p.base08, bg = p.flt_bg, attr = nil, sp = nil })
hi('DiagnosticFloatingHint',  { fg = p.base0D, bg = p.flt_bg, attr = nil, sp = nil })
hi('DiagnosticFloatingInfo',  { fg = p.base0C, bg = p.flt_bg, attr = nil, sp = nil })
hi('DiagnosticFloatingOk',    { fg = p.base0B, bg = p.flt_bg, attr = nil, sp = nil })
hi('DiagnosticFloatingWarn',  { fg = p.base0E, bg = p.flt_bg, attr = nil, sp = nil })

hi('DiagnosticSignError', { fg = p.base08, bg = nil, attr = nil, sp = nil })
hi('DiagnosticSignHint',  { fg = p.base0D, bg = nil, attr = nil, sp = nil })
hi('DiagnosticSignInfo',  { fg = p.base0C, bg = nil, attr = nil, sp = nil })
hi('DiagnosticSignOk',    { fg = p.base0B, bg = nil, attr = nil, sp = nil })
hi('DiagnosticSignWarn',  { fg = p.base0E, bg = nil, attr = nil, sp = nil })

hi('LspReferenceText',  { fg = nil, bg = nil, attr = 'underline,italic', sp = nil })
hi('LspReferenceRead',  { fg = nil, bg = nil, attr = 'underline,italic', sp = nil })
hi('LspReferenceWrite', { fg = nil, bg = nil, attr = 'underline,bold',   sp = nil })

hi('LspSignatureActiveParameter', { fg = p.base0E, bg = nil, attr = nil, sp = nil })
hi('LspCodeLens',                 { fg = p.base09, bg = nil, attr = nil, sp = nil })
hi('LspCodeLensSeparator',        { fg = p.base09, bg = nil, attr = nil, sp = nil })

hi('@attribute',           { link = 'Constant'    })
hi('@markup.environment',  { link = 'Keyword'     })
hi('@markup.heading',      { link = 'Function'    })
hi('@keyword.conditional', { link = 'Conditional' })
hi('@keyword.function',    { link = 'Function'    })
hi('@keyword.import',      { link = 'PreProc'     })
hi('@keyword.repeat',      { link = 'Repeat'      })
hi('@variable.parameter',  { link = 'Special'     })

hi("@lsp.mod.readonly", { link = "Constant" })
hi("@lsp.mod.typeHint", { link = "Type"     })

hi("@lsp.type.bitwise",         { link = "Operator"            })
hi("@lsp.type.builtinConstant", { link = "@constant.builtin"   })
hi("@lsp.type.comparison",      { link = "Operator"            })
hi("@lsp.type.const",           { link = "Constant"            })
hi("@lsp.type.decorator.rust",  { link = "PreProc"             })
hi("@lsp.type.lifetime",        { link = "Operator"            })
hi("@lsp.type.macro",           { link = "Macro"               })
hi("@lsp.type.method",          { link = "@function.method"    })
hi("@lsp.type.magicFunction",   { link = "@function.builtin"   })
hi("@lsp.type.namespace",       { link = "@module"             })
hi("@lsp.type.parameter",       { link = "@variable.parameter" })
hi("@lsp.type.punctuation",     { link = "Delimiter"           })
hi("@lsp.type.selfParameter",   { link = "@variable.builtin"   })

hi("@lsp.typemod.function.builtin",        { link = "@function.builtin"  })
hi("@lsp.typemod.function.defaultLibrary", { link = "@function.builtin"  })
hi("@lsp.typemod.keyword.documentation",   { link = "Special"            })
hi("@lsp.typemod.method.defaultLibrary",   { link = "@function.builtin"  })
hi("@lsp.typemod.operator.controlFlow",    { link = "@keyword.exception" })
hi("@lsp.typemod.variable.defaultLibrary", { link = "Special"            })
hi("@lsp.typemod.variable.injected",       { link = "@variable"          })
hi("@lsp.typemod.variable.global",         { link = "Constant"           })
hi("@lsp.typemod.variable.static",         { link = "Constant"           })

hi('@markup.math',  { link = 'Constant'   })
hi('@markup.quote', { link = 'Identifier' })
hi('@markup.raw',   { link = 'String'     })

hi("@function",                         { fg = p.base0C, bg = nil, attr = nil,      sp = nil })
hi("@function.builtin",                 { fg = p.base0C, bg = nil, attr = 'italic', sp = nil })
hi('@keyword.operator',                 { fg = p.base0A, bg = nil, attr = 'bold',   sp = nil })
hi('@keyword.return',                   { fg = p.base0A, bg = nil, attr = 'bold',   sp = nil })
hi('@keyword.exception',                { fg = p.base08, bg = nil, attr = 'bold',   sp = nil })
hi("@lsp.mod.global",                   { fg = p.base09, bg = nil, attr = 'bold',   sp = nil })
hi("@lsp.type.comment",                 { fg = nil,      bg = nil, attr = nil,      sp = nil })
hi("@lsp.type.function",                { fg = p.base0C, bg = nil, attr = nil,      sp = nil })
hi("@lsp.type.property",                { fg = nil,      bg = nil, attr = nil,      sp = nil })
hi("@lsp.type.variable",                { fg = nil,      bg = nil, attr = nil,      sp = nil })
hi("@lsp.typemod.function.declaration", { fg = p.base0C, bg = nil, attr = 'italic', sp = nil })
hi('@property',                         { fg = p.base0C, bg = nil, attr = 'italic', sp = nil })
hi('@variable',                         { fg = p.flt_fg, bg = nil, attr = nil,      sp = nil })
hi('@variable.builtin',                 { fg = p.base0E, bg = nil, attr = 'italic', sp = nil })
hi('@variable.member',                  { fg = p.base0E, bg = nil, attr = 'italic', sp = nil })

hi('@tag.attribute', { fg = p.base0C, bg = nil, attr = 'italic', sp = nil })
hi('@tag.delimiter', { fg = p.base0F, bg = nil, attr = nil,      sp = nil })

-- plugins
-- 
-- GitSigns
hi('GitSignsAdd',       { fg = p.base0B, bg = nil, attr = nil, sp = nil })
hi('GitSignsChange',    { fg = p.base0E, bg = nil, attr = nil, sp = nil })
hi('GitSignsDelete',    { fg = p.base08, bg = nil, attr = nil, sp = nil })
hi('GitSignsUntracked', { fg = p.base0D, bg = nil, attr = nil, sp = nil })
-- 
-- Mini
hi('MiniClueTitle', { link = 'FloatTitle' })
hi('MiniFilesTitleFocused', { link = 'FloatTitle' })

hi('MiniFilesTitle', { fg = p.flt_bg, bg = p.flt_fb, attr = nil, sp = nil })
hi('MiniPickBorderBusy', { fg = p.base0E, bg = p.flt_bg, attr = 'bold', sp = nil })
hi('MiniPickBorderText', { fg = p.base0D, bg = p.flt_bg, attr = 'bold', sp = nil })
hi('MiniPickPrompt', { fg = p.base0B, bg = p.flt_bg, attr = 'bold', sp = nil })
--
-- Notify
hi('NotifyDEBUGBody', { link = 'NormalFloat' })
hi('NotifyERRORBody', { link = 'NormalFloat' })
hi('NotifyINFOBody',  { link = 'NormalFloat' })
hi('NotifyTRACEBody', { link = 'NormalFloat' })
hi('NotifyWARNBody',  { link = 'NormalFloat' })

hi('NotifyDEBUGBorder', { fg = p.base03, bg = p.flt_bg, attr = nil, sp = nil })
hi('NotifyDEBUGIcon',   { fg = p.base03, bg = nil,      attr = nil, sp = nil })
hi('NotifyDEBUGTitle',  { fg = p.base03, bg = nil,      attr = nil, sp = nil })
hi('NotifyERRORBorder', { fg = p.base08, bg = p.flt_bg, attr = nil, sp = nil })
hi('NotifyERRORIcon',   { fg = p.base08, bg = nil,      attr = nil, sp = nil })
hi('NotifyERRORTitle',  { fg = p.base08, bg = nil,      attr = nil, sp = nil })
hi('NotifyINFOBorder',  { fg = p.base0C, bg = p.flt_bg, attr = nil, sp = nil })
hi('NotifyINFOIcon',    { fg = p.base0C, bg = nil,      attr = nil, sp = nil })
hi('NotifyINFOTitle',   { fg = p.base0C, bg = nil,      attr = nil, sp = nil })
hi('NotifyTRACEBorder', { fg = p.base0D, bg = p.flt_bg, attr = nil, sp = nil })
hi('NotifyTRACEIcon',   { fg = p.base0D, bg = nil,      attr = nil, sp = nil })
hi('NotifyTRACETitle',  { fg = p.base0D, bg = nil,      attr = nil, sp = nil })
hi('NotifyWARNBorder',  { fg = p.base0E, bg = p.flt_bg, attr = nil, sp = nil })
hi('NotifyWARNIcon',    { fg = p.base0E, bg = nil,      attr = nil, sp = nil })
hi('NotifyWARNTitle',   { fg = p.base0E, bg = nil,      attr = nil, sp = nil })
--
-- stylua: ignore end

vim.g.colors_name = 'ghostty'
