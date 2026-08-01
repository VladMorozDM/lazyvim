return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")

      -- Перевизначаємо або додаємо конфігурацію для Go
      dap.configurations.go = {
        {
          type = "go",
          name = "Debug (Delve з підтримкою TTY)",
          request = "launch",
          program = "${file}",
          -- Цей рядок є ключовим! Він змушує nvim-dap відкрити справжній термінал
          console = "integratedTerminal",
        },
        {
          type = "go",
          name = "Debug test",
          request = "launch",
          mode = "test",
          program = "${file}",
          console = "integratedTerminal",
        },
      }
    end,
  },
}
