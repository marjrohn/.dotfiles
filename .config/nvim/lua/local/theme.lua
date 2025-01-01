local M = {}

---Get the current mode to be used in a UI component (e.g. statusline).
---
---@return 'normal'|'insert'|'visual'|'replace'|'command'
function M.get_mode()
  local mode = vim.fn.mode()

  if vim.list_contains({ 'i', 'ic', 'ix' }, mode) then
    return 'insert'
  end

  if vim.list_contains({ 'v', 'vs', 'V', 'Vs', '', 's', 's', 'S', '' }, mode) then
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

M.colors = {}

local function _validate(tbl)
  return vim.iter(tbl):all(function(ch)
    return tonumber(ch) and true or false
  end)
end

---@alias _colors.hex string|integer
---@alias _colors.rgb table<'r'|'g'|'b', integer>
---@alias _colors.xyz table<'x'|'y'|'z', integer>
---@alias _colors.lab table<'l'|'a'|'b', integer>
---@alias _colors.lch table<'l'|'c'|'h', integer>

---@param color _colors.hex
---@return boolean
function M.colors.check_hex(color)
  local _t = type(color)

  local res = _t == 'number'
  if not res then
    res = _t == 'string'
      and (color:match('^#?' .. string.rep('[0-9a-fA-F]', 6) .. '$') and true or false)
  end

  return res
end

---@param color _colors.rgb
---@return boolean
function M.colors.check_rgb(color)
  return _validate({ color.r, color.g, color.b })
end

---@param color _colors.xyz
---@return boolean
function M.colors.check_xyz(color)
  return _validate({ color.x, color.y, color.z })
end

---@param color _colors.lab
---@return boolean
function M.colors.check_lab(color)
  return _validate({ color.l, color.a, color.b })
end

---@param color _colors.lch
---@return boolean
function M.colors.check_lch(color)
  return _validate({ color.l, color.c, color.h })
end

---@param color _colors.hex
---@return integer
local function _hex2dec(color)
  local dec

  if type(color) == 'string' then
    dec = tonumber('0x' .. color:gsub('#', ''))
  else
    ---@diagnostic disable-next-line: param-type-mismatch
    dec = math.floor(tonumber(color))
  end

  ---@cast dec integer
  return dec
end

---@param color _colors.hex
---@return string
function M.colors.validate_hex(color)
  ---@diagnostic disable-next-line: param-type-mismatch
  return '#' .. string.format('%06x', math.min(math.max(_hex2dec(color), 0), 0xffffff))
end

---@param color _colors.rgb
---@return _colors.rgb
function M.colors.validate_rgb(color)
  return vim.tbl_map(function(ch)
    return math.floor(math.min(math.max(ch, 0), 255) + 0.5)
  end, { r = color.r, g = color.g, b = color.b })
end

---@param color _colors.xyz
---@return _colors.xyz
function M.colors.validate_xyz(color)
  return vim.tbl_map(function(ch)
    return math.min(math.max(ch, 0), 1)
  end, { x = color.x, y = color.y, z = color.z })
end

---@param color _colors.lab
---@return _colors.lab
function M.colors.validate_lab(color)
  local res = vim.tbl_map(function(ch)
    return math.min(math.max(ch, -128), 127)
  end, { a = color.a, b = color.b })

  res.l = math.min(math.max(color.l, 0), 100)

  return res
end

---@param color _colors.lch
---@return _colors.lch
function M.colors.validate_lch(color)
  local res = {}

  res.l = math.min(math.max(color.l, 0), 100)
  res.c = math.max(color.c, 0)
  res.h = math.min(math.max(color.h, 0), 360)

  return res
end

-- Helpers functions
---

---@param color _colors.hex
---@return _colors.rgb
local function _hex2rgb(color)
  local rgb_color = {}
  local d = _hex2dec(color)

  rgb_color.b = math.fmod(d, 256)
  rgb_color.g = math.fmod((d - rgb_color.b) / 256, 256)
  rgb_color.r = math.floor(d / 65536)

  return rgb_color
