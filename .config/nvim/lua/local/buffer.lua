local M = {}

function M.buf_list()
  return vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_valid(buf)
      and vim.api.nvim_get_option_value('buflisted', { buf = buf })
  end, vim.api.nvim_list_bufs())
end

function M.buf_remove(buf)
  local buflist = M.buf_list()
  local current_buf = vim.api.nvim_get_current_buf()

  if buf == nil or buf == 0 then
    buf = current_buf
  elseif not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  if not vim.list_contains(buflist, buf) then
    return
  end

  if #buflist == 1 and vim.api.nvim_buf_get_name(buf) == '' then
    return
  end

  if buf ~= current_buf then
    vim.api.nvim_buf_delete(buf, {})
    return
  end

  if #buflist == 1 then
    vim.cmd('enew')
  elseif buf == buflist[1] then
    vim.cmd('bnext')
  else
    vim.cmd('bprevious')
  end

  vim.api.nvim_buf_delete(buf, {})
end

function M.buf_only()
  local current_buf = vim.api.nvim_get_current_buf()

  vim
    .iter(M.buf_list())
    :filter(function(buf)
      return buf ~= current_buf
    end)
    :each(function(buf)
      vim.api.nvim_buf_delete(buf, {})
    end)
end

return M
