return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  config = function()
      local configs = require"nvim-treesitter"
      configs.setup({
      highlight = {
	  enable = true,
      },
      indent = { enable = true },
      autotage = { enable = true },
      ensure_installed = {
	    "lua",
	    "typescript",
	    "tsx",
	    "rust",
      },
      auto_install = false,
    })
    end
}
