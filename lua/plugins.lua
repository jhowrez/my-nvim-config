return {
	{ 'nvim-telescope/telescope.nvim', tag = '0.1.6', dependencies = {'nvim-lua/plenary.nvim'} },
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
	{ 'nvim-lualine/lualine.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' } },
}
