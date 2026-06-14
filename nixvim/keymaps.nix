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
      mode = "x";
      key = "<C-f>";
      action = "l";
      options.desc = "Forward char";
    }
    {
      mode = "x";
      key = "<C-b>";
      action = "h";
      options.desc = "Backward char";
    }
    {
      mode = "x";
      key = "<C-p>";
      action = "k";
      options.desc = "Previous line";
    }
    {
      mode = "x";
      key = "<C-n>";
      action = "j";
      options.desc = "Next line";
    }
    {
      mode = [
        "i"
        "n"
        "x"
      ];
      key = "<C-a>";
      action = lua "function() require('my.editor').move_beginning_of_line() end";
      options.desc = "Back to indentation or beginning";
    }
    {
      mode = "c";
      key = "<C-a>";
      action = "<Home>";
      options.desc = "Beginning of command line";
    }
    {
      mode = [
        "i"
        "c"
        "x"
      ];
      key = "<C-e>";
      action = "<End>";
      options.desc = "End of line";
    }
    {
      mode = "i";
      key = "<C-d>";
      action = lua "function() require('softpair').forward_delete_char() end";
      options.desc = "Softpair forward delete char";
    }
    {
      mode = "c";
      key = "<C-d>";
      action = "<Del>";
      options.desc = "Delete char";
    }
    {
      mode = [
        "i"
        "n"
      ];
      key = "<C-k>";
      action = lua "function() require('softpair').kill_line() end";
      options.desc = "Softpair kill line";
    }
    {
      mode = [
        "i"
        "n"
      ];
      key = "<C-S-k>";
      action = lua "function() require('softpair').backward_kill_line() end";
      options.desc = "Softpair backward kill line";
    }
    {
      mode = [
        "i"
        "n"
      ];
      key = "<M-C-d>";
      action = lua "function() require('softpair').backward_kill_word() end";
      options.desc = "Softpair backward kill word";
    }
    {
      mode = [
        "i"
        "n"
      ];
      key = "<M-BS>";
      action = lua "function() require('softpair').backward_kill_word() end";
      options.desc = "Softpair backward kill word";
    }
    {
      mode = [
        "i"
        "n"
      ];
      key = "<M-Del>";
      action = lua "function() require('softpair').backward_kill_word() end";
      options.desc = "Softpair backward kill word";
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
    {
      mode = "x";
      key = "<M-f>";
      action = "w";
      options.desc = "Forward word";
    }
    {
      mode = "x";
      key = "<M-b>";
      action = "b";
      options.desc = "Backward word";
    }
    {
      mode = [
        "i"
        "n"
      ];
      key = "<M-d>";
      action = lua "function() require('softpair').forward_kill_word() end";
      options.desc = "Softpair forward kill word";
    }
    {
      mode = [
        "i"
        "n"
        "x"
      ];
      key = "<M-C-f>";
      action = lua "function() require('softpair').forward_sexp() end";
      options.desc = "Softpair forward sexp";
    }
    {
      mode = [
        "i"
        "n"
        "x"
      ];
      key = "<M-C-b>";
      action = lua "function() require('softpair').backward_sexp() end";
      options.desc = "Softpair backward sexp";
    }
    {
      mode = [
        "i"
        "n"
        "x"
      ];
      key = "<M-C-a>";
      action = lua "function() require('softpair').beginning_of_sexp() end";
      options.desc = "Softpair beginning of sexp";
    }
    {
      mode = [
        "i"
        "n"
        "x"
      ];
      key = "<M-C-e>";
      action = lua "function() require('softpair').end_of_sexp() end";
      options.desc = "Softpair end of sexp";
    }
    {
      mode = [
        "i"
        "n"
        "x"
      ];
      key = "<M-(>";
      action = lua "function() require('softpair').syntactic_backward_punct() end";
      options.desc = "Softpair syntactic backward punct";
    }
    {
      mode = [
        "i"
        "n"
        "x"
      ];
      key = "<M-)>";
      action = lua "function() require('softpair').syntactic_forward_punct() end";
      options.desc = "Softpair syntactic forward punct";
    }
    {
      mode = [
        "i"
        "n"
      ];
      key = "<C-c><Del>";
      action = lua "function() require('softpair').force_delete() end";
      options.desc = "Softpair force delete";
    }
  ];
