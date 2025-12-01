# Tess
Terminal session storage plugin for neovim.

Sessions use vim built-in count, i.e. pressing ```2<leader>t``` will open session #2.

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

Default setup

```lua
{
  "alexfilatov101/tess.nvim",
  config = function()
    require("tess").setup({
      -- Window setup
      -- vim.api.keyset.win_config
      win = {
        relative = "editor",
        anchor = "NW",
        row = 3,
        col = 20,
        width = vim.o.columns - 40,
        height = vim.o.lines - 8,
        border = "single",
        title_pos = "center",
      },
      -- Keybinds
      binds = {
        open = "<leader>t",
        override = "<leader>to", -- kill old session and create neovimw
        rename = "<C-n>", -- rename window
        hide = "<ESC>", -- close window
        close = "<C-q>", -- kill session
        normal = "jk", -- exit terminal mode
      }
    })
}
```
```
```
```


## TODO

[x] Simple terminal sessions
[ ] Session restoration
[ ] Session groups
