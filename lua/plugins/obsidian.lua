return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- use latest release, remove to use latest commit
  lazy = false, -- keep loading eagerly so vault files are detected without pressing a key first
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    legacy_commands = false, -- this will be removed in 4.0.0
    workspaces = {
      {
        name = "dream",
        path = "~/vaults/роман",
      },
    },
  },
  -- <leader>o + first letter of the command.
  -- Uppercase / mnemonic letters are used where several commands share a first letter.
  keys = {
    -- top level
    { "<leader>oc", "<cmd>Obsidian check<cr>", desc = "Obsidian: check vault & setup" },
    { "<leader>od", "<cmd>Obsidian dailies<cr>", desc = "Obsidian: dailies picker" },
    { "<leader>oh", "<cmd>Obsidian help<cr>", desc = "Obsidian: help wiki files" },
    { "<leader>oH", "<cmd>Obsidian helpgrep<cr>", desc = "Obsidian: grep help wiki" },
    { "<leader>on", "<cmd>Obsidian new<cr>", desc = "Obsidian: new note" },
    { "<leader>oN", "<cmd>Obsidian new_from_template<cr>", desc = "Obsidian: new note from template" },
    { "<leader>oo", "<cmd>Obsidian open<cr>", desc = "Obsidian: open in Obsidian app" },
    { "<leader>ot", "<cmd>Obsidian today<cr>", desc = "Obsidian: today's daily note" },
    { "<leader>oT", "<cmd>Obsidian tomorrow<cr>", desc = "Obsidian: tomorrow's daily note" },
    { "<leader>oy", "<cmd>Obsidian yesterday<cr>", desc = "Obsidian: yesterday's daily note" },
    { "<leader>oq", "<cmd>Obsidian quick_switch<cr>", desc = "Obsidian: quick switch note" },
    { "<leader>os", "<cmd>Obsidian search<cr>", desc = "Obsidian: search notes (ripgrep)" },
    { "<leader>oS", "<cmd>Obsidian sync<cr>", desc = "Obsidian: sync service" },
    { "<leader>o#", "<cmd>Obsidian tags<cr>", desc = "Obsidian: tags picker" },
    { "<leader>ou", "<cmd>Obsidian unique_note<cr>", desc = "Obsidian: new unique (zettel) note" },
    { "<leader>ow", "<cmd>Obsidian workspace<cr>", desc = "Obsidian: switch workspace" },

    -- current note
    { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Obsidian: backlinks" },
    { "<leader>of", "<cmd>Obsidian follow_link<cr>", desc = "Obsidian: follow link under cursor" },
    { "<leader>oF", "<cmd>Obsidian footnotes<cr>", desc = "Obsidian: footnotes" },
    { "<leader>ol", "<cmd>Obsidian links<cr>", desc = "Obsidian: links in note" },
    { "<leader>oC", "<cmd>Obsidian toc<cr>", desc = "Obsidian: table of contents" },
    { "<leader>om", "<cmd>Obsidian template<cr>", desc = "Obsidian: insert template" },
    { "<leader>op", "<cmd>Obsidian paste_img<cr>", desc = "Obsidian: paste image" },
    { "<leader>or", "<cmd>Obsidian rename<cr>", desc = "Obsidian: rename note" },
    { "<leader>ox", "<cmd>Obsidian toggle_checkbox<cr>", desc = "Obsidian: toggle checkbox" },

    -- visual selection
    { "<leader>oe", "<cmd>Obsidian extract_note<cr>", mode = "v", desc = "Obsidian: extract selection to note" },
    { "<leader>ol", "<cmd>Obsidian link<cr>", mode = "v", desc = "Obsidian: link selection to note" },
    { "<leader>oL", "<cmd>Obsidian link_new<cr>", mode = "v", desc = "Obsidian: link selection to new note" },
  },
}
