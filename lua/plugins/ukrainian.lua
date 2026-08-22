-- 'langmap' alone only fixes built-in commands: Neovim matches mappings against
-- the raw typed keys, so <leader>щ or пв (gd) never reach their mapping.
-- langmapper registers a Cyrillic twin for every mapping to close that gap.
local uk = require("config.ukrainian")

return {
  "Wansmer/langmapper.nvim",
  lazy = false,
  priority = 1000, -- has to wrap vim.keymap.set before other plugins define keys
  init = function()
    -- langmapper only handles mappings; commands still need 'langmap'
    vim.o.langmap = uk.langmap()
  end,
  config = function()
    local langmapper = require("langmapper")

    langmapper.setup({
      hack_keymap = true, -- wrap vim.keymap.set, incl. lazy-loaded plugins
      disable_hack_modes = { "i" }, -- insert mode stays latin (use <leader>uu there)
      automapping_modes = { "n", "v", "x", "s" },
      use_layouts = { "uk" }, -- no need to detect the current OS layout
      default_layout = uk.default_layout,
      layouts = {
        uk = {
          id = "uk",
          layout = uk.langmapper_layout(),
        },
      },
    })

    -- mappings that already existed before langmapper loaded: LazyVim's own, and
    -- the stubs lazy.nvim creates for `keys = {...}` specs
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        langmapper.automapping({ global = true, buffer = true })
      end,
    })

    -- buffer-local mappings arrive later (LazyVim's gd/gr/K come from LspAttach)
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function()
        langmapper.automapping({ global = false, buffer = true })
      end,
    })

    -- textobject ids are read with getcharstr(), which langmap cannot reach
    if LazyVim and LazyVim.on_load then
      LazyVim.on_load("mini.ai", uk.setup_mini_ai)
    end
  end,
}
