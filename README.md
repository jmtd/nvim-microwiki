# nvim-µwiki

A minimalist plugin to add basic wiki functions to [Markdown] documents.

## ✨ Features

 * Jump the cursor between wiki-links (enclosed in double-braces, e.g. `[[this]]`)
   in a document.
 * Follow wiki-links to existing pages where they exist, or start editing empty buffers
 * Populate the tag stack as you follow wiki-links
 * Don't take over the FileType: play nicely with any other Markdown
   configuration or plugins you are using.
 * Quickly edit a page corresponding to Today's date
 * Quickly Navigate to previous/next days from any page with a filename matching
   `%Y-%m-%d` e.g. `2025-01-23`

## ⚡️ Requirements

 * [Neovim]. This has been developed with version 0.10.0.
 * [This Treesitter grammar for markdown](https://github.com/tree-sitter-grammars/tree-sitter-markdown).
   It's bundled with Neovim since version 0.10.0.

## 📦 Installation

Use your favourite plugin manager. I'm using
[vim-plug](https://github.com/junegunn/vim-plug/). e.g.:

```Vim
call plug#begin('~/git/mine/neovim/test-µwiki/plugged')
  Plug 'jmtd/nvim-microwiki'
call plug#end()
```

## ⚙️ Configuration

```Lua
local wiki = require("nvim-µwiki")
wiki.setup({
  root = '$HOME/rh/vimwiki',
})
```

You need to have TreeSitter enabled for Markdown documents:

```Lua
vim.api.nvim_create_autocmd( 'FileType', { pattern = 'markdown',
  callback = function(args)
    vim.treesitter.start(args.buf, 'markdown')
  end
})
```

The plugin doesn't create any mappings. Here are some suggestions:

```Lua
-- global mapping
vim.keymap.set('n', '<leader>wd', wiki.todayDatePage)

-- buffer-local to markdown files
vim.api.nvim_create_autocmd( 'FileType', { pattern = 'markdown',
  callback = function(args)
    vim.keymap.set('n', '<C-]>',    wiki.followWikiLink, {buffer = true})
    vim.keymap.set('n', '<CR>',     wiki.followWikiLink, {buffer = true})
    vim.keymap.set('n', '<Tab>',    wiki.nextWikiLink,   {buffer = true})
    vim.keymap.set('n', '<S-Tab>',  wiki.prevWikiLink,   {buffer = true})
    vim.keymap.set('n', '<C-Down>', wiki.nextDatePage,   {buffer = true})
    vim.keymap.set('n', '<C-Up>',   wiki.prevDatePage,   {buffer = true})
  end
})
```

## 🧐 See also

 * [Vimwiki]: fully featured VimScript wiki
 * [Potwiki]: VimScript wiki of text files

## Authors

 * Copyright © 2025 [Jonathan Dowland], all rights reserved.

Distributed under the GNU General Public License, version 3. See [LICENSE](LICENSE).

[Markdown]: https://commonmark.org/
[Jonathan Dowland]: https://jmtd.net/
[Vimwiki]: https://github.com/vimwiki/vimwiki
[Neovim]: https://neovim.io/
[Potwiki]: https://www.vim.org/scripts/script.php?script_id=1018
