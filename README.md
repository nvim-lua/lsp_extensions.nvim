# lsp_extensions.nvim

Repo to hold a bunch of info &amp; extension callbacks for built-in LSP. Use at your own risk :wink:

## Install

Requires Built-in LSP, [Neovim Nightly](https://github.com/neovim/neovim/releases/tag/nightly), [nvim-lsp](https://github.com/neovim/nvim-lsp)

```vimscript
	" LSP Extensions (inlay-hints)
	Plug "tjdevries/lsp_extensions.nvim"
```

## Inlay Hints (rust-analyzer)

![inlay-hints](https://i.imgur.com/YsOfqOk.png)

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
autocmd CursorHold,CursorHoldI *.rs :lua require'lsp_extensions'.inlay_hints{ only_current_line = true }
```

Available Options (Showing defaults):

```lua
require'lsp_extensions'.inlay_hints{
	highlight = "Comment",
	prefix = " > ",
	aligned = false,
	only_current_line = false
}
```

## Clips

- Showing Line Diagnostics: https://clips.twitch.tv/ProductiveBoxyPastaCoolStoryBro

- This Plugin:

  - Lined up hints: https://clips.twitch.tv/DaintyCorrectMarjoramKeepo

- N E O V I M: https://clips.twitch.tv/SmoothGoodTurnipCmonBruh