end

---@param color _colors.rgb
---@return _colors.hex
local function _rgb2hex(color)
  return string.format('#%02x%02x%02x', color.r, color.g, color.b)
end

---@param color _colors.rgb
---@return _colors.xyz
local function _rgb2xyz(color)
  local c = vim.tbl_map(function(ch)
    ch = ch / 255
    if ch > 0.04045 then
      return ((ch + 0.055) / 1.055) ^ 2.4
    end

    return ch / 12.92
  end, color)

  local xyz_color = {}
  xyz_color.x = 0.4124564 * c.r + 0.3575761 * c.g + 0.1804375 * c.b
  xyz_color.y = 0.2126729 * c.r + 0.7151522 * c.g + 0.0721750 * c.b
  xyz_color.z = 0.0193339 * c.r + 0.1191920 * c.g + 0.9503041 * c.b

  return xyz_color
end

---@param color _colors.xyz
---@return _colors.rgb
local function _xyz2rgb(color)
  local c = { x = color.x, y = color.y, z = color.z }

  local rgb_color = {}
  -- stylua: ignore start
  rgb_color.r =  3.2404542 * c.x + -1.5371385 * c.y + -0.4985314 * c.z
  rgb_color.g = -0.9692660 * c.x +  1.8760108 * c.y +  0.0415560 * c.z
  rgb_color.b =  0.0556434 * c.x + -0.2040259 * c.y +  1.0572252 * c.z
  -- stylua: ignore end

  return vim.tbl_map(function(ch)
    if ch <= 0.0031308 then
      return 3294.6 * ch
    end

    return 269.025 * ch ^ 0.4166667 - 0.055
  end, rgb_color)
end

---@param color _colors.xyz
---@return _colors.lab
local function _xyz2lab(color)
  local lab_color = {}

  color.x = 1.05211 * color.x
  color.z = 0.91842 * color.z

  local f = vim.tbl_map(function(ch)
    if ch > 0.008856 then
      return ch ^ (1 / 3)
    end

    return 7.78706897 * ch + 0.13793103
  end, { x = color.x, y = color.y, z = color.z })

  lab_color.l = 116 * f.y - 16
  lab_color.a = 500 * (f.x - f.y)
  lab_color.b = 200 * (f.y - f.z)

  return lab_color
end

---@param color _colors.lab
---@return _colors.xyz
local function _lab2xyz(color)
  local xyz_color = {}
  local c = { l = color.l, a = color.a, b = color.b }

  xyz_color.y = (c.l + 16) / 116
  xyz_color.x = c.a / 500 + xyz_color.y
  xyz_color.z = xyz_color.y - c.b / 200

  xyz_color = vim.tbl_map(function(ch)
    if ch > 0.206893 then
      return ch ^ 3
    end

    return (ch - 0.13793103) / 7.78706897
  end, xyz_color)

  if c.l <= 7.99962480 then
    xyz_color.y = c.l / 903.3
  end

  xyz_color.x = xyz_color.x * 0.95047
  xyz_color.z = xyz_color.z * 1.08883

  return xyz_color
end

---@param color _colors.lab
---@return _colors.lch
local function _lab2lch(color)
  local lch_color = { l = color.l }

  lch_color.c = math.sqrt(color.a ^ 2 + color.b ^ 2)
  lch_color.h = 180 * math.atan2(color.b, color.a) / math.pi

  local h = lch_color.h
  lch_color.h = h >= 0 and h or h + 360

  return lch_color
end

---@param color _colors.lch
---@return _colors.lab
local function _lch2lab(color)
  local lab_color = { l = color.l }

  lab_color.a = color.c * math.cos(math.pi * color.h / 180)
  lab_color.b = color.c * math.sin(math.pi * color.h / 180)

  return lab_color
end
---

