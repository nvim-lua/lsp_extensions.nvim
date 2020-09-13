-- The configured callback will fetch the labels automatically. You just need
-- to tell the labels to be drawn.
vim.cmd [[autocmd DartShowClosingLabels CursorHold,CursorHoldI *.dart :lua require('lsp_extensions.dart.closing_labels').draw_labels()]]

-- With a group
vim.cmd [[augroup DartShowClosingLabels]]
vim.cmd [[  au!]]
vim.cmd [[  autocmd CursorHold,CursorHoldI *.dart :lua require('lsp_extensions.dart.closing_labels').draw_labels()]]
vim.cmd [[augroup END]]
