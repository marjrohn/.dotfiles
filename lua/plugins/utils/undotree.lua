return {
  'mbbill/undotree',
  lazy = false,
  config = function()
    local nmap = require('local.helpers').map({ mode = 'n' })

    -- stylua: ignore start
    nmap('<leader>ut', ':UndotreeToggle',      { desc = 'Toggle undotree' })
    nmap('<leader>uh', ':UndotreeHide',        { desc = 'Hide undotree'   })
    nmap('<leader>us', ':UndotreeShow',        { desc = 'Show undotree'   })
    nmap('<leader>uf', ':UndotreeFocus',       { desc = 'Focus undotree'  })
    nmap('<leader>uu', ':UndotreePersistUndo', { desc = 'Persist Undo'    })
    -- stylua: ignore end
  end,
}
