{
  lib,
  ...
}:
let
  lua = expr: {
    __raw = expr;
  };

  emacsMove = [
    {
      mode = [
        "i"
        "c"
      ];
      key = "<C-f>";
      action = "<Right>";
      options.desc = "Forward char";
    }
    {
      mode = [
        "i"
        "c"
      ];
      key = "<C-b>";
      action = "<Left>";
      options.desc = "Backward char";
    }
    {
      mode = [
        "i"
        "c"
      ];
      key = "<C-p>";
      action = "<Up>";
      options.desc = "Previous line";
    }
    {
      mode = [
        "i"
        "c"
      ];
      key = "<C-n>";
      action = "<Down>";
      options.desc = "Next line";
    }
    {
      mode = [
        "i"
        "c"
      ];
      key = "<C-a>";
      action = "<Home>";
      options.desc = "Beginning of line";
    }
    {
      mode = [
        "i"
        "c"
      ];
      key = "<C-e>";
      action = "<End>";
      options.desc = "End of line";
    }
    {
      mode = [
        "i"
        "c"
      ];
      key = "<C-d>";
      action = "<Del>";
      options.desc = "Delete char";
    }
    {
      mode = "i";
      key = "<C-k>";
      action = "<C-o>d$";
      options.desc = "Kill to end of line";
    }
    {
      mode = "i";
      key = "<M-f>";
      action = "<C-o>w";
      options.desc = "Forward word";
    }
    {
      mode = "i";
      key = "<M-b>";
      action = "<C-o>b";
      options.desc = "Backward word";
    }
  ];
in
{
  keymaps = emacsMove ++ [
    {
      mode = "i";
      key = "<Esc>";
      action = "<Nop>";
      options.desc = "Disabled: use C-g C-g";
    }
    {
      mode = "i";
      key = "<C-g><C-g>";
      action = "<Esc>";
      options.desc = "Leave insert mode";
    }
    {
      mode = [
        "i"
        "n"
      ];
      key = "<C-Space>";
      action = "<Esc>v";
      options.desc = "Start visual selection";
    }
    {
      mode = [
        "i"
        "n"
      ];
      key = "<M-x>";
      action = lua "function() require('fzf-lua').commands() end";
      options.desc = "M-x commands";
    }
    {
      mode = [
        "i"
        "n"
      ];
      key = "<F1>";
      action = lua "function() require('fzf-lua').helptags() end";
      options.desc = "Help";
    }
    {
      mode = [
        "i"
        "n"
      ];
      key = "<C-M-x>";
      action = lua "function() require('my.eval').lua() end";
      options.desc = "Eval Lua";
    }
    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "<C-;>";
      action = lua "function() require('flash').jump() end";
      options.desc = "Flash jump";
    }
    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "<C-/>";
      action = lua "function() require('flash').treesitter() end";
      options.desc = "Flash treesitter";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-s>";
      action = lua "function() require('fzf-lua').blines() end";
      options.desc = "Search current buffer";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-M-s>";
      action = lua "function() require('fzf-lua').live_grep() end";
      options.desc = "Ripgrep";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x><C-f>";
      action = lua "function() require('fzf-lua').files() end";
      options.desc = "Find file";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x>b";
      action = lua "function() require('fzf-lua').buffers() end";
      options.desc = "Switch buffer";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x>k";
      action = "<Cmd>bdelete<CR>";
      options.desc = "Kill buffer";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x><C-s>";
      action = "<Cmd>write<CR>";
      options.desc = "Save buffer";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x>u";
      action = "<Cmd>undo<CR>";
      options.desc = "Undo";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x>r";
      action = "<Cmd>redo<CR>";
      options.desc = "Redo";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<M-l>d";
      action = lua "function() vim.lsp.buf.definition() end";
      options.desc = "LSP definition";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<M-l>r";
      action = lua "function() vim.lsp.buf.rename() end";
      options.desc = "LSP rename";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<M-l>a";
      action = lua "function() vim.lsp.buf.code_action() end";
      options.desc = "LSP code action";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<M-l>f";
      action = lua "function() require('conform').format({ async = true, lsp_format = 'fallback' }) end";
      options.desc = "Format";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<M-I>";
      action = lua "function() require('my.special_edit').pick_pane() end";
      options.desc = "Special edit for WezTerm pane";
    }
  ];
}
