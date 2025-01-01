local M = {}

function M.buf_list()
  return vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_valid(buf)
      and vim.api.nvim_get_option_value('buflisted', { buf = buf })
  end, vim.api.nvim_list_bufs())
end

function M.buf_remove(buf)
  local buflist = M.buf_list()

  if buf == nil or buf == 0 then
    buf = vim.api.nvim_get_current_buf()
  elseif not vim.list_contains(buflist, buf) then
    return
  end

  if #buflist == 1 then
    if vim.api.nvim_buf_get_name(buf) ~= '' then
      vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, false))
    else
      return
    end
  else
    local number = vim
      .iter(ipairs(buflist))
      :map(function(n, _buf)
        if _buf == buf then
          return n
        end
      end)
      :next()

    number = number - 1
    number = (number > 0) and number or #buflist

    vim.api.nvim_win_set_buf(0, buflist[number])
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
