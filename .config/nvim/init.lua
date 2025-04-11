require('config.settings')
require('config.keymaps')
require('config.autocmds')
require('config.lsp')
require('config.diagnostic')

if vim.env.NVIM_NO_PLUGINS ~= 1 then
  require('config.lazy')
end

---------------------------------------------------------------------------------

-- local function copy_diagnostics()
--   local buf = vim.api.nvim_get_current_buf()
--   local lnum = vim.api.nvim_win_get_cursor(0)[1]
--   local diagnostics = vim.diagnostic.get(buf, {
--     lnum = lnum - 1, -- need 0-based index
--     -- this will select only `ERROR` or `WARN`,
--     -- i.e. `INFO` or `HINT` will be ignored
--     severity = { min = vim.diagnostic.severity.WARN },
--   })
--
--   if vim.tbl_isempty(diagnostics) then
--     vim.notify(string.format('Line %d has no diagnostics.', lnum))
--     return
--   end
--
--   table.sort(diagnostics, function(a, b)
--     return a.severity < b.severity
--   end)
--
--   -- so which diagnostic to choose
--   local result
--
--   -- 1. take wharever appears first
--   result = vim.trim(diagnostics[1].message)
--
--   -- 2. just concatenate everything
--   result = vim
--     .iter(diagnostics)
--     :map(function(diag)
--       return vim.trim(diag.message)
--       -- you may want to prefix with severity
--       -- local prefix = diag.severity == vim.diagnostic.severity.ERROR and 'ERROR: ' or 'WARNING: '
--       -- return prefix .. vim.trim(diag.message)
--     end)
--     :join('\r\n')
--
--   -- 3. use vim.ui.select
--   vim.ui.select(diagnostics, {
--     prompt = 'Select diagnostic:',
--     format_item = function(diag)
--       local severity = diag.severity == vim.diagnostic.severity.ERROR and 'ERROR' or 'WARNING'
--       return string.format(
--         '%s: [%s] %s (%s)',
--         severity,
--         diag.code,
--         vim.trim(diag.message),
--         diag.source
--       )
--     end,
--   }, function(choice)
--       if choice then
--         result = vim.trim(choice.message)
--       end
--     end)
--
--   if result then
--     vim.fn.setreg(vim.v.register, result)
--     vim.notify(string.format('Yank diagnostic to register `%s`: %s', vim.v.register, result))
--   end
-- end
