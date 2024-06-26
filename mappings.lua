-- Mapping data with "desc" stored directly by vim.keymap.set().
--
-- Please use this mappings table to set keyboard mapping since this is the
-- lower level configuration and more robust one. (which-key will
-- automatically pick-up stored data by this setting.)
return {
  -- first key is the mode
  n = {
    -- second key is the lefthand side of the map

    -- navigate buffer tabs with `H` and `L`
    L = {
      function() require("astronvim.utils.buffer").nav(vim.v.count > 0 and vim.v.count or 1) end,
      desc = "Next buffer",
    },
    H = {
      function() require("astronvim.utils.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1)) end,
      desc = "Previous buffer",
    },

    -- mappings seen under group name "Buffer"
    ["<leader>bD"] = {
      function()
        require("astronvim.utils.status").heirline.buffer_picker(
          function(bufnr) require("astronvim.utils.buffer").close(bufnr) end
        )
      end,
      desc = "Pick to close",
    },
    -- tables with the `name` key will be registered with which-key if it's installed
    -- this is useful for naming menus
    ["<leader>b"] = { name = "Buffers" },
    -- quick save
    -- ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command
    ["<leader>-"] = { "<cmd>IndentBlanklineDisable<cr><cmd>set list!<cr>",
      desc = "Toggle show whitespaces"
    },
    -- speed up motion
    J = { "3j", desc = "Move down 3 lines" },
    K = { "3k", desc = "Move up 3 lines" },
    -- move lines up/down
    ["<A-j>"] = { ":m .+1<CR>==", desc = "Move lines down" },
    ["<A-k>"] = { ":m .-2<CR>==" , desc = "Move lines up" },
    -- append semicolon
    ["<leader>;"] = { "g_a;<esc>", desc = "Append semicolon" },
    -- switch source/header clang
    ["<F2>"] = { function() vim.lsp.buf.definition() end, desc = "Show the definition" },
    ["<F4>"] = { "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch to Source/Header" },
  },
  i = {
    ["<C-s>"] = { "<esc><cmd>w<cr>", desc = "Save" },
  },
  v = {
    ["<C-s>"] = { "<esc><cmd>w<cr>", desc = "Save" },
    ["p"] = { "pgvy" },
    -- move lines up/down
    ["<A-j>"] = { ":m '>+1<CR>gv=gv", desc = "Move lines down" },
    ["<A-k>"] = { ":m '<-2<CR>gv=gv" , desc = "Move lines up" },
  },
  t = {
    -- setting a mapping to false will disable it
    -- ["<esc>"] = false,
  },
}
