--[[
--
## dart/textDocument/publishOutline Notification

Direction: Server -> Client
Params: `{ uri: string, outline: Outline }`
Outline: `{ element: Element, range: Range, codeRange: Range, children: Outline[] }`
Element: `{ name: string, range: Range, kind: string, parameters: string | undefined, typeParameters: string | undefined, returnType: string | undefined }`

Notifies the client when outline information is available (or updated) for a file.

Nodes contains multiple ranges:

- `element.range` - the range of the name in the declaration of the element
- `range` - the entire range of the declaration including dartdocs
- `codeRange` - the range of code part of the declaration (excluding dartdocs and annotations) - typically used when navigating to the declaration

https://github.com/dart-lang/sdk/blob/master/pkg/analysis_server/tool/lsp_spec/README.md#darttextdocumentpublishoutline-notification

## Usage
Since this is a notification, the callback needs to be registered in the client's callbacks table.
This can be achieved with nvim_lspconfig with this minimal config.
```lua
nvim_lsp.dartls.setup{
  init_options = {
    outline = true,
  },
  callbacks = {
    ['dart/textDocument/publishOutline'] = require('lsp_extensions.dart.outline').get_callback(),
  },
}
```

Then from nvim you can call loclist() or custom() to show the outline.
```
:lua require('lsp_extensions.dart.outline').loclist()
```

--]]

local M = {}

-- The most recent published outline.
local current_outline = {}

-- https://github.com/dart-lang/sdk/blob/93313eb2449099e20ade80d4760f76a325a4e176/pkg/analysis_server/tool/spec/generated/java/types/ElementKind.java#L16
local default_kind_prefixes = {
    CLASS = "CLASS",
    CLASS_TYPE_ALIAS = "CLASS_TYPE_ALIAS",
    COMPILATION_UNIT = "COMPILATION_UNIT",
    CONSTRUCTOR = "CONSTRUCTOR",
    CONSTRUCTOR_INVOCATION = "CONSTRUCTOR_INVOCATION",
    ENUM = "ENUM",
    ENUM_CONSTANT = "ENUM_CONSTANT",
    EXTENSION = "EXTENSION",
    FIELD = "FIELD",
    FILE = "FILE",
    FUNCTION = "FUNCTION",
    FUNCTION_INVOCATION = "FUNCTION_INVOCATION",
    FUNCTION_TYPE_ALIAS = "FUNCTION_TYPE_ALIAS",
    GETTER = "GETTER",
    LABEL = "LABEL",
    LIBRARY = "LIBRARY",
    LOCAL_VARIABLE = "LOCAL_VARIABLE",
    METHOD = "METHOD",
    MIXIN = "MIXIN",
    PARAMETER = "PARAMETER",
    PREFIX = "PREFIX",
    SETTER = "SETTER",
    TOP_LEVEL_VARIABLE = "TOP_LEVEL_VARIABLE",
    TYPE_PARAMETER = "TYPE_PARAMETER",
    UNIT_TEST_GROUP = "UNIT_TEST_GROUP",
    UNIT_TEST_TEST = "UNIT_TEST_TEST",
    UNKNOWN = "UNKNOWN",
}

-- A global function that recursively traverses the outline tree depth first
-- and adds items to the items table.
--
-- @tparam table opts is a table used to mutate items
-- @tparam string fname is the filename of the buffer that the outline belongs to
-- @tparam table items is the in progress table of items
-- @tparam table node is the current `Element` that is being traversed
_DART_OUTLINE_APPEND_CHILDREN = function(opts, fname, items, node, tree_prefix)
  if node == nil then
    return
  end
  local stringBuilder = {}
  local range = node.codeRange
  local elem = node.element


  table.insert(stringBuilder, opts.kind_prefixes[elem.kind] or opts.kind_prefixes.UNKNOWN)

  if elem.returnType ~= nil then
    table.insert(stringBuilder, elem.returnType)
  end

  if elem.typeParameters ~= nil and elem.parameters ~= nil then
    table.insert(stringBuilder, elem.name .. elem.typeParameters .. elem.parameters)
  elseif elem.typeParameters ~= nil then
    table.insert(stringBuilder, elem.name ..  elem.typeParameters)
  elseif elem.parameters ~= nil then
    table.insert(stringBuilder, elem.name ..  elem.parameters)
  else
    table.insert(stringBuilder, elem.name)
  end

  local text = table.concat(stringBuilder, ' ')
  table.insert(items, {filename = fname, lnum = range.start.line + 1, col = range.start.character + 1, text = text, tree_prefix = tree_prefix})

  -- We're done if there's no more children
  if node.children == nil or vim.tbl_isempty(node.children) then
    return
  end

  local child_tree_prefix = tree_prefix .. '  '
  for _, child in ipairs(node.children) do
      _DART_OUTLINE_APPEND_CHILDREN(opts, fname, items, child, child_tree_prefix)
  end
