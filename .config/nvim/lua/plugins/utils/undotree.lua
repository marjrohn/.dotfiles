return {
  'mbbill/undotree',
  lazy = false,
  config = function()
    local nmap = require('local.helpers').map({ mode = 'n' })

    -- stylua: ignore start
    nmap('<leader>ut', ':UndotreeToggle<cr>',      { desc = 'Toggle undotree' })
    nmap('<leader>uh', ':UndotreeHide<cr>',        { desc = 'Hide undotree'   })
    nmap('<leader>us', ':UndotreeShow<cr>',        { desc = 'Show undotree'   })
    nmap('<leader>uf', ':UndotreeFocus<cr>',       { desc = 'Focus undotree'  })
    nmap('<leader>uu', ':UndotreePersistUndo<cr>', { desc = 'Persist Undo'    })
    -- stylua: ignore end
  end,
}
