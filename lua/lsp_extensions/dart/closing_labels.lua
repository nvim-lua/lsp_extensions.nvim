--[[
## Closing Labels

** Method: 'dart/textDocument/publishClosingLabels**
Direction: Server -> Client Params: { uri: string, labels: { label: string, range: Range }[] }
This notifies the client when closing label information is available (or updated) for a file.

Since this is a notification, the callback needs to be registered in the client's callbacks table.
This can be achieved with nvim_lspconfig with this minimal config.
```lua
nvim_lsp.dartls.setup{
  init_options = {
    closingLabels = true,
  },
  callbacks = {
    ['dart/textDocument/publishClosingLabels'] = require('lsp_extensions.dart.closing_labels').get_callback{},
  },
}
```
https://github.com/dart-lang/sdk/blob/master/pkg/analysis_server/tool/lsp_spec/README.md#darttextdocumentpublishclosinglabels-notification
--]]
local M = {}

-- Namespace for the virtual text
local closing_labels_ns = vim.api.nvim_create_namespace('lsp_extensions.dart.closing_labels')

-- Draws the newly published labels in the current buffer
-- @tparam table a table of options: highlight, prefix
-- @tparam table a table of labels for the current buffer
local draw_labels = function(opts, labels)
  opts = opts or {}
  local highlight = opts.highlight or "Comment"
  local prefix = opts.prefix or "// "
  vim.api.nvim_buf_clear_namespace(0, closing_labels_ns, 0, -1)
  for _, label in pairs(labels) do
    local end_line = label.range["end"].line
    local text = prefix .. label.label
    vim.api.nvim_buf_set_virtual_text(0, closing_labels_ns, end_line, { { text, highlight } }, {})
  end
end

-- Gets a callback to register to the dartls publishClosingLabels notification.
-- @tparam table a table of options: highlight, prefix
M.get_callback = function(opts)
  return function(_, _, result, _, _)
    local uri = result.uri
    local labels = result.labels
    -- This check is meant to prevent stray events from over-writing labels that
    -- don't match the current buffer.
    if uri == vim.uri_from_bufnr(0) then
      draw_labels(opts, labels)
    end
  end
end

return M
