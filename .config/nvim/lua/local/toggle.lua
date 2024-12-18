local M = {}

function M.toggle_statusline()
  if vim.o.laststatus == 1 then
    if #vim.api.nvim_tabpage_list_wins(0) > 1 then
      vim.o.laststatus = 0
    else
      vim.o.laststatus = 3
    end
  elseif vim.o.laststatus == 2 then
    vim.o.laststatus = 0
  else
    -- cycle between 0 and 3
    vim.o.laststatus = 3 * ((vim.o.laststatus / 3 + 1) % 2)
  end
end

function M.toogle_tabline()
  if vim.showtabline == 1 then
    if #vim.api.nvim_list_tabpages() > 1 then
      vim.o.showtabline = 0
    else
      vim.o.showtabline = 2
    end
  else
    -- cycle between 0 and 2
    vim.o.showtabline = 2 * ((vim.o.showtabline / 2 + 1) % 2)
  end
end

return M
