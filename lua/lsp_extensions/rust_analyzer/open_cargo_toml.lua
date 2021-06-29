--[[
Open Cargo.toml

https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/dev/lsp-extensions.md#open-cargotoml

This request is sent from client to server to open the current project's Cargo.toml

Method: experimental/openCargoToml

Request: OpenCargoTomlParams

Response: Location | null

experimental/openCargoToml returns a single Link to the start of the [package] keyword.
--]]

local get_callback = function() 
    return function(err, _, result, _, _) 
        if not result or vim.tbl_isempty(result) then
            return
        end
    vim.lsp.util.jump_to_location(result)
    end 
end

local get_params = function() 
  return {
      textDocument = vim.lsp.util.make_text_document_params()
  }
end

return function()
  vim.lsp.buf_request(0, "experimental/openCargoToml", get_params(),
                      get_callback())
end

