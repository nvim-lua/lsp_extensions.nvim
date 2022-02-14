# lsp_extensions.nvim

Repo to hold a bunch of info &amp; extension callbacks for built-in LSP. Use at your own risk :wink:

## Install

Requires Built-in LSP, [Neovim Nightly](https://github.com/neovim/neovim/releases/tag/nightly), [nvim-lsp](https://github.com/neovim/nvim-lsp)

```vimscript
" LSP Extensions
Plug 'nvim-lua/lsp_extensions.nvim'
```

### Available Features

#### Rust/C++
- [Inlay Hints](#inlay-hints-rust-analyzerclangd-14)

#### Dart
- [Closing Labels](#closing-labels-dartls)
- [Outline](#outline-dartls)

#### Diagnostics
- [Diagnostics](#workspace-diagnostics)


## Inlay Hints (rust-analyzer/clangd-14)

![Customized](https://i.imgur.com/FRRas1c.png)
![CustomizedCpp](https://i.imgur.com/SofDfdh.png)

**Note**: Minial requirement for clangd inlay hints is clangd-14, you need to set `clangdInlayHintsProvider` to true in clangd's `init_options`
```lua
lspconfig.clangd.setup {
 ...
 init_options = {
   clangdInlayHintsProvider = true,
   ...
 },
 ...
}
```

Inlay hints for the whole file:

```vimscript
nnoremap <Leader>T :lua require'lsp_extensions'.inlay_hints()
" For C++ set lsp_client to clangd
nnoremap <Leader>T :lua require'lsp_extensions'.inlay_hints{ lsp_client = "clangd" }
```

Only current line:

```vimscript
nnoremap <Leader>t :lua require'lsp_extensions'.inlay_hints{ only_current_line = true }
" For C++ set lsp_client to clangd
nnoremap <Leader>t :lua require'lsp_extensions'.inlay_hints{ lsp_client = "clangd", only_current_line = true }
```

Run on showing file or new file in buffer:

```vimscript
autocmd BufEnter,BufWinEnter,TabEnter *.rs :lua require'lsp_extensions'.inlay_hints{}
" For C++ set lsp_client to clangd
autocmd BufEnter,BufWinEnter,TabEnter *.cpp :lua require'lsp_extensions'.inlay_hints{ lsp_client = "clangd" }
```

On cursor hover, get hints for current line:

```vimscript
autocmd CursorHold,CursorHoldI *.rs :lua require'lsp_extensions'.inlay_hints{ only_current_line = true }
" For C++ set lsp_client to clangd
autocmd CursorHold,CursorHoldI *.cpp :lua require'lsp_extensions'.inlay_hints{ lsp_client = "clangd", only_current_line = true }
```

By default only ChainingHint is enabled. This is due to Neovim not able to add virtual text injected into a line. To enable all hints:
**Note:** Not all hints will be displayed if this is set. For easier readability, only hints of one type are shown per line.
**Note:** For clangd you have to explicitly specify the type of the hints to provide, currently, it have "parameter" and "type" [clangd doc](https://clangd.llvm.org/extensions#inlay-hints)
```vimscript
:lua require('lsp_extensions').inlay_hints{ enabled = {"TypeHint", "ChainingHint", "ParameterHint"} }
:lua require('lsp_extensions').inlay_hints{ lsp_client = "clangd", enabled = {"parameter", "type"} }
```

Available Options (Showing defaults):

```lua
require'lsp_extensions'.inlay_hints{
	highlight = "Comment",
	prefix = " > ",
	lsp_client = "rust-analyzer",
	aligned = false,
	only_current_line = false,
	enabled = { "ChainingHint" }
}
```

```vimscript
autocmd InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost *.rs :lua require'lsp_extensions'.inlay_hints{ prefix = ' » ', highlight = "NonText", enabled = {"ChainingHint"} }
" For C++
autocmd InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost *.cpp :lua require'lsp_extensions'.inlay_hints{ lsp_client = "clangd" prefix = ' » ', highlight = "NonText", enabled = {"type"} }
```

## Closing Labels (dartls)
![closing-labels](https://raw.githubusercontent.com/tjdevries/media.repo/b4a4a20d0c31a4905e42e219cf854c9aa104edbd/lsp_extensions/dart-closingLabels.png)

[Closing Labels Documentation](https://github.com/dart-lang/sdk/blob/master/pkg/analysis_server/tool/lsp_spec/README.md#darttextdocumentpublishclosinglabels-notification)

Check out the [example file](examples/dart/closing_labels.lua) for setup

## Outline (dartls)
Rending in loclist:
<img align="left" alt="dart-outline-loclist" src="https://raw.githubusercontent.com/tjdevries/media.repo/b27a8366b460cac2629d5fdb81862e5bd1d0a553/lsp_extensions/dart-outline.png">


Rendering in fzf:
<img align="left" alt="dart-outline-fzf" src="https://raw.githubusercontent.com/PatOConnor43/media.repo/0a8aa1c6fc89087c4771557c1e59864700821b26/lsp_extensions/dart-outline-fzf.png">


Rendering in telescope:
<img align="left" alt="dart-outline-telescope" src="https://raw.githubusercontent.com/PatOConnor43/media.repo/0a8aa1c6fc89087c4771557c1e59864700821b26/lsp_extensions/dart-outline-telescope.png">

[Outline Documentation](https://github.com/dart-lang/sdk/blob/master/pkg/analysis_server/tool/lsp_spec/README.md#darttextdocumentpublishoutline-notification)

Check out the [example file](examples/dart/outline.lua) for setup

## Workspace Diagnostics

To enable workspace diagnostics, you'll want do something like this:

```lua
-- use the same configuration you would use for `vim.lsp.diagnostic.on_publish_diagnostics`.
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  require('lsp_extensions.workspace.diagnostic').handler, {
    signs = {
      severity_limit = "Error",
    }
  }
)
```

To use workspace diagnostics, you can do some of the following:

```lua
-- Get the counts from your curreent workspace:
local ws_errors = require('lsp_extensions.workspace.diagnostic').get_count(0, 'Error')
local ws_hints = require('lsp_extensions.workspace.diagnostic').get_count(0, 'Hint')

-- Set the qflist for the current workspace
--  For more information, see `:help vim.lsp.diagnostic.set_loc_list()`, since this has some of the same configuration.
require('lsp_extensions.workspace.diagnostic').set_qf_list()
```

## Clips

- Showing Line Diagnostics: https://clips.twitch.tv/ProductiveBoxyPastaCoolStoryBro

- This Plugin:

  - Lined up hints: https://clips.twitch.tv/DaintyCorrectMarjoramKeepo
  - [Closing Labels Demo](https://github.com/tjdevries/media.repo/blob/b4a4a20d0c31a4905e42e219cf854c9aa104edbd/lsp_extensions/dart-closingLabels.mp4)

- N E O V I M: https://clips.twitch.tv/SmoothGoodTurnipCmonBruh
