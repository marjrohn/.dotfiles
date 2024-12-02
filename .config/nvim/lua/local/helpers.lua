local M = {}

function M.map(default_opts)
  default_opts = default_opts or {}

  local mode = default_opts.mode
  local key_list = default_opts.key_list

  default_opts.mode = nil
  default_opts.key_list = nil

  if key_list and type(key_list) ~= 'table' then
    error("Invalid 'key_list': Expected a table, got " .. type(key_list))
  end

  local _map = function(mode, lhs, rhs, opts)
    opts = vim.tbl_extend('keep', opts or {}, default_opts)

    if opts.silent == nil then
      opts.silent = true
    end

    if opts.remap then
      opts.noremap = false
    elseif opts.noremap == nil then
      opts.noremap = true
    end

    if key_list then
      opts.mode = mode
      table.insert(key_list, { lhs, rhs, opts })
    else
      vim.keymap.set(mode, lhs, rhs, opts)
    end
  end

  if mode then
    return function(lhs, rhs, opts)
      _map(mode, lhs, rhs, opts)
    end
  end

  return function(mode, lhs, rhs, opts)
    _map(mode, lhs, rhs, opts)
  end
end

function M.augroup(name, clear)
  if clear == nil then
    clear = true
  end

  return vim.api.nvim_create_augroup(name, { clear = clear })
end

M.autocmd = vim.api.nvim_create_autocmd

return M
