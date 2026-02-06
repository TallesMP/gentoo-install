return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  config = function()
    require('dashboard').setup {
      theme = 'doom',
      config = {
        header = {
	    '',
	},
        center = {
          {
            icon = ' ',
            icon_hl = 'Title',
            desc = 'Find File           ',
            desc_hl = 'String',
            key = 'f',
            key_hl = 'Number',
            key_format = ' %s',
            action = 'lua print(2)',
          },
          {
            icon = ' ',
            desc = 'Config',
            key = 'c',
            key_format = ' %s',
            action = 'lua print(3)',
          },
	  {
            icon = '󰞓 ',
            desc = 'Quit',
            key = 'q',
            key_format = ' %s',
            action = 'q',
          },
        },
        footer = {
	 ' '
	 },
	},
        vertical_center = false, -- Center the Dashboard on the vertical (from top to bottom)
    }
  end,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
}
