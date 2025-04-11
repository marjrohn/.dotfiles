local M = {}

function M.buf_list()
  return vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_valid(buf)
      and vim.api.nvim_get_option_value('buflisted', { buf = buf })
  end, vim.api.nvim_list_bufs())
end

function M.buf_remove()
  local buflist = M.buf_list()
  local buf = vim.api.nvim_get_current_buf()
  local next_buf

  if #buflist == 1 then
    if vim.api.nvim_buf_get_name(buf) ~= '' then
      next_buf = vim.api.nvim_create_buf(true, false)
    else
      return
    end
  else
    -- stylua: ignore
    local number = vim.iter(ipairs(buflist)):map(function(n, _buf)
      if _buf == buf then
        return n
      end
    end):next()

    next_buf = buflist[1 + number % #buflist]
  end

  vim.api.nvim_win_set_buf(0, next_buf)
  -- workaround to avoid error msg, using `pcall` for some reason is not enough
  vim.v.errmsg = ''
  vim.cmd(string.format('silent! call v:lua.vim.api.nvim_buf_delete(%d, {})', buf))

  if vim.v.errmsg ~= '' and vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_win_set_buf(0, buf)

    vim.ui.input({ prompt = 'Failed to delete buffer, force? (y/N): ' }, function(input)
      input = vim.trim(input or ''):lower()

      if vim.tbl_contains({ 'n', 'no', '' }, input) then
        return
      end

      if vim.tbl_contains({ 'y', 'yes' }, input) then
        vim.api.nvim_win_set_buf(0, next_buf)
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
        return
      end

      vim.notify(
        "Invalid input: expected 'y'|'yes' (force) or 'n'|'no' (don't force).",
        vim.log.levels.WARN
      )
    end)
  end
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
