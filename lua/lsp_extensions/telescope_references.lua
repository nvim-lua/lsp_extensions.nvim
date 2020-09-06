
require('plenary.reload').reload_module('telescope')

local ok, telescope = pcall(require, 'telescope')
if not ok then
  return {}
end

local telescope_references = {}

telescope_references.request = function(opts)
  vim.lsp.buf_request(0, 'textDocument/references', telescope_references.get_params(), telescope_references.get_callback(opts))
end

telescope_references.get_callback = function(opts)
  opts = opts or {}

  return function(_, _, result, _, bufnr)
    if not result then
      print("[lsp_extensions.telescope_references] No references found")
      return
    end

    local items = vim.lsp.util.locations_to_items(result)
    -- print(vim.inspect(items))

    local finder_items = {}
    for _, v in ipairs(items) do
      table.insert(finder_items, string.format("%s:%s:%s:%s",
        v.filename,
        v.lnum,
        v.col,
        v.text
      ))
    end

    local file_finder = telescope.finders.new { results = finder_items }
    local file_previewer = telescope.previewers.vim_buffer

    local file_picker = telescope.pickers.new {
      previewer = file_previewer
    }

    -- local file_sorter = telescope.sorters.get_ngram_sorter()
    -- local file_sorter = require('telescope.sorters').get_levenshtein_sorter()
    local file_sorter = telescope.sorters.get_norcalli_sorter()

    file_picker:find {
      prompt = 'LSP References',
      finder = file_finder,
      sorter = file_sorter,
    }
  end
end

telescope_references.get_params = function()
  local params = vim.lsp.util.make_position_params()

  params.context = {
    includeDeclaration = true
  }

  -- params[vim.type_idx] = vim.types.dictionary
  return params
end

return telescope_references
