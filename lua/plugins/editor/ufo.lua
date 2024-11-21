local spec = {
  'kevinhwang91/nvim-ufo',
  dependencies = 'kevinhwang91/promise-async',
}

function spec.init()
  vim.o.foldenable = true
  vim.o.foldcolumn = '1'
  vim.o.foldlevel = 99
  vim.o.foldlevelstart = 99
end

function spec.opts()
  local handler = function(virtText, lnum, endLnum, width, truncate)
    local newVirtText = {}
    local suffix = (' 󰁂 %d '):format(endLnum - lnum)
    local sufWidth = vim.fn.strdisplaywidth(suffix)
    local targetWidth = width - sufWidth
    local curWidth = 0

    for _, chunk in ipairs(virtText) do
      local chunkText = chunk[1]
      local chunkWidth = vim.fn.strdisplaywidth(chunkText)

      if targetWidth > curWidth + chunkWidth then
        table.insert(newVirtText, chunk)
      else
        local hlGroup = chunk[2]

        chunkText = truncate(chunkText, targetWidth - curWidth)
        chunkWidth = vim.fn.strdisplaywidth(chunkText)
        table.insert(newVirtText, { chunkText, hlGroup })

        -- str width returned from truncate() may less than 2nd argument, need padding
        if curWidth + chunkWidth < targetWidth then
          suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
        end

        break
      end

      curWidth = curWidth + chunkWidth
    end

    table.insert(newVirtText, { suffix, 'MoreMsg' })

    return newVirtText
  end

  local function selector(_, filetype, buftype)
    local function handleFallbackException(bufnr, err, providerName)
      if type(err) == 'string' and err:match('UfoFallbackException') then
        return require('ufo').getFolds(bufnr, providerName)
      else
        return require('promise').reject(err)
      end
    end

    return (filetype == '' or buftype == 'nofile') and 'indent' -- only use indent until a file is opened
      or function(bufnr)
        return require('ufo')
          .getFolds(bufnr, 'lsp')
          :catch(function(err)
            return handleFallbackException(bufnr, err, 'treesitter')
          end)
          :catch(function(err)
            return handleFallbackException(bufnr, err, 'indent')
          end)
      end
  end

  return {
    provider_selector = selector,
    fold_virt_text_handler = handler,
  }
end

function spec.config(_, opts)
  local ufo = require('ufo')
  local nmap = require('local.helpers').map({ mode = 'n' })

  ufo.setup(opts)

  nmap('zR', ufo.openAllFolds, { desc = 'Open All Folds' })
  nmap('zM', ufo.closeAllFolds, { desc = 'Close All Folds' })
  nmap('zr', ufo.openFoldsExceptKinds, { desc = 'Fold Less' })
  nmap('zm', ufo.closeFoldsWith, { desc = 'Fold more' })
  nmap('zp', ufo.peekFoldedLinesUnderCursor, { desc = 'Peak Fold' })
end

return spec
