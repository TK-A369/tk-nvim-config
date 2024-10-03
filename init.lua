vim.fn['plug#begin']()
local plugs = {
	'nvim-lua/plenary.nvim',
	'nvim-lua/popup.nvim',
	'neovim/nvim-lspconfig',
	'williamboman/mason.nvim',
	'williamboman/mason-lspconfig.nvim',
	'NLKNguyen/papercolor-theme',
	'nvim-telescope/telescope.nvim',
	'hrsh7th/cmp-nvim-lsp',
	'hrsh7th/cmp-buffer',
	'hrsh7th/cmp-path',
	'hrsh7th/cmp-cmdline',
	'hrsh7th/nvim-cmp',
	'hrsh7th/cmp-vsnip',
	'hrsh7th/vim-vsnip',
	'scalameta/nvim-metals',
	{ 'nvim-treesitter/nvim-treesitter', '{\'do\': \':TSUpdate\'}' }
}
for _, v in ipairs(plugs) do
	if type(v) == 'table' then
		vim.cmd("Plug \'" .. v[1] .. "\', " .. v[2])
	else
		vim.cmd("Plug \'" .. v .. "\'")
	end
end
vim.fn['plug#end']()

local mason = require('mason')
mason.setup()

vim.cmd.colorscheme('industry')

vim.cmd.syntax('on')
vim.opt.number = true
vim.opt.incsearch = true
vim.opt.visualbell = true
vim.opt.tabstop = 4
vim.opt.ruler = true
vim.opt.smartindent = true
vim.opt.shiftwidth = 4
vim.opt.virtualedit = 'onemore'
vim.opt.autoindent = true
vim.opt.mouse = 'a'

-- Telescope keybindings
local telescope_builtin = require('telescope.builtin')
vim.keymap.set('n', ',cs', telescope_builtin.colorscheme)
vim.keymap.set('n', ',f', telescope_builtin.find_files)

-- LSP keybindings
vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration)
vim.keymap.set('n', 'gr', vim.lsp.buf.references)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation)
vim.keymap.set({ 'n', 'i' }, '<C-k>', vim.lsp.buf.signature_help)
vim.keymap.set('n', 'gh', vim.lsp.buf.hover)
vim.keymap.set({ 'n', 'v' }, 'gf', vim.lsp.buf.format)
vim.keymap.set('n', 'gn', vim.lsp.buf.rename)
vim.keymap.set({ 'n', 'v' }, 'ga', vim.lsp.buf.code_action)


-- Autocompletion
local cmp = require('cmp')
cmp.setup({
	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body)
		end
	},
	window = {},
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' }
	}, {
		{ name = 'buffer' }
	})
})

-- LSP setup
local lspconfig = require('lspconfig')
local lsps = {
	rust_analyzer = {},
	--[[omnisharp={
		-- on_attach = on_attach,
		-- capabilities = capabilities,
		-- cmd = {os.getenv('OMNISHARP_LANGUAGE_SERVER'), '--languageserver', 'hostPID', tostring(pid)}
		cmd = {'omnisharp', '--languageserver', '--hostPID', tostring(vim.fn.getpid())}
	},--]]
	csharp_ls = {},
	lua_ls = {},
	clangd = {},
	--[[pylsp = {
		settings = {
			pylsp = {
				plugins = {
					pycodestyle = {
					}
				}
			}
		}
	}--]]
	jedi_language_server = {},
	ts_ls = {},
	eslint = {},
	html = {},
	jdtls = {}, --Consider https://github.com/mfussenegger/nvim-jdtls instead
	zls = { settings = {} },
	gopls = {}
}
for k, v in pairs(lsps) do
	lspconfig[k].setup(v)
end

-- Metals
local metals = require('metals')
local metals_config = metals.bare_config()
metals_config.init_options.statusBarProvider = "off"
metals_config.capabilities = require('cmp_nvim_lsp').default_capabilities()
metals_config.on_attach = function(client, bufnr)
	-- metals.setup_dap()
end
local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	pattern = { 'scala', 'sbt' },
	callback = function()
		metals.initialize_or_attach(metals_config)
	end,
	group = nvim_metals_group
})
