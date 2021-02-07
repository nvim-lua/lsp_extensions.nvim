
--[[

Note to self:

Each extension should probably look like:

- request(opts)
  -> opts gets passed to get_callback, runs the request in your buffer.

- get_callback(opts)
  -> opts configures how you would want this extension to run.

- get_params(opts)
  -> get the params you need to make the request

--]]

local vim = vim
local extensions = {}
local rust_analyzer = require('lsp_extensions.rust_analyzer')

extensions.rust_analyzer = {}
extensions.rust_analyzer.inlay_hints = rust_analyzer.inlay_hints
extensions.rust_analyzer.open_cargo_toml = rust_analyzer.open_cargo_toml

return extensions
