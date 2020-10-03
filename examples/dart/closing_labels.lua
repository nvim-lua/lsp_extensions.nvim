local nvim_lsp = require('nvim_lsp')

nvim_lsp.dartls.setup{
  init_options = {
    closingLabels = true,
  },
  callbacks = {
    -- get_callback can be called with or without arguments
    ['dart/textDocument/publishClosingLabels'] = require('lsp_extensions.dart.closing_labels').get_callback({highlight = "Special", prefix = " >> "}),
  },
}

