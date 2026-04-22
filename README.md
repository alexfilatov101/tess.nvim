# Tess
Terminal session storage plugin for neovim.

Sessions use vim built-in count, i.e. pressing ```2<leader>t``` will open session #2

Session history is stored alongside project in `.nvim/tess/history` folder. You can disable this functionality by setting `shell.history.enabled` to `false`. This folder is added to .gitignore by default

Right now `bash` is the only supported shell, though some others might work as well. _Basically, for shell to be supported in current version of tess, it has to implement --rcfile flag for sourcing files, and HISTFILE env variable to load history_

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

Default setup:

```lua
{
  "alexfilatov101/tess.nvim",
  config = function()
    require("tess").setup({

      -- Shell setup
	    shell = {
        -- shell to run in new session
	    	app = "bash",
        -- history setup
	    	history = {
          -- enable per-session history
	    		enabled = true,
          -- max history size
	    		size = 10000,
          -- max history file size
	    		filesize = 20000,
	    	},
        -- file to source on startup
	    	source = nil,
        -- working directory for new session
        -- win = relative to current window file folder
        -- anything else - relative to project root
	    	relative = "win",
	    },

      -- Window setup
      -- vim.api.keyset.win_config
      -- VS Code - style terminal
      win = {
        split = "below",
        height = 16,
      },
      -- setup below creates new centered floating window
      -- win = {
      --   relative = "editor",
      --   anchor = "NW",
      --   row = 3,
      --   col = 20,
      --   width = vim.o.columns - 40,
      --   height = vim.o.lines - 8,
      --   border = "single",
      --   title_pos = "center",
      -- },

      -- Keybinds
      binds = {
        open = "<leader>t", -- open session (creates new on first call)
        override = "<leader>to", -- override old session
        rename = "<C-n>", -- rename window
        hide = "<ESC>", -- close window
        close = "<C-q>", -- kill session
        normal = "jk", -- exit terminal mode
        next = "<C-l>", -- switch to next session, create one if needed. Works with vim.v.count
        prev = "<C-h>" -- switch to previous session, create on if needed. Works with vim.v.count
      }
    })
}
```
```
```
```


## TODO

[x] Simple terminal sessions
[x] Session restoration
[ ] Session groups
[ ] Other shell integrations