---Convert a color in `HEX` format to the `RGB` format.
---
---@param color _colors.hex color in `HEX` format.
---@return _colors.rgb? rgb_color color in `RGB` format or `nil` if `color` is invalid.
function M.colors.hex2rgb(color)
  ---@diagnostic disable-next-line: param-type-mismatch
  if not M.colors.check_hex(color) then
    return nil
  end

  return _hex2rgb(M.colors.validate_hex(color))
end

---Convert a color in `HEX` format to the `XYZ` format.
---
---@param color string color in `HEX` format.
---@return _colors.xyz? xyz_color color in `XYZ` format or `nil` if `color` is invalid.
function M.colors.hex2xyz(color)
  ---@diagnostic disable-next-line: param-type-mismatch
  if not M.colors.check_hex(color) then
    return nil
  end

  local hex_color = M.colors.validate_hex(color)
  local xyz_color = _rgb2xyz(_hex2rgb(hex_color))

  return M.colors.validate_xyz(xyz_color)
end

---Convert a color in `HEX` format to the `L*a*b*` format.
---
---@param color string color in `HEX` format.
---@return _colors.lab? lab_color color in `L*a*b*` format or `nil` if `color` is invalid.
function M.colors.hex2lab(color)
  ---@diagnostic disable-next-line: param-type-mismatch
  if not M.colors.check_hex(color) then
    return nil
  end

  local hex_color = M.colors.validate_hex(color)
  local xyz_color = M.colors.validate_xyz(_rgb2xyz(_hex2rgb(hex_color)))

  return M.colors.validate_lab(_xyz2lab(xyz_color))
end

---Convert a color in `HEX` format to the `LCH` format.
---
---@param color string color in `HEX` format.
---@return _colors.lch? lch_color color in `LCH` format or `nil` if `color` is invalid.
function M.colors.hex2lch(color)
  ---@diagnostic disable-next-line: param-type-mismatch
  if not M.colors.check_hex(color) then
    return nil
  end

  local hex_color = M.colors.validate_hex(color)
  local xyz_color = M.colors.validate_xyz(_rgb2xyz(_hex2rgb(hex_color)))
  local lab_color = M.colors.validate_lab(_xyz2lab(xyz_color))

  return M.colors.validate_lch(_lab2lch(lab_color))
end

---Convert a color in `RGB` format to the `HEX` format.
---
---@param color _colors.rgb color in `RGB` format.
---@return _colors.hex? hex_color color in `HEX` format or `nil` if `color` is invalid.
function M.colors.rgb2hex(color)
  if not M.colors.check_rgb(color) then
    return nil
  end

  return _rgb2hex(M.colors.validate_rgb(color))
end

---Convert a color in `RGB` format to the `XYZ` format.
---
---@param color _colors.rgb color in `RGB` format.
---@return _colors.xyz? xyz_color color in `XYZ` format or `nil` if `color` is invalid.
function M.colors.rgb2xyz(color)
  if not M.colors.check_rgb(color) then
    return nil
  end

  return M.colors.validate_xyz(_rgb2xyz(M.colors.validate_rgb(color)))
end

---Convert a color in `RGB` format to the `L*a*b*` format.
---
---@param color _colors.rgb color in `RGB` format.
---@return _colors.lab? lab_color color in `L*a*b*` format or `nil` if `color` is invalid.
function M.colors.rgb2lab(color)
  if not M.colors.check_rgb(color) then
    return nil
  end

  local rgb_color = M.colors.validate_rgb(color)
  local xyz_color = M.colors.validate_xyz(_rgb2xyz(rgb_color))

  return M.colors.validate_lab(_xyz2lab(xyz_color))
end

---Convert a color in `RGB` format to the `LCH` format.
---
---@param color _colors.rgb color in `RGB` format.
---@return _colors.lch? lch_color color in `LCH` format or `nil` if `color` is invalid.
function M.colors.rgb2lch(color)
  if not M.colors.check_rgb(color) then
    return nil
  end

  local rgb_color = M.colors.validate_rgb(color)
  local xyz_color = M.colors.validate_xyz(_rgb2xyz(rgb_color))
  local lab_color = M.colors.validate_lab(_xyz2lab(xyz_color))

  return M.colors.validate_lch(_lab2lch(lab_color))
