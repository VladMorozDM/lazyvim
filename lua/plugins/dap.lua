return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")
      local host = "127.0.0.1"
      local port = 4040
      dap.adapters.go_external = function(callback, config)
        -- 1. Choose a random available port for Delve to listen on

        -- 2. Define your external terminal execution command
        -- Example uses Alacritty. Replace with your terminal (e.g., 'kitty', 'gnome-terminal --', 'iTerm2')
        local term_cmd = "ghostty"
        local term_args = {
          "-e",
          "sh",
          "-c",
          string.format('dlv dap --listen=%s:%d || (echo "Delve failed. Press Enter..."; read)', host, port),
        }

        -- 3. Spawn the external terminal window
        vim.fn.jobstart(vim.list_extend({ term_cmd }, term_args), {
          detach = true,
          on_stderr = function(_, data)
            if data and #data > 1 then
              print("OS Error: " .. table.concat(data, "\n"))
            end
          end,
        })
        -- 4. Give the external terminal a moment to spin up the Delve server
        vim.defer_fn(function()
          callback({
            type = "server",
            host = host,
            port = port,
          })
        end, 500) -- 500ms delay to prevent connection race conditions
      end
      dap.adapters.go = function(callback, config)
        if config.mode == "remote" and config.request == "attach" then
          callback({
            type = "server",
            host = config.host or host,
            port = config.port or port,
          })
        end
      end

      -- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
      dap.configurations.go = {
        {
          type = "go_external",
          name = "Open terminal and Start Delve Debug",
          request = "launch",
          program = "${fileDirname}",
        },
        {
          type = "go",
          name = "Attach to existing server",
          request = "attach",
          mode = "remote",
        },
      }
    end,
  },
}
