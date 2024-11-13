local M = {}

function M.map(opts_)
  opts_ = opts_ or {}
  local has_key_list = false

  if opts_.key_list then
    if type(opts_.key_list) ~= 'table' then
      error("'key_list' should be of type table, but got " .. type(opts_.key_list))
    end

    has_key_list = true
  end

  local _map = function(mode, lhs, rhs, opts)
    opts = vim.tbl_extend('keep', opts or {}, opts_)

    opts.key_list = nil

    if opts.silent == nil then
      opts.silent = true
    end

    if opts.remap then
      opts.noremap = false
    elseif opts.noremap == nil then
      opts.noremap = true
    end

    vim.keymap.set(mode, lhs, rhs, opts)

    if has_key_list then
      table.insert(opts_.key_list, lhs)
    end
  end

  if opts_.mode then
    local mode = opts_.mode
    opts_.mode = nil

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
