return {
  {
    'mfussenegger/nvim-dap',
    keys = {
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "DAP Set Conditional Breakpoint" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "DAP Run/Continue" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "DAP Run to Cursor" },
      { "<leader>dg", function() require("dap").goto_() end,         desc = "DAP Go to Line (No Execute)" },
      { "<leader>dl", function() require("dap").run_last() end,     desc = "DAP Run Last" },
      { "<leader>dP", function() require("dap").pause() end,        desc = "DAP Pause" },
      { "<leader>dr", function() require("dap").repl.toggle() end,  desc = "Toggle REPL" },
      { "<leader>ds", function() require("dap").session() end,      desc = "DAP Session" },
      { "<leader>dt", function() require("dap").terminate() end,    desc = "DAP Terminate" },
      { "<leader>du", function() require("dap-view").toggle({}) end, desc = "DAP UI" },
      { "<leader>dj", function() require("dap").down() end, desc = "DAP Down" },
      { "<leader>dk", function() require("dap").up() end,   desc = "DAP Up" },
      { "<M-i>", function() require("dap").step_into() end, desc = "Step Into" },
      { "<M-o>", function() require("dap").step_over() end, desc = "Step Over" },
      { "<M-e>", function() require("dap").step_out() end,  desc = "Step Out" },
    },
    dependencies = {
			'igorlfs/nvim-dap-view',
			'theHamsta/nvim-dap-virtual-text'
		},
    config = function()
      local dap = require('dap')

      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
      vim.fn.sign_define("DapStopped", {text="󰁕", texthl="DiagnosticWarn", linehl="DapStoppedLine", numhl="DapStoppedLine"})
      vim.fn.sign_define("DapBreakpoint", {text="", texhl="DiagnosticInfo"})
      vim.fn.sign_define("DapBreakpointCondition", {text="", texthl="DiagnosticInfo"})
      vim.fn.sign_define("DapBreakpointRejected", {text="", texthl="DiagnosticError"})
      vim.fn.sign_define("DapLogPoint", {text="", texthl="DiagnosticInfo"})

      dap.adapters.python = function(cb, config)
        if config.request == 'attach' then
          ---@diagnostic disable-next-line: undefined-field
          local port = (config.connect or config).port
          ---@diagnostic disable-next-line: undefined-field
          local host = (config.connect or config).host or '127.0.0.1'
          cb({
            type = 'server',
            port = assert(port, '`connect.port` is required for a python `attach` configuration'),
            host = host,
            options = {
              source_filetype = 'python',
            },
          })
        else
          cb({
            type = 'executable',
            command = 'python3',
            args = { '-m', 'debugpy.adapter' },
            options = {
              source_filetype = 'python',
            },
          })
        end
      end
      dap.adapters.codelldb = {
        type = "executable",
        command = "codelldb", -- or if not in $PATH: "/absolute/path/to/codelldb"

        -- On windows you may have to uncomment this:
        -- detached = false,
      }
      dap.configurations.python = {
        {
          -- The first three options are required by nvim-dap
          type = 'python'; -- the type here established the link to the adapter definition: `dap.adapters.python`
          request = 'launch';
          name = "Launch file";

          -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

          program = "${file}"; -- This configuration will launch the current file if used.
          pythonPath = function()
            -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
            -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
            -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
            local cwd = vim.fn.getcwd()
            local venv = os.getenv('VIRTUAL_ENV') or os.getenv('CONDA_PREFIX')
            if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
              return cwd .. '/venv/bin/python'
            elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
              return cwd .. '/.venv/bin/python'
            elseif venv and vim.fn.executable(venv .. '/bin/python') == 1 then
              return venv .. '/bin/python'
            else
              return '/usr/bin/python'
            end
          end;
					justMyCode = false,
        },
      }
      dap.configurations.cpp = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
        },
      }

			dap.configurations.c = dap.configurations.cpp
			dap.configurations.rust = dap.configurations.cpp

    end
  },
}
