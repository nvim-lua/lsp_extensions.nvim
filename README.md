# lsp_extensions.nvim

Repo to hold a bunch of info &amp; extension callbacks for built-in LSP. Use at your own risk :wink:

## Install

Requires Built-in LSP, [Neovim Nightly](https://github.com/neovim/neovim/releases/tag/nightly), [nvim-lsp](https://github.com/neovim/nvim-lsp)

```vimscript
" LSP Extensions
Plug 'nvim-lua/lsp_extensions.nvim'
```

### Available Features

#### Rust
- [Inlay Hints](#inlay-hints-rust-analyzer)

#### Dart
- [Closing Labels](#closing-labels-dartls)
- [Outline](#outline-dartls)

## Inlay Hints (rust-analyzer)

![Customized](https://i.imgur.com/FRRas1c.png)

Inlay hints for the whole file:

```vimscript
nnoremap <Leader>T :lua require'lsp_extensions'.inlay_hints()
```

Only current line:

```vimscript
nnoremap <Leader>t :lua require'lsp_extensions'.inlay_hints{ only_current_line = true }
```

Run on showing file or new file in buffer:

```vimscript
autocmd BufEnter,BufWinEnter,TabEnter *.rs :lua require'lsp_extensions'.inlay_hints{}
```

On cursor hover, get hints for current line:

```vimscript
autocmd CursorHold,CursorHoldI *.rs :lua require'lsp_extensions.rust_analyzer'.inlay_hints{ only_current_line = true }
```

Available Options (Showing defaults):

```lua
require'lsp_extensions'.inlay_hints{
	highlight = "Comment",
	prefix = " > ",
	aligned = false,
	only_current_line = false
	enabled = { "ChainingHint" }
}
```

```vimscript
autocmd InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost *.rs :lua require'lsp_extensions'.inlay_hints{ prefix = ' » ', highlight = "NonText", enabled = {"ChainingHint"} }
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

## Clips

- Showing Line Diagnostics: https://clips.twitch.tv/ProductiveBoxyPastaCoolStoryBro

- This Plugin:

  - Lined up hints: https://clips.twitch.tv/DaintyCorrectMarjoramKeepo
  - [Closing Labels Demo](https://github.com/tjdevries/media.repo/blob/b4a4a20d0c31a4905e42e219cf854c9aa104edbd/lsp_extensions/dart-closingLabels.mp4)

- N E O V I M: https://clips.twitch.tv/SmoothGoodTurnipCmonBruh