end

---Convert a color in `XYZ` format to the `HEX` format.
---
---@param color _colors.xyz color in `XYZ` format.
---@return _colors.hex? hex_color color in `HEX` format or `nil` if `color` is invalid.
function M.colors.xyz2hex(color)
  if not M.colors.check_xyz(color) then
    return nil
  end

  local xyz_color = M.colors.validate_xyz(color)
  local rgb_color = M.colors.validate_rgb(_xyz2rgb(xyz_color))

  return _rgb2hex(rgb_color)
end

---Convert a color in `XYZ` format to the `RGB` format.
---
---@param color _colors.xyz color in `XYZ` format.
---@return _colors.rgb? rgb_color color in `RGB` format or `nil` if `color` is invalid.
function M.colors.xyz2rgb(color)
  if not M.colors.check_xyz(color) then
    return nil
  end

  return M.colors.validate_rgb(_xyz2rgb(M.colors.validate_xyz(color)))
end

---Convert a color in `XYZ` format to the `L*a*b*` format.
---
---@param color _colors.xyz color in `XYZ` format.
---@return _colors.lab? lab_color color in `L*a*b*` format or `nil` if `color` is invalid.
function M.colors.xyz2lab(color)
  if not M.colors.check_xyz(color) then
    return nil
  end

  return M.colors.validate_lab(_xyz2lab(M.colors.validate_xyz(color)))
end

---Convert a color in `XYZ` format to the `LCH` format.
---
---@param color _colors.xyz color in `XYZ` format.
---@return _colors.lch? lch_color color in `LCH` format or `nil` if `color` is invalid.
function M.colors.xyz2lch(color)
  if not M.colors.check_xyz(color) then
    return nil
  end

  local xyz_color = M.colors.validate_xyz(color)
  local lab_color = M.colors.validate_lab(_xyz2lab(xyz_color))

  return M.colors.validate_lch(_lab2lch(lab_color))
end

---Convert a color in `L*a*b*` format to the `HEX` format.
---
---@param color _colors.lab color in `L*a*b*` format.
---@return _colors.hex? hex_color color in `HEX` format or `nil` if `color` is invalid.
function M.colors.lab2hex(color)
  if not M.colors.check_lab(color) then
    return nil
  end

  local lab_color = M.colors.validate_lab(color)
  local xyz_color = M.colors.validate_xyz(_lab2xyz(lab_color))
  local rgb_color = M.colors.validate_rgb(_xyz2rgb(xyz_color))

  return _rgb2hex(rgb_color)
end

---Convert a color in `L*a*b*` format to the `RGB` format.
---
---@param color _colors.lab color in `L*a*b*` format.
---@return _colors.rgb? rgb_color color in `RGB` format or `nil` if `color` is invalid.
function M.colors.lab2rgb(color)
  if not M.colors.check_lab(color) then
    return nil
  end

  local lab_color = M.colors.validate_lab(color)
  local xyz_color = M.colors.validate_xyz(_lab2xyz(lab_color))

  return M.colors.validate_rgb(_xyz2rgb(xyz_color))
end

---Convert a color in `L*a*b*` format to the `XYZ` format.
---
---@param color _colors.lab color in `L*a*b*` format.
---@return _colors.xyz? xyz_color color in `XYZ` format or `nil` if `color` is invalid.
function M.colors.lab2xyz(color)
  if not M.colors.check_lab(color) then
    return nil
  end

  return M.colors.validate_xyz(_lab2xyz(M.colors.validate_lab(color)))
end

---Convert a color in `L*a*b*` format to the `LCH` format.
---
---@param color _colors.lab color in `L*a*b*` format.
---@return _colors.lch? lch_color color in `LCH` format or `nil` if `color` is invalid.
function M.colors.lab2lch(color)
  if not M.colors.check_lab(color) then
    return nil
  end

  return M.colors.validate_lch(_lab2lch(M.colors.validate_lab(color)))
