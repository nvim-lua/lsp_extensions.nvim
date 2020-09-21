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
-- Stored labels from the server's notifications keyed by uri
local all_labels = {}
-- Namespace for the virtual text
local closing_labels_ns = vim.api.nvim_create_namespace('lsp_extensions.dart.closing_labels')

-- Gets a callback to register to the dartls publishClosingLabels notification.
-- @tparam table a table of options: highlight, prefix
M.get_callback = function(opts)

  local get_draw_labels = function(opts)
    return function()
      opts = opts or {}
      local highlight = opts.highlight or "Comment"
      local prefix = opts.prefix or "// "
      local bufnr = 0
      local uri = vim.uri_from_bufnr(bufnr)
      local labels = all_labels[uri] or {}

      local display_virt_text = function(label)
        local end_line = label.range["end"].line
        local text = prefix .. label.label
        vim.api.nvim_buf_set_virtual_text(bufnr, closing_labels_ns, end_line, { { text, highlight } }, {})
      end

      vim.api.nvim_buf_clear_namespace(bufnr, closing_labels_ns, 0, -1)
      for _, label in pairs(labels) do
        display_virt_text(label)
      end
    end
  end

  -- Draws closing labels in the current buffer
  M.draw_labels = get_draw_labels(opts)

  return function(_, _, result, _, _)
    local uri = result.uri
    local labels = result.labels
    all_labels[uri] = labels
    if uri == vim.uri_from_bufnr(0) then
      M.draw_labels()
    end
  end
end

return M
