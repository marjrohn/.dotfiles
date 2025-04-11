function Linemode:size_and_mtime()
  local time = math.floor(self._file.cha.mtime or 0)
  if time == 0 then
    time = ""
  else
    time = os.date("%b %d %Y", time)
  end

  local size = self._file:size()
  return string.format("%s %s", size and ya.readable_size(size) or "-", time)
end

Status:children_add(function(self)
  local h = self._current.hovered
  if h and h.link_to then
    return "  " .. tostring(h.link_to)
  else
    return ""
  end
end, 3300, Status.LEFT)

if os.getenv("NVIM") then
  require("no-status").setup()
else
  require("full-border"):setup({
    type = ui.Border.PLAIN,
  })
end
