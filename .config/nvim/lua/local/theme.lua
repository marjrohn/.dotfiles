local M = {}

M.get_mode = function()
  local mode = vim.fn.mode()

  if vim.list_contains({ 'i', 'ic', 'ix' }, mode) then
    return 'insert'
  end

  -- '\22' is CTRL-V (see `h: nvim_replace_termcodes()`)
  if
    vim.list_contains(
      { 'v', 'vs', 'V', 'Vs', '\22', '\22s', 's', 'S', 'CTRL-S' },
      mode
    )
  then
    return 'visual'
  end

  if vim.list_contains({ 'R', 'Rc', 'Rv', 'Rvc', 'Rvx' }, mode) then
    return 'replace'
  end

  if vim.list_contains({ 'c', 'cr', 'cv', 'cvr' }, mode) then
    return 'command'
  end

  return 'normal'
end

function M.hex_to_rgb(hex)
  if type(hex) == 'number' then
    hex = string.format('#%06x', hex)
  end

  return vim.tbl_map(function(channel)
    return tonumber('0x' .. channel)
  end, { r = hex:sub(2, 3), g = hex:sub(4, 5), b = hex:sub(6, 7) })
end

function M.rgb_to_hex(rgb)
  return string.format('#%02x%02x%02x', rgb.r, rgb.g, rgb.b)
end

function M.mix_colors(hex1, hex2, alpha)
  local new_color = {}

  alpha = math.min(math.max(alpha, 0), 1)
  local rgb1 = M.hex_to_rgb(hex1)
  local rgb2 = M.hex_to_rgb(hex2)

  vim.iter({ 'r', 'g', 'b' }):each(function(ch)
    new_color[ch] = (1 - alpha) * rgb1[ch] + alpha * rgb2[ch]
  end)

  return M.rgb_to_hex(new_color)
end

function M.gen_lualine_theme(colorscheme)
  colorscheme = colorscheme or vim.g.colorscheme

  local ok, _theme = pcall(require, 'lualine.themes.' .. colorscheme)

  if not ok then
    _theme = require('lualine.themes.auto')
  end

  local modes = {}
  local fg_base = _theme.normal.a.fg
  local fg_text = _theme.normal.b.fg
  local fg_muted = _theme.inactive.a.fg

  for _, mode in ipairs({
    'normal',
    'insert',
    'visual',
    'replace',
    'command',
    'inactive',
  }) do
    modes[mode] = _theme[mode].a.bg
  end

  local theme = {}

  for mode, color in pairs(modes) do
    local is_inactive = (mode == 'inactive')
    local fg_a = is_inactive and fg_muted or fg_base
    local fg_b = is_inactive and fg_muted or fg_text
    local gui = (not is_inactive) and 'bold'

    theme[mode] = {
      a = { bg = color, fg = fg_a, gui = gui },
      b = { bg = 'none', fg = fg_b },
      c = { bg = 'none', fg = color, gui = gui },
    }
  end

  return theme
end

return M
