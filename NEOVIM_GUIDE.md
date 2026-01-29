# jArch Neovim Configuration Guide

This guide covers the enhanced Neovim setup included in jArch.

## Table of Contents

- [Plugins Included](#plugins-included)
- [Keybindings](#keybindings)
- [Features](#features)
- [Customization](#customization)

## Plugins Included

### Core Functionality

| Plugin | Purpose |
|--------|---------|
| **kanagawa.nvim** | Beautiful colorscheme with balanced colors |
| **nvim-treesitter** | Advanced syntax highlighting and code understanding |
| **nvim-lspconfig** | LSP (Language Server Protocol) configuration |
| **mason.nvim** | LSP server manager |
| **nvim-cmp** | Autocompletion engine |

### Productivity

| Plugin | Purpose |
|--------|---------|
| **telescope.nvim** | Fuzzy finder for files, grep, buffers, and more |
| **harpoon** | Quick file navigation (mark and jump to files) |
| **which-key.nvim** | Shows available keybindings as you type |
| **nvim-tree.lua** | File explorer tree view |

### Git Integration

| Plugin | Purpose |
|--------|---------|
| **gitsigns.nvim** | Git diff signs in the gutter |
| **vim-fugitive** | Git commands within Neovim |

### Code Enhancement

| Plugin | Purpose |
|--------|---------|
| **conform.nvim** | Code formatting (auto-format on save) |
| **nvim-autopairs** | Automatically close brackets, quotes, etc. |
| **Comment.nvim** | Easy commenting (gcc to toggle line comment) |
| **vim-surround** | Easily change surrounding characters (cs"') |

### UI Improvements

| Plugin | Purpose |
|--------|---------|
| **lualine.nvim** | Beautiful status line |
| **bufferline.nvim** | Buffer tabs at the top |
| **indent-blankline.nvim** | Indent guides |
| **todo-comments.nvim** | Highlight and search TODO comments |

## Keybindings

Leader key: `<Space>`

### File Operations

| Key | Action |
|-----|--------|
| `<leader>w` | Save file |
| `<leader>q` | Quit |
| `<leader>Q` | Quit all without saving |

### File Explorer

| Key | Action |
|-----|--------|
| `<leader>e` | Toggle file explorer |
| `<leader>E` | Focus file explorer |

### Fuzzy Finding (Telescope)

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep (search in files) |
| `<leader>fb` | Find buffers |
| `<leader>fh` | Help tags |
| `<leader>fr` | Recent files |
| `<leader>fc` | Commands |
| `<leader>ft` | Find TODOs |

### Harpoon (Quick Navigation)

| Key | Action |
|-----|--------|
| `<leader>a` | Add current file to Harpoon |
| `<leader>h` | Toggle Harpoon menu |
| `<leader>1-4` | Jump to Harpoon file 1-4 |

**Harpoon Workflow:**
1. Open files you work with frequently
2. Press `<leader>a` in each file to mark them
3. Use `<leader>1`, `<leader>2`, etc. to instantly jump between them

### LSP (Language Server)

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Go to references |
| `gi` | Go to implementation |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>f` | Format file |

### Buffer Navigation

| Key | Action |
|-----|--------|
| `<leader>bn` | Next buffer |
| `<leader>bp` | Previous buffer |
| `<leader>bd` | Delete buffer |

### Window Navigation

| Key | Action |
|-----|--------|
| `<C-h>` | Move to left window |
| `<C-j>` | Move to bottom window |
| `<C-k>` | Move to top window |
| `<C-l>` | Move to right window |
| `<leader>sv` | Vertical split |
| `<leader>sh` | Horizontal split |

### Git Operations

| Key | Action |
|-----|--------|
| `<leader>gs` | Git status |
| `<leader>gc` | Git commit |
| `<leader>gp` | Git push |
| `<leader>gl` | Git pull |
| `<leader>gb` | Git blame |

### Editing

| Key | Action |
|-----|--------|
| `<leader>o` | Insert line below (stay in normal mode) |
| `<leader>O` | Insert line above (stay in normal mode) |
| `<leader>p` | Paste from system clipboard |
| `<leader>y` | Yank to system clipboard (visual mode) |
| `<leader>nh` | Clear search highlight |
| `gcc` | Toggle line comment |
| `gc` | Comment motion (e.g., `gcip` comments paragraph) |
| `<A-j>` | Move line down |
| `<A-k>` | Move line up |

### Visual Mode

| Key | Action |
|-----|--------|
| `<` | Indent left (stays in visual mode) |
| `>` | Indent right (stays in visual mode) |
| `<A-j>` | Move selection down |
| `<A-k>` | Move selection up |

## Features

### Auto-Format on Save

Files are automatically formatted when you save them. Formatters included:

- **Lua**: stylua
- **Python**: black
- **JavaScript/TypeScript**: prettier
- **Rust**: rustfmt
- **Go**: gofmt

### Language Servers

LSP servers automatically installed for:

- Lua (lua_ls)
- Python (pyright)
- JavaScript/TypeScript (tsserver)
- Rust (rust_analyzer)
- Go (gopls)
- Java (jdtls)
- Bash (bashls)
- JSON (jsonls)
- YAML (yamlls)
- ESLint
- TailwindCSS

### Syntax Highlighting

Treesitter parsers installed for:

- Lua, Vim, Python, JavaScript, TypeScript, Rust, Go, Java
- C, C++, Bash, YAML, JSON, TOML
- HTML, CSS, Markdown

### TODO Comments

Highlight special comments in your code:

```lua
-- TODO: something to do
-- HACK: hacky solution
-- WARN: warning
-- PERF: performance issue
-- NOTE: note
-- FIX: fix this
```

Use `<leader>ft` to search all TODOs in your project.

## Customization

### Changing Colorscheme

Edit `~/.config/nvim/init.lua` and change:

```lua
vim.cmd('colorscheme kanagawa')
```

To another theme like:
```lua
vim.cmd('colorscheme tokyonight')
vim.cmd('colorscheme gruvbox')
vim.cmd('colorscheme catppuccin')
```

(Remember to add the theme plugin to the plugin list first)

### Adding More Plugins

Edit `~/.config/nvim/init.lua` and add to the plugin list:

```lua
require('lazy').setup({
    -- ... existing plugins ...
    'author/plugin-name',
    {
        'author/plugin-name',
        config = function()
            require('plugin').setup()
        end
    },
})
```

### Changing Keybindings

Add or modify keybindings in `~/.config/nvim/init.lua`:

```lua
vim.keymap.set('n', '<leader>x', ':YourCommand<CR>', { desc = 'Description' })
```

- First argument: mode (`'n'` = normal, `'i'` = insert, `'v'` = visual)
- Second argument: key combination
- Third argument: command or function
- `desc`: description shown in which-key

## Tips and Tricks

### Telescope Tips

1. In Telescope, use `<C-c>` to close
2. Use `<C-n>`/`<C-p>` or arrow keys to navigate
3. Start typing to filter results
4. Press `?` in Telescope for more actions

### Harpoon Workflow

Harpoon is perfect for working on a feature:

1. Open your main files (e.g., component, test, config)
2. Mark each with `<leader>a`
3. Now `<leader>1`, `<leader>2`, etc. instantly jump between them
4. Much faster than searching each time!

### LSP Features

- Hover over any symbol and press `K` for documentation
- Use `gd` to jump to where something is defined
- Press `<leader>ca` for quick fixes and refactoring options
- Use `<leader>rn` to rename a variable everywhere

### Which-Key

Start typing `<leader>` and wait a moment - a popup will show all available keybindings!

### Bufferline

Click on buffer tabs with your mouse, or use `<leader>bn`/`<leader>bp` to cycle through them.

## Common Workflows

### Starting a New Project

1. `cd` into project directory
2. Run `nvim .` to open with file explorer
3. Use `<leader>ff` to find files
4. Mark important files with `<leader>a`
5. Use `<leader>1-4` to jump between marked files

### Searching in Project

1. Press `<leader>fg` for live grep
2. Type your search term
3. Navigate results with `<C-n>`/`<C-p>`
4. Press `<CR>` to open file

### Git Workflow

1. `<leader>gs` to see status
2. Make changes
3. `<leader>gc` to commit
4. `<leader>gp` to push
5. Git signs in gutter show changes inline

### Refactoring Code

1. Put cursor on symbol
2. Press `<leader>rn` for rename
3. Type new name
4. All references updated!

## Troubleshooting

### LSP Not Working

1. Open Neovim
2. Run `:Mason` to check if servers are installed
3. Run `:LspInfo` to see active servers

### Plugins Not Loading

1. Run `:Lazy` to open plugin manager
2. Press `S` to sync/install plugins
3. Restart Neovim

### Format Not Working

Ensure formatter is installed:
- Python: `pip install black`
- JavaScript: `npm install -g prettier`
- Lua: `cargo install stylua`

## Learning Resources

- `:help` - Built-in help (e.g., `:help telescope`)
- `:Tutor` - Vim tutorial
- `:checkhealth` - Check Neovim configuration

---

**Happy coding with jArch Neovim!** 🚀
