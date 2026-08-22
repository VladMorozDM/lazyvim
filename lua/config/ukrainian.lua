-- Ukrainian ЙЦУКЕН layout, in Lua (replacement for a keymap/*.vim file).
--
-- Two independent pieces built from the same table:
--   * 'langmap' — always on. Normal/visual-mode commands keep working while the
--     OS keyboard is switched to Ukrainian (the key that types "д" still means "l").
--   * a buffer-local insert-mode layer — type Ukrainian with the OS keyboard on
--     US, like the built-in 'keymap' option. Toggle with <leader>uu or
--     :UkrainianToggle.

local M = {}

-- key on a US keyboard -> character it produces on the Ukrainian layout.
-- Taken from xkb ua(winkeys) + ua(legacy), which is what `setxkbmap -query`
-- reports here. Note this differs from the macOS variant: winkeys puts і on `s`
-- and и on `b`, macOS has those two swapped.
-- stylua: ignore
M.layout = {
  { "`", "'" }, { "@", '"' }, { "#", "№" }, { "$", ";" }, { "^", ":" }, { "&", "?" },
  { "/", "." }, { "?", "," },

  { "F", "А" }, { "<", "Б" }, { "D", "В" }, { "U", "Г" }, { "|", "Ґ" }, { "L", "Д" }, { "T", "Е" },
  { '"', "Є" }, { ":", "Ж" }, { "P", "З" }, { "B", "И" }, { "S", "І" }, { "}", "Ї" }, { "Q", "Й" },
  { "R", "К" }, { "K", "Л" }, { "V", "М" }, { "Y", "Н" }, { "J", "О" }, { "G", "П" }, { "H", "Р" },
  { "C", "С" }, { "N", "Т" }, { "E", "У" }, { "A", "Ф" }, { "{", "Х" }, { "W", "Ц" }, { "X", "Ч" },
  { "I", "Ш" }, { "O", "Щ" }, { "M", "Ь" }, { ">", "Ю" }, { "Z", "Я" },

  { "f", "а" }, { ",", "б" }, { "d", "в" }, { "u", "г" }, { "\\", "ґ" }, { "l", "д" }, { "t", "е" },
  { "'", "є" }, { ";", "ж" }, { "p", "з" }, { "b", "и" }, { "s", "і" }, { "]", "ї" }, { "q", "й" },
  { "r", "к" }, { "k", "л" }, { "v", "м" }, { "y", "н" }, { "j", "о" }, { "g", "п" }, { "h", "р" },
  { "c", "с" }, { "n", "т" }, { "e", "у" }, { "a", "ф" }, { "[", "х" }, { "w", "ц" }, { "x", "ч" },
  { "i", "ш" }, { "o", "щ" }, { "m", "ь" }, { ".", "ю" }, { "z", "я" },
}

-- ; , " | and \ are structural in 'langmap' and have to be escaped (:h 'langmap')
local function escape(char)
  return (char:gsub('([\\,;"|])', "\\%1"))
end

--- Ukrainian character -> the US key in the same position (`ц` -> `w`).
function M.to_key()
  local map = {}
  for _, pair in ipairs(M.layout) do
    map[pair[2]] = pair[1]
  end
  return map
end

--- US key -> the Ukrainian character in the same position (`w` -> `ц`).
function M.to_char()
  local map = {}
  for _, pair in ipairs(M.layout) do
    map[pair[1]] = pair[2]
  end
  return map
end

-- "<" would be read as the start of a key notation such as <Esc>
local function lhs(key)
  return key == "<" and "<lt>" or key
end

--- The 'langmap' value: Cyrillic character -> the US key that means the same
--- command. Pairs that produce plain ASCII (`'`, `"`, `.`, ...) are skipped, so
--- real Vim commands on those keys are left alone.
function M.langmap()
  local parts = {}
  for _, pair in ipairs(M.layout) do
    local key, char = pair[1], pair[2]
    if char:byte() > 127 then
      table.insert(parts, escape(char) .. escape(key))
    end
  end
  return table.concat(parts, ",")
end

-- langmapper zips this string with the layout string position by position. It is
-- langmapper's own default plus "\" on the end, so that <localleader> is covered
-- too; both sides are passed to setup() explicitly, so they cannot drift apart.
M.default_layout = [[~QWERTYUIOP{}|ASDFGHJKL:"ZXCVBNM<>?`qwertyuiop[]asdfghjkl;'zxcvbnm,./\]]

-- This layout puts "." and "," on the / and ? keys, but a twin of any mapping on
-- "/" would then land on "." and swallow dot-repeat (and <leader>/ would shadow
-- LazyVim's <leader>.), so those two keys get no twin. "/" itself is still
-- reachable on this layout: it sits on the extra 105-key key next to left shift.
local no_twin = { ["/"] = true, ["?"] = true }

--- The `layout` string for langmapper.nvim: M.default_layout with every key
--- replaced by the character the Ukrainian layout puts there. Keys left as
--- themselves (`~`, `/`, `?`) simply become a no-op twin.
function M.langmapper_layout()
  local by_key = M.to_char()
  local out = {}
  for key in M.default_layout:gmatch(".") do
    table.insert(out, not no_twin[key] and by_key[key] or key)
  end
  return table.concat(out)
end

--- mini.ai reads the textobject id with getcharstr(), and 'langmap' never sees
--- input read that way: `ciw` typed as `сшц` reaches mini.ai as the id "ц".
--- Instead of patching mini.ai, re-enter it through its own latin mapping with
--- the id already translated, so every textobject (its builtins, LazyVim's extra
--- ones, treesitter) keeps working unchanged.
function M.setup_mini_ai()
  local ok, mini_ai = pcall(require, "mini.ai")
  if not ok then
    return
  end

  local to_key, to_char = M.to_key(), M.to_char()

  for name, latin in pairs(mini_ai.config.mappings or {}) do
    -- around/inside/around_next/inside_last/...; not the goto_* motions
    if name:find("around") or name:find("inside") then
      local cyrillic = latin:gsub(".", to_char)
      if cyrillic ~= latin then
        vim.keymap.set({ "x", "o" }, cyrillic, function()
          local got, char = pcall(vim.fn.getcharstr)
          if not got or char == "" then
            return ""
          end
          -- only Cyrillic needs translating: an id typed as ASCII is already the
          -- id meant (`"` is Shift+2 on this layout, so ci" must stay ci")
          local id = char:byte() > 127 and (to_key[char] or char) or char
          -- remapped, so this runs mini.ai's own `latin` mapping; 'langremap' is
          -- off by default, so these keys are not sent through langmap again
          return latin .. id
        end, { expr = true, remap = true, desc = "mini.ai " .. name .. " (uk)" })
      end
    end
  end
end

return M