end

---Convert a color in `LCH` format to the `HEX` format.
---
---@param color _colors.lch color in `LCH` format.
---@return _colors.hex? hex_color color in `HEX` format or `nil` if `color` is invalid.
function M.colors.lch2hex(color)
  if not M.colors.check_lch(color) then
    return nil
  end

  local lch_color = M.colors.validate_lch(color)
  local lab_color = M.colors.validate_lab(_lch2lab(lch_color))
  local xyz_color = M.colors.validate_xyz(_lab2xyz(lab_color))
  local rgb_color = M.colors.validate_rgb(_xyz2rgb(xyz_color))

  return _rgb2hex(rgb_color)
end

---Convert a color in `LCH` format to the `RGB` format.
---
---@param color _colors.lch color in `LCH` format.
---@return _colors.rgb? rgb_color color in `RGB` format or `nil` if `color` is invalid.
function M.colors.lch2rgb(color)
  if not M.colors.check_lch(color) then
    return nil
  end

  local lch_color = M.colors.validate_lch(color)
  local lab_color = M.colors.validate_lab(_lch2lab(lch_color))
  local xyz_color = M.colors.validate_xyz(_lab2xyz(lab_color))

  return M.colors.validate_rgb(_xyz2rgb(xyz_color))
end

---Convert a color in `LCH` format to the `XYZ` format.
---
---@param color _colors.lch color in `LCH` format.
---@return _colors.xyz? xyz_color color in `XYZ` format or `nil` if `color` is invalid.
function M.colors.lch2xyz(color)
  if not M.colors.check_lch(color) then
    return nil
  end

  local lch_color = M.colors.validate_lch(color)
  local lab_color = M.colors.validate_lab(_lch2lab(lch_color))

  return M.colors.validate_xyz(_lab2xyz(lab_color))
end

---Convert a color in `LCH` format to the `L*a*b*` format.
---
---@param color _colors.lch color in `LCH` format.
---@return _colors.lab? lab_color color in `L*a*b*` format or `nil` if `color` is invalid.
function M.colors.lch2lab(color)
  if not M.colors.check_lch(color) then
    return nil
  end

  return M.colors.validate_lab(_lch2lab(M.colors.validate_lch(color)))
end

---Blend a color with the background. Return `nil` if `color` or `background` are invalid.
---
---@param color _colors.hex color in `HEX` format.
---@param background _colors.hex color in `HEX` format.
---@param alpha number? value between 0 and 1. Default to 0.5.
---@return _colors.hex?
function M.colors.blend(color, background, alpha)
  local rgb_color = M.colors.hex2rgb(color)
  local rgb_background = M.colors.hex2rgb(background)

  if not rgb_color or not rgb_background then
    return nil
  end

  local a = alpha and type(alpha) == 'number' and math.min(math.max(alpha, 1), 0) or 0.5

  local blended = {}
  for _, ch in ipairs({ 'r', 'g', 'b' }) do
    local fg = rgb_color[ch]
    local bg = rgb_background[ch]

    blended[ch] = (1 - a) * fg + a * bg
  end

  return M.colors.rgb2hex(M.colors.validate_rgb(blended))
end

---@deprecated
function M.hex_to_rgb(hex)
  if type(hex) == 'number' then
    hex = string.format('#%06x', hex)
  end

  return vim.tbl_map(function(channel)
    return tonumber('0x' .. channel)
  end, { r = hex:sub(2, 3), g = hex:sub(4, 5), b = hex:sub(6, 7) })
end

---@deprecated
function M.rgb_to_hex(rgb)
  return string.format('#%02x%02x%02x', rgb.r, rgb.g, rgb.b)
end

---@deprecated
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

---@deprecated
function M.gen_lualine_theme(colorscheme)
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
