local spec = {
  'luukvbaal/statuscol.nvim',
  opts = {},
}

spec.opts.ft_ignore = { 'help', 'lazy', 'TelescopePrompt', 'undotree' }
spec.opts.bt_ignore = { 'terminal' }

function spec.config(_, opts)
  local builtin = require('statuscol.builtin')
  local ffi = require('statuscol.ffidef')

  local hl_range

  local function gen_relline_hls()
    local v = 1 - vim.g.scrolloff
    hl_range = math.ceil(vim.api.nvim_win_get_height(0) * v)

    local color1 = vim.api.nvim_get_hl(0, { name = 'CursorLineNr' }).fg
    local color2 = vim.api.nvim_get_hl(0, { name = 'LineNr' }).fg

    for i = 1, hl_range do
      local alpha = math.sqrt(i / (hl_range + 1))

      vim.api.nvim_set_hl(0, 'RelLineNr' .. i, {
        fg = require('local.theme').mix_colors(color1, color2, alpha),
      })
    end
  end

  gen_relline_hls()

  local autocmd = require('local.helpers').autocmd
  local augroup = require('local.helpers').augroup

  autocmd({ 'WinEnter', 'WinResized' }, {
    group = augroup('statuscolumn_relline_hl'),
    callback = gen_relline_hls,
  })

  local cursor_fold = { level = 0, start = -1, end_ = -1 }

  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
    group = vim.api.nvim_create_augroup('Statuscol Fold', { clear = false }),
    callback = function(event)
      if
        vim.tbl_contains(opts.ft_ignore or {}, vim.bo[event.buf].filetype)
        or vim.tbl_contains(opts.bt_ignore or {}, vim.bo[event.buf].buftype)
      then
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
        local ufo_available, fold_ = pcall(require, 'ufo.fold')

        if ufo_available then
          fold_ = fold_.get(event.buf)
          local folds = vim.iter(fold_ and fold_.foldRanges or {}):map(function(fold)
            return { start = fold.startLine + 1, end_ = fold.endLine + 1 }
          end)

          folds = folds:filter(function(fold)
            return fold.start <= line and line <= fold.end_
          end)

          cursor_fold = folds:fold(nil, function(cur_fold, fold)
            cur_fold = cur_fold or fold
            cur_fold.level = foldlevel

            if fold.end_ - fold.start < cur_fold.end_ - cur_fold.start then
              cur_fold.start = fold.start
              cur_fold.end_ = fold.end_
            end

            return cur_fold
          end)
        end

        if not cursor_fold then
          cursor_fold = {}
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
      end
    end,
  })

  opts.segments = {}

  table.insert(opts.segments, {
    sign = {
      name = { '*' },
      -- take anything except diagnostics, since will be added after numbers
      namespace = { '^(?!.*diagnostic).*$' },
      wrap = true,
      foldclosed = true,
      auto = true,
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
        local hl
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
          hl = ''
        else
          hl = get_hl(args)
        end

        if args.sclnu and segment.sign and segment.sign.wins[args.win].signs[args.lnum] then
          return '%=' .. builtin.signfunc(args, segment)
        end

        if not args.rnu and not args.nu then
          return ''
        end
        if args.virtnum ~= 0 then
          return '%='
        end

        local lnum = args.rnu and (args.relnum > 0 and args.relnum or (args.nu and args.lnum or 0)) or args.lnum

        if args.relnum == 0 and args.rnu then
          return hl .. lnum .. '%='
        end

        return hl .. '%=' .. string.format('%' .. vim.o.numberwidth .. 'd', lnum)
      end,
      ' ',
    },
    click = 'v:lua.ScLa',
  })

  table.insert(opts.segments, {
    sign = {
      namespace = { 'diagnostic/signs' },
      colwidth = 1,
      wrap = true,
      foldclosed = true,
    },
    click = 'v:lua.ScSa',
  })

  table.insert(opts.segments, {
    text = {
      ' ',
      function(args)
        local hl
        local foldinfo = ffi.C.fold_info(args.wp, args.lnum)
        local symbol = args.fold.sep or ''

        local foldclosed = foldinfo.lines > 0

        if foldclosed then
          symbol = args.fold.close
        elseif args.lnum == foldinfo.start then
          symbol = args.fold.open
        end

        if foldclosed or (args.lnum >= cursor_fold.start and args.lnum <= cursor_fold.end_) then
          hl = '%#Normal#'
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
