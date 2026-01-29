vim.cmd([[set runtimepath=$VIMRUNTIME]])
vim.opt.packpath = { vim.fn.stdpath('data') .. '/site' }

-- Basic settings
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = false
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hidden = true
vim.o.backup = false
vim.o.writebackup = false
vim.o.undofile = true
vim.o.updatetime = 300
vim.o.signcolumn = 'yes'
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8
vim.o.termguicolors = true
vim.o.mouse = 'a'
vim.o.clipboard = 'unnamedplus'
vim.o.completeopt = 'menu,menuone,noselect'
vim.o.cursorline = true
vim.o.splitright = true
vim.o.splitbelow = true

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git', 'clone', '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin setup
require('lazy').setup({
    -- Colorscheme
    'rebelot/kanagawa.nvim',
    
    -- Syntax highlighting
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
    },
    
    -- LSP
    'neovim/nvim-lspconfig',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-buffer',
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
    
    -- Fuzzy finder
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make'
    },
    
    -- File explorer
    'nvim-tree/nvim-tree.lua',
    'nvim-tree/nvim-web-devicons',
    
    -- Status line
    'nvim-lualine/lualine.nvim',
    
    -- Git integration
    'lewis6991/gitsigns.nvim',
    'tpope/vim-fugitive',
    
    -- Quick navigation
    {
        'ThePrimeagen/harpoon',
        branch = 'harpoon2',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    
    -- Better surround
    'tpope/vim-surround',
    
    -- Auto pairs
    'windwp/nvim-autopairs',
    
    -- Comments
    'numToStr/Comment.nvim',
    
    -- Formatting
    'stevearc/conform.nvim',
    
    -- Which-key (shows keybindings)
    {
        'folke/which-key.nvim',
        event = 'VeryLazy',
    },
    
    -- Indent guides
    {
        'lukas-reineke/indent-blankline.nvim',
        main = 'ibl',
    },
    
    -- Todo comments
    {
        'folke/todo-comments.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
    },
    
    -- Better buffer line
    {
        'akinsho/bufferline.nvim',
        dependencies = 'nvim-tree/nvim-web-devicons'
    },
})

-- Colorscheme
vim.cmd('colorscheme kanagawa')

-- Treesitter setup
require('nvim-treesitter.configs').setup({
    ensure_installed = { 
        'lua', 'vim', 'vimdoc', 'query', 
        'python', 'javascript', 'typescript', 'tsx',
        'rust', 'go', 'java', 'c', 'cpp',
        'bash', 'yaml', 'json', 'toml', 
        'markdown', 'markdown_inline',
        'html', 'css'
    },
    highlight = { enable = true },
    indent = { enable = true },
})

-- Mason setup
require('mason').setup()
require('mason-lspconfig').setup({
    ensure_installed = { 
        'lua_ls', 'pyright', 'tsserver', 
        'rust_analyzer', 'gopls', 'jdtls', 
        'bashls', 'jsonls', 'yamlls', 
        'eslint', 'tailwindcss'
    },
    handlers = {
        function(server_name)
            require('lspconfig')[server_name].setup({})
        end,
    },
})

-- Completion setup
local cmp = require('cmp')
cmp.setup({
    sources = {
        { name = 'nvim_lsp' },
        { name = 'buffer' },
        { name = 'path' },
        { name = 'luasnip' },
    },
    mapping = cmp.mapping.preset.insert({
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping.select_next_item(),
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        ['<C-Space>'] = cmp.mapping.complete(),
    }),
})

-- Telescope setup
local telescope = require('telescope')
telescope.setup({
    defaults = {
        layout_strategy = 'horizontal',
        layout_config = {
            horizontal = {
                preview_width = 0.55,
            },
        },
    },
})
telescope.load_extension('fzf')

-- Harpoon setup
local harpoon = require('harpoon')
harpoon:setup()

-- Other plugin setups
require('lualine').setup({ options = { theme = 'kanagawa' } })
require('nvim-tree').setup()
require('gitsigns').setup()
require('nvim-autopairs').setup()
require('Comment').setup()
require('which-key').setup()
require('ibl').setup()
require('todo-comments').setup()
require('bufferline').setup({
    options = {
        mode = 'buffers',
        separator_style = 'slant',
        diagnostics = 'nvim_lsp',
    }
})

