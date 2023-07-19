useful keymappings for testing with [Plenary](https://github.com/nvim-lua/plenary.nvim)

```lua
keymap("n", "<leader>tf", "<Plug>PlenaryTestFile", { desc = " Test File" })
keymap("n", "<leader>td", "<cmd>PlenaryBustedDirectory .<CR>", { desc = " Tests in Directory" })
```
