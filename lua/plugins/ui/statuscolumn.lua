local spec = { 'luukvbaal/statuscol.nvim', opts = {} }

function spec.config(_, opts)
  local builtin = require('statuscol.builtin')
  local ffi = require('statuscol.ffidef')

  local hl_range = 24
  local color1 = vim.api.nvim_get_hl(0, { name = 'CursorLineNr' }).fg
  local color2 = vim.api.nvim_get_hl(0, { name = 'LineNr' }).fg

  for i = 1, hl_range do
    vim.api.nvim_set_hl(0, 'RelLineNr' .. i, {
      fg = require('local.theme').mix_colors(color1, color2, math.sqrt(i / (hl_range + 1))),
    })
  end

  local cursor_fold = { level = 0, start = -1, end_ = -1 }

  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
    group = vim.api.nvim_create_augroup('Statuscol Fold', { clear = false }),
    callback = function(ev)
      if vim.tbl_contains(opts.ft_ignore or {}, vim.bo[ev.buf].filetype) then
        return
      end

      if not vim.wo.foldenable or vim.wo.foldcolumn == '0' then
        return
      end

      local line = vim.api.nvim_win_get_cursor(0)[1]
      local foldlevel = vim.fn.foldlevel(line)

      if foldlevel == 0 then
        cursor_fold.level = 0
        cursor_fold.start = -1
        cursor_fold.end_ = -1
      elseif line < cursor_fold.start or line > cursor_fold.end_ or foldlevel ~= cursor_fold.level then
        cursor_fold.level = foldlevel

        local foldstart = vim.fn.foldclosed(line)
        if foldstart ~= -1 then
          cursor_fold.start = foldstart
          cursor_fold.end_ = vim.fn.foldclosedend(line)
        else
          vim.cmd('silent! ' .. line .. 'foldclose')
          cursor_fold.start = vim.fn.foldclosed(line)
          cursor_fold.end_ = vim.fn.foldclosedend(line)
          vim.cmd('silent! ' .. line .. 'foldopen')
        end
      end
    end,
  })

  opts.segments = {}

  table.insert(opts.segments, {
    sign = {
      name = { '*' },
      -- take anything except diagnostics, since will be added after numbers
      namespace = { '^(?!.*diagnostic).*$' },
      colwidth = 1,
      wrap = true,
      foldclosed = true,
    },
    click = 'v:lua.ScSa',
  })

  local function get_hl(args)
    local hl = '%#LineNr#'

    if args.relnum == 0 then
      hl = '%#CursorLineNr#'
    elseif args.relnum <= hl_range then
      hl = '%#RelLineNr' .. args.relnum .. '#'
    end

    return hl
  end

  table.insert(opts.segments, {
    text = {
      function(args, segment)
        local buf = vim.api.nvim_win_get_buf(args.win)
        if
          vim.iter(vim.fn.sign_getplaced(buf, { group = '*', lnum = args.lnum })[1].signs):any(function(sign)
            local ns_id = vim.api.nvim_get_namespaces()[sign.group]

            if not ns_id then
              return false
            end

            local extmark = vim.api.nvim_buf_get_extmark_by_id(buf, ns_id, sign.id, { details = true })

            return extmark[3].number_hl_group and true or false
          end)
        then
          return builtin.lnumfunc(args, segment)
        end

        return '%*' .. get_hl(args) .. builtin.lnumfunc(args, segment) .. '%*'
      end,
      ' ',
    },
    click = 'v:lua.ScLa',
  })

  table.insert(opts.segments, {
    sign = {
      namespace = { 'diagnostic/signs' },
      colwidth = 1,
      maxwidth = 2,
      wrap = true,
      foldclosed = true,
    },
    click = 'v:lua.ScSa',
  })

  table.insert(opts.segments, {
    text = {
      function(args)
        local hl
        local foldinfo = ffi.C.fold_info(args.wp, args.lnum)
        local symbol = args.fold.sep

        local foldclosed = foldinfo.lines > 0

        if foldclosed then
          symbol = args.fold.close
        elseif args.lnum == foldinfo.start then
          symbol = args.fold.open
        end

        if foldclosed or (args.lnum >= cursor_fold.start and args.lnum <= cursor_fold.end_) then
          hl = '%#ErrorMsg#'
        else
          hl = get_hl(args)
        end

        return '%*' .. hl .. symbol .. '%*'
      end,
      ' ',
    },
    click = 'v:lua.ScSa',
  })

  require('statuscol').setup(opts)
end

return spec
