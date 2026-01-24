vim.cmd([[set runtimepath=$VIMRUNTIME]])
vim.opt.packpath = { '/home/fool/.local/share/nvim/site' }

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

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git', 'clone', '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
    'rebelot/kanagawa.nvim',
    'nvim-treesitter/nvim-treesitter',
    'neovim/nvim-lspconfig',
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-buffer',
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
    'nvim-lualine/lualine.nvim',
    'nvim-tree/nvim-tree.lua',
    'nvim-tree/nvim-web-devicons',
    'lewis6991/gitsigns.nvim',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'tpope/vim-fugitive',
    'tpope/vim-surround',
    'windwp/nvim-autopairs',
    'numToStr/Comment.nvim',
})

vim.cmd('colorscheme kanagawa')

require('nvim-treesitter.configs').setup({
    ensure_installed = { 'lua', 'vim', 'vimdoc', 'query', 'python', 'javascript', 'typescript', 'rust', 'go', 'java', 'bash', 'yaml', 'json', 'toml', 'markdown', 'markdown_inline' },
    highlight = { enable = true },
    indent = { enable = true },
})

require('nvim-lspconfig').setup({
    ensure_installed = { 'lua_ls', 'pyright', 'tsserver', 'rust_analyzer', 'gopls', 'jdtls', 'bashls', 'jsonls', 'yamlls', 'eslint', 'tailwindcss' },
    handlers = {
        function(server_name)
            require('lspconfig')[server_name].setup({})
        end,
    },
})

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
    }),
})

require('lualine').setup({ options = { theme = 'kanagawa' } })
require('nvim-tree').setup()
require('gitsigns').setup()
require('nvim-autopairs').setup()
require('Comment').setup()

vim.keymap.set('n', '<Space>', '', {})
vim.g.mapleader = ' '

vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')
vim.keymap.set('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>')
vim.keymap.set('n', '<leader>q', ':q<CR>')
vim.keymap.set('n', '<leader>w', ':w<CR>')
vim.keymap.set('n', '<leader>o', 'o<Esc>')
vim.keymap.set('n', '<leader>O', 'O<Esc>')
vim.keymap.set('n', '<leader>p', '"+p')
vim.keymap.set('v', '<leader>y', '"+y')

vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = '*',
    callback = function(args)
        require('conform').format({ bufnr = args.buf })
    end,
})