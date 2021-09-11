--[[
## Inlay Hints

**Method:** `rust-analyzer/inlayHints`

This request is send from client to server to render "inlay hints" -- virtual text inserted into editor to show things like inferred types.
Generally, the client should re-query inlay hints after every modification.
Note that we plan to move this request to `experimental/inlayHints`,
  as it is not really Rust-specific, but the current API is not necessary the right one.

**Request:**

```typescript
interface InlayHintsParams {
    textDocument: TextDocumentIdentifier,
}
```

**Response:** `InlayHint[]`

```typescript
interface InlayHint {
    kind: "TypeHint" | "ParameterHint" | "ChainingHint",
    range: Range,
    label: string,
}
```
--]] 

local util = require('lsp_extensions.util')

local inlay_hints = {}

local inlay_hints_ns = vim.api.nvim_create_namespace("lsp_extensions.inlay_hints")

inlay_hints.request = function(opts, bufnr)
  vim.lsp.buf_request(bufnr or 0, "rust-analyzer/inlayHints", inlay_hints.get_params(),
                      inlay_hints.get_callback(opts))

  -- TODO: At some point, rust probably adds this?
  -- vim.lsp.buf_request(bufnr or 0, 'experimental/inlayHints', inlay_hints.get_params(), inlay_hints.get_callback(opts))
end

inlay_hints.get_callback = function(opts)
  opts = opts or {}

  local highlight = opts.highlight or "Comment"
  local prefix = opts.prefix or " > "
  local aligned = opts.aligned or false

  local enabled = opts.enabled or {"ChainingHint"}

  local only_current_line = opts.only_current_line
  if only_current_line == nil then only_current_line = false end

  return util.mk_handler(function(err, result, ctx, _)
    -- I'm pretty sure this only happens for unsupported items.
    if err or type(result) == 'number' then
      return
    end

    if not result or vim.tbl_isempty(result) then
      return
    end

    vim.api.nvim_buf_clear_namespace(ctx.bufnr, inlay_hints_ns, 0, -1)

    local hint_store = {}

    local longest_line = -1

    -- Check if something is in the list
    -- in_list({"ChainingHint"})("ChainingHint")
    local in_list = function(list)
      return function(item)
        for _, f in ipairs(list) do
          if f == item then return true end
        end

        return false
      end
    end

    for _, hint in ipairs(result) do
      local finish = hint.range["end"].line
      if not hint_store[finish] and in_list(enabled)(hint.kind) then
        hint_store[finish] = hint

        if aligned then
          longest_line = math.max(longest_line,
                                  #vim.api.nvim_buf_get_lines(ctx.bufnr, finish, finish + 1, false)[1])
        end
      end
    end

    local display_virt_text = function(hint)
      local end_line = hint.range["end"].line

      -- Check for any existing / more important virtual text on the line.
      -- TODO: Figure out how stackable virtual text works? What happens if there is more than one??
      local existing_virt_text = vim.api.nvim_buf_get_extmarks(ctx.bufnr, inlay_hints_ns, {end_line, 0},
                                                               {end_line, 0}, {})
      if not vim.tbl_isempty(existing_virt_text) then return end

      local text
      if aligned then
        local line_length = #vim.api.nvim_buf_get_lines(ctx.bufnr, end_line, end_line + 1, false)[1]
        text = string.format("%s %s", (" "):rep(longest_line - line_length), prefix .. hint.label)
      else
        text = prefix .. hint.label
      end
      vim.api.nvim_buf_set_virtual_text(ctx.bufnr, inlay_hints_ns, end_line, {{text, highlight}}, {})
    end

    if only_current_line then
      local hint = hint_store[vim.api.nvim_win_get_cursor(0)[1] - 1]

      if not hint then
        return
      else
        display_virt_text(hint)
      end
    else
      for _, hint in pairs(hint_store) do display_virt_text(hint) end
    end
  end)
end

inlay_hints.get_params = function()
  return {textDocument = vim.lsp.util.make_text_document_params()}
end

inlay_hints.clear = function()
  vim.api.nvim_buf_clear_namespace(0, inlay_hints_ns, 0, -1)
end

return inlay_hints