-- Formatting setup
require('conform').setup({
    formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'black' },
        javascript = { 'prettier' },
        typescript = { 'prettier' },
        rust = { 'rustfmt' },
        go = { 'gofmt' },
    },
})

-- Auto-format on save
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = '*',
    callback = function(args)
        require('conform').format({ bufnr = args.buf })
    end,
})

-- Leader key
vim.keymap.set('n', '<Space>', '', {})
vim.g.mapleader = ' '

-- File operations
vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = 'Save file' })
vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = 'Quit' })
vim.keymap.set('n', '<leader>Q', ':qa!<CR>', { desc = 'Quit all without saving' })

-- File explorer
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle file explorer' })
vim.keymap.set('n', '<leader>E', ':NvimTreeFocus<CR>', { desc = 'Focus file explorer' })

-- Telescope fuzzy finder
vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>', { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>', { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>', { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fh', ':Telescope help_tags<CR>', { desc = 'Help tags' })
vim.keymap.set('n', '<leader>fr', ':Telescope oldfiles<CR>', { desc = 'Recent files' })
vim.keymap.set('n', '<leader>fc', ':Telescope commands<CR>', { desc = 'Commands' })

-- Harpoon quick navigation
vim.keymap.set('n', '<leader>a', function() harpoon:list():add() end, { desc = 'Harpoon add file' })
vim.keymap.set('n', '<leader>h', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = 'Harpoon menu' })
vim.keymap.set('n', '<leader>1', function() harpoon:list():select(1) end, { desc = 'Harpoon file 1' })
vim.keymap.set('n', '<leader>2', function() harpoon:list():select(2) end, { desc = 'Harpoon file 2' })
vim.keymap.set('n', '<leader>3', function() harpoon:list():select(3) end, { desc = 'Harpoon file 3' })
vim.keymap.set('n', '<leader>4', function() harpoon:list():select(4) end, { desc = 'Harpoon file 4' })

-- LSP keymaps
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'Go to declaration' })
vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'Go to references' })
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = 'Go to implementation' })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover documentation' })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename symbol' })
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })
vim.keymap.set('n', '<leader>f', function() require('conform').format({ async = true }) end, { desc = 'Format file' })

-- Buffer navigation
vim.keymap.set('n', '<leader>bn', ':bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<leader>bp', ':bprevious<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', { desc = 'Delete buffer' })

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to bottom window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to top window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- Split windows
vim.keymap.set('n', '<leader>sv', ':vsplit<CR>', { desc = 'Vertical split' })
vim.keymap.set('n', '<leader>sh', ':split<CR>', { desc = 'Horizontal split' })

-- Git operations
vim.keymap.set('n', '<leader>gs', ':Git<CR>', { desc = 'Git status' })
vim.keymap.set('n', '<leader>gc', ':Git commit<CR>', { desc = 'Git commit' })
vim.keymap.set('n', '<leader>gp', ':Git push<CR>', { desc = 'Git push' })
vim.keymap.set('n', '<leader>gl', ':Git pull<CR>', { desc = 'Git pull' })
vim.keymap.set('n', '<leader>gb', ':Git blame<CR>', { desc = 'Git blame' })

-- Clipboard operations
vim.keymap.set('n', '<leader>o', 'o<Esc>', { desc = 'Insert line below' })
vim.keymap.set('n', '<leader>O', 'O<Esc>', { desc = 'Insert line above' })
vim.keymap.set('n', '<leader>p', '"+p', { desc = 'Paste from system clipboard' })
vim.keymap.set('v', '<leader>y', '"+y', { desc = 'Yank to system clipboard' })

-- Todo comments
vim.keymap.set('n', '<leader>ft', ':TodoTelescope<CR>', { desc = 'Find todos' })

-- Better visual mode indenting
vim.keymap.set('v', '<', '<gv', { desc = 'Indent left' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent right' })

-- Move lines up/down
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { desc = 'Move line down' })
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==', { desc = 'Move line up' })
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Clear search highlight
vim.keymap.set('n', '<leader>nh', ':nohlsearch<CR>', { desc = 'Clear search highlight' })