end

-- Rudimentary validation for the outlines before trying to do anything with
-- them.
--
-- @tparam table outline the outline for the current request
-- @treturn bool a bool describing if the outline is valid
local validate = function(outline)
  if vim.tbl_isempty(outline) then
      print('No outline available for ' .. vim.api.nvim_buf_get_name(0))
      return false
  end
  return true
end

-- Constructs a list of items that can be used to build the UI of the outline.
--
-- @tparam table opts is table used to mutate items
-- @tparam table outline the outline for the current request
-- @treturn table {{filename = string, lnum = number, col = number, text = string}, ...}
local build_items = function(opts, outline)
  local fname = vim.api.nvim_buf_get_name(0)
  local items = {}
  for _, node in ipairs(outline.children or {}) do
    _DART_OUTLINE_APPEND_CHILDREN(opts, fname, items, node, '')
  end
  return items
end

-- This function allows you to specify your own outline handler to do whatever
-- you want. Check out the loclist implementation as an example.
--
-- @tparam table opts is table used to mutate items. opts.kind_prefixes is a
-- table that allows specifying a prefix per kind type. This can be especially
-- useful if you want to display unicode or patched font icons.
-- @tparam function(items) handler is a function which takes a list of items
M.custom = function(opts, handler)
  opts = opts or {}
  local kind_prefixes = opts.kind_prefixes or default_kind_prefixes
  opts.kind_prefixes = vim.tbl_extend("keep", kind_prefixes, default_kind_prefixes)
  local outline = current_outline
  if not validate(outline) then
      return
  end
  local items = build_items(opts, outline)
  handler(items)
end

-- This function displays the outline in the loclist.
--
-- @tparam table opts is table used to mutate items. opts.kind_prefixes is a
-- table that allows specifying a prefix per kind type. This can be especially
-- useful if you want to display unicode or patched font icons.
M.loclist = function(opts)
  M.custom(opts, function(items)
    vim.fn.setloclist(0, {}, ' ', {
        title = 'Outline';
        items = items;
      })
    vim.cmd[[lopen]]
  end)
end

M.fzf = function(opts)
   M.custom(opts, function(items)
     opts = opts or {}
     local fzf_opts = opts.fzf_opts or {'--reverse'}
     local stringifiedItems = {}
     for _, item in ipairs(items) do
         table.insert(stringifiedItems, string.format('%s%s:%d:%d',item.tree_prefix, item.text, item.lnum, item.col))
     end
     -- Calling fzf as explained here:
     -- https://github.com/junegunn/fzf/issues/1778#issuecomment-697208274
     local fzf_run = vim.fn['fzf#run']
     local fzf_wrap = vim.fn['fzf#wrap']
     local wrapped = fzf_wrap('Outline', {
         source = stringifiedItems,
         options = fzf_opts,
     })
     wrapped["sink*"] = nil
     wrapped.sink = function(line)
       local pattern = '%S+:(%d+):(%d+)'
       local lnum, col = string.match(line, pattern)
       vim.call('cursor', lnum, col)
     end
     fzf_run(wrapped)
   end)
end

-- Gets a callback to register to the dartls outline notification.
M.get_callback = function()
  return function(_, _, result, _, _)
    current_outline = result.outline
  end
end

return M
