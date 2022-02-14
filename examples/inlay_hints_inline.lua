local inlay_hints = require('lsp_extensions.inlay_hints')

local M = {}

-- Global function, so you can just call it on the lua side
ShowInlineInlayHints = function()
  -- For C++ replace "rust-analyzer" with "clangd"
  vim.lsp.buf_request(0, inlay_hints.request_name{ lsp_client = "rust-analyzer"}, inlay_hints.get_params(), inlay_hints.get_callback {
    only_current_line = true
  })
end

-- @rockerboo
M.show_line_hints_on_cursor_events = function()
  -- For C++ replace *.rs with *.cpp
  vim.cmd [[augroup ShowLineHints]]
  vim.cmd [[  au!]]
  vim.cmd [[  autocmd CursorHold,CursorHoldI,CursorMoved *.rs :lua ShowInlineInlayHints()]]
  vim.cmd [[augroup END]]
end

return M