in
{
  keymaps = emacsMove ++ [
    {
      mode = "i";
      key = "<Esc>";
      action = "<Nop>";
      options.desc = "Disabled: use F12 F12";
    }
    {
      mode = "i";
      key = "<F12><F12>";
      action = "<Esc>";
      options.desc = "Leave insert mode";
    }
    {
      mode = [
        "i"
        "n"
      ];
      key = "<C-g>";
      action = lua "function() require('my.editor').keyboard_quit() end";
      options = {
        desc = "Keyboard quit";
        nowait = true;
      };
    }
    {
      mode = "c";
      key = "<C-g>";
      action = "<C-c>";
      options.desc = "Cancel command";
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
      mode = "x";
      key = "<C-g>";
      action = "<Esc>";
      options.desc = "Cancel selection";
    }
    {
      mode = [
        "i"
        "n"
      ];
      key = "<M-h>";
      action = lua "function() require('my.region').select_paragraph() end";
      options.desc = "Select paragraph";
    }
    {
      mode = "i";
      key = "<C-y>";
      action = lua "function() require('my.editor').yank() end";
      options.desc = "Yank";
    }
    {
      mode = "x";
      key = "<M-w>";
      action = "y";
      options.desc = "Yank region";
    }
    {
      mode = "x";
      key = "<C-w>";
      action = ":<C-u>lua require('softpair').kill_active_region(vim.fn.visualmode())<CR>";
      options.desc = "Softpair kill region";
    }
    {
      mode = "x";
      key = "<C-y>";
      action = "P";
      options.desc = "Paste over region";
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
      key = "<F1>f";
      action = lua "function() require('fzf-lua').helptags() end";
      options.desc = "Describe function";
    }
    {
      mode = [
        "i"
        "n"
      ];
      key = "<F1>v";
      action = "<Cmd>options<CR>";
      options.desc = "Describe variable";
    }
    {
      mode = [
        "i"
        "n"
      ];
      key = "<F1>k";
      action = lua "function() require('fzf-lua').keymaps() end";
      options.desc = "Describe key";
    }
    {
      mode = [
        "i"
        "n"
      ];
      key = "<F1>m";
      action = lua "function() require('fzf-lua').filetypes() end";
      options.desc = "Describe mode";
    }
    {
      mode = [
        "i"
        "n"
      ];
      key = "<F1>b";
      action = lua "function() require('fzf-lua').keymaps() end";
      options.desc = "Describe bindings";
    }
    {
      mode = [
        "i"
        "n"
      ];
      key = "<F1>i";
      action = lua "function() require('fzf-lua').helptags() end";
      options.desc = "Info";
    }
    {
      mode = [
        "i"
        "n"
      ];
      key = "<F1>a";
      action = lua "function() require('fzf-lua').commands() end";
      options.desc = "Apropos commands";
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
      mode = "n";
      key = "<M-:>";
      action = ":";
      options.desc = "Command";
    }
    {
      mode = "i";
      key = "<M-:>";
      action = "<C-o>:";
      options.desc = "Command";
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
      mode = "x";
      key = "<C-M-s>";
      action = lua "function() require('fzf-lua').grep_visual() end";
      options.desc = "Ripgrep visual selection";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<M-%>";
      action = lua "function() require('my.replace').buffer_literal() end";
      options.desc = "Query replace buffer";
    }
    {
      mode = "x";
      key = "<M-%>";
      action = lua "function() require('my.replace').visual_within_literal() end";
      options.desc = "Query replace region";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-M-%>";
      action = lua "function() require('my.replace').buffer_regexp() end";
      options.desc = "Query replace regexp buffer";
    }
    {
      mode = "x";
      key = "<C-M-%>";
      action = lua "function() require('my.replace').visual_within_regexp() end";
      options.desc = "Query replace regexp region";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<M-;>";
      action = lua "function() require('my.region').comment_current() end";
      options.desc = "Comment line";
    }
    {
      mode = "x";
      key = "<M-;>";
      action = lua "function() require('my.region').comment_visual() end";
      options.desc = "Comment region";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<F3>";
      action = lua "function() require('my.macro').start_or_insert_counter() end";
      options.desc = "Start macro or insert counter";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<F4>";
      action = lua "function() require('my.macro').end_or_call() end";
      options.desc = "End or call macro";
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
      key = "<C-x>d";
      action = lua "function() require('my.project').oil_prompt() end";
      options.desc = "Oil";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x><C-j>";
      action = lua "function() require('my.project').oil_current() end";
      options.desc = "Oil current directory";
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
      key = "<C-x>2";
      action = "<Cmd>split<CR>";
      options.desc = "Split window below";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x>3";
      action = "<Cmd>vsplit<CR>";
      options.desc = "Split window right";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x>0";
      action = lua "function() pcall(vim.cmd.close) end";
      options.desc = "Delete window";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x>1";
      action = "<Cmd>only<CR>";
      options.desc = "Delete other windows";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x>+";
      action = "<Cmd>wincmd =<CR>";
      options.desc = "Balance windows";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x>^";
      action = "<Cmd>resize +3<CR>";
      options.desc = "Enlarge window";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x>{";
      action = "<Cmd>vertical resize -5<CR>";
      options.desc = "Shrink window horizontally";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x>}";
      action = "<Cmd>vertical resize +5<CR>";
      options.desc = "Enlarge window horizontally";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x>o";
      action = lua "function() require('my.hydras').window() end";
      options.desc = "Other window hydra";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x>g";
      action = lua "function() require('my.project').neogit() end";
      options.desc = "Magit status";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x>h";
      action = lua "function() require('my.region').select_all() end";
      options.desc = "Select whole buffer";
    }
    {
      mode = [
        "n"
        "i"
        "x"
      ];
      key = "<C-x><C-x>";
      action = lua "function() require('my.region').exchange_mark() end";
      options.desc = "Exchange point and mark";
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
      action = lua "function() require('my.hydras').undo_then() end";
      options.desc = "Undo hydra";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x>r";
      action = lua "function() require('my.hydras').redo_then() end";
      options.desc = "Redo hydra";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x>(";
      action = lua "function() require('my.macro').start() end";
      options.desc = "Start macro";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x>)";
      action = lua "function() require('my.macro').stop() end";
      options.desc = "End macro";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x>e";
      action = lua "function() require('my.hydras').macro_end_and_call() end";
      options.desc = "Call macro hydra";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x><C-k><C-k>";
      action = lua "function() require('my.macro').end_or_call() end";
      options.desc = "End or call macro";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x><C-k><C-s>";
      action = lua "function() require('my.macro').start() end";
      options.desc = "Start macro";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x><C-k>e";
      action = lua "function() require('my.macro').edit() end";
      options.desc = "Edit macro register";
    }
    {
      mode = "x";
      key = "<C-x><C-k>r";
      action = lua "function() require('my.macro').apply_to_region_lines() end";
      options.desc = "Apply macro to region lines";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x><C-k>x";
      action = lua "function() require('my.macro').copy_to_register() end";
      options.desc = "Copy macro to register";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x>pf";
      action = lua "function() require('my.project').files() end";
      options.desc = "Project files";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x>pg";
      action = lua "function() require('my.project').grep() end";
      options.desc = "Project ripgrep";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x>pb";
      action = lua "function() require('my.project').buffers() end";
      options.desc = "Project buffers";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x>pp";
      action = lua "function() require('my.project').switch() end";
      options.desc = "Switch project";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x>pd";
      action = lua "function() require('my.project').oil_root() end";
      options.desc = "Project Oil";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x>ps";
      action = lua "function() require('my.project').neogit() end";
      options.desc = "Project Git status";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x>pr";
      action = lua "function() require('my.replace').project_literal() end";
      options.desc = "Project query replace";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-x>pR";
      action = lua "function() require('my.replace').project_regexp() end";
      options.desc = "Project query replace regexp";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<M-C-p>";
      action = lua "function() require('my.hydras').softpair() end";
      options.desc = "Softpair hydra";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-c>^";
      action = lua "function() require('my.hydras').conflict() end";
      options.desc = "Git conflict hydra";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<M-l>d";
      action = lua "function() require('fzf-lua').lsp_definitions() end";
      options.desc = "LSP definitions";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<M-l>r";
      action = lua "function() require('fzf-lua').lsp_references() end";
      options.desc = "LSP references";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<M-l>R";
      action = lua "function() vim.lsp.buf.rename() end";
      options.desc = "LSP rename";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<M-l>a";
      action = lua "function() require('fzf-lua').lsp_code_actions() end";
      options.desc = "LSP code action";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<M-l>f";
      action = lua "function() require('my.editor').format() end";
      options.desc = "Format";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<M-n>";
      action = lua "function() require('my.editor').next_diagnostic() end";
      options.desc = "Next diagnostic";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<M-p>";
      action = lua "function() require('my.editor').prev_diagnostic() end";
      options.desc = "Previous diagnostic";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<M-i>";
      action = lua "function() require('my.special_edit').pick_pane() end";
      options.desc = "Special edit for WezTerm pane";
    }
  ];
}
