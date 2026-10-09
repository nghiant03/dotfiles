return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'onsails/lspkind.nvim',
      'saghen/blink.cmp',
    },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }

      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = {
              globals = {
                'vim'
              }
            }
          }
        },
      })

      vim.lsp.config("pyrefly", {
        settings = {
          python = {
            analysis = {
              diagnosticSeverityOverrides = {
                reportUnusedExpression = "none",
              }
            }
          }
        }
      })

      vim.lsp.config("rust_analyzer", {
        settings = {
          ["rust_analyzer"] = {
            check = {
              command = "clippy"
            }
          }
        }
      })

      vim.lsp.config("ltex_plus", {
			 filetypes = { 'bib', 'tex', 'latex', 'gitcommit' },
			 on_attach = function(_, _)
					 require("ltex_extra").setup{}
			 end,
        settings = {
          ltex = {
            additionalRules = {
              enabledPickyRules = true
            },
            enabled = {
              'bib',
              'tex',
              'gitcommit',
              'latex'
            }
          }
        }
      })

      local function load_buffer_lines(bufnr)
        if vim.fn.bufloaded(bufnr) == 0 then
          pcall(vim.fn.bufload, bufnr)
        end

        return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      end

      local function read_yaml_scalars(lines, keys)
        local values = {}
        for _, line in ipairs(lines) do
          local key, value = line:match("^%s*([%w_-]+):%s*([^#]+)")
          if key and keys[key] then
            values[key] = vim.trim(value):gsub("[\"']", "")
          end
        end
        return values
      end

      local schema_uri_cache = {}

      local function schema_exists(uri)
        if schema_uri_cache[uri] ~= nil then
          return schema_uri_cache[uri]
        end

        local command = { "python3", "-c", "import sys, urllib.request; r = urllib.request.urlopen(sys.argv[1], timeout=2); sys.exit(0 if r.status == 200 else 1)", uri }
        local result = vim.system(command, { text = true }):wait()
        schema_uri_cache[uri] = result.code == 0
        return schema_uri_cache[uri]
      end

      local function kubernetes_schema(values, _, _)
        if not (values.apiVersion and values.kind) then
          return nil
        end

        local schema_base = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/refs/heads/master/v1.32.1-standalone-strict/"
        local group, version = values.apiVersion:match("^(.+)/(.+)$")
        local uri
        if group then
          uri = schema_base .. string.format(
            "%s-%s-%s.json",
            values.kind:lower(),
            group:gsub("%.k8s%.io$", ""):gsub("%.x%-k8s%.io$", ""):gsub("%.", "-"):lower(),
            version:lower()
          )
        else
          uri = schema_base .. string.format("%s-%s.json", values.kind:lower(), values.apiVersion:lower())
        end

        if schema_exists(uri) then
          return uri
        end
      end

      local yaml_schema_detectors = {
        {
          keys = { apiVersion = true, kind = true },
          schema = kubernetes_schema,
        },
      }

      local function detect_yaml_schema(bufnr)
        local lines = load_buffer_lines(bufnr)
        for _, detector in ipairs(yaml_schema_detectors) do
          local values = read_yaml_scalars(lines, detector.keys)
          local schema = detector.schema(values, lines, bufnr)
          if schema then
            return schema
          end
        end
      end

      vim.lsp.handlers["custom/schema/request"] = function(_, params)
        local resource = type(params) == "table" and (params.uri or params[1]) or params
        if type(resource) ~= "string" then
          return {}
        end

        local ok, bufnr = pcall(vim.uri_to_bufnr, resource)
        if not ok or not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
          return {}
        end

        return detect_yaml_schema(bufnr) or {}
      end

      vim.lsp.config("yamlls", {
        on_init = function(client)
          client.server_capabilities.documentFormattingProvider = true
          pcall(function()
            client:notify("yaml/registerCustomSchemaRequest")
          end)
          return true
        end,
        settings = {
          yaml = {
            completion = true,
            hover = true,
            validate = true,
          },
        },
      })

      vim.lsp.enable({'lua_ls', 'pyrefly', 'ruff', 'rust_analyzer', 'ltex_plus', 'texlab', 'gopls', 'yamlls', 'ts_ls'})

      require('lspkind').init({
        -- DEPRECATED (use mode instead): enables text annotations
        --
        -- default: true
        -- with_text = true,

        -- defines how annotations are shown
        -- default: symbol
        -- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
        mode = 'symbol_text',

        -- default symbol map
        -- can be either 'default' (requires nerd-fonts font) or
        -- 'codicons' for codicon preset (requires vscode-codicons font)
        --
        -- default: 'default'
        preset = 'codicons',

        -- override preset symbols
        --
        -- default: {}
        symbol_map = {
          Text = "󰉿",
          Method = "󰆧",
          Function = "󰊕",
          Constructor = "",
          Field = "󰜢",
          Variable = "󰀫",
          Class = "󰠱",
          Interface = "",
          Module = "",
          Property = "󰜢",
          Unit = "󰑭",
          Value = "󰎠",
          Enum = "",
          Keyword = "󰌋",
          Snippet = "",
          Color = "󰏘",
          File = "󰈙",
          Reference = "󰈇",
          Folder = "󰉋",
          EnumMember = "",
          Constant = "󰏿",
          Struct = "󰙅",
          Event = "",
          Operator = "󰆕",
          TypeParameter = "",
        }
      })
  end
  },
  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false<cr>",
        desc = "LSP Definitions and References",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List",
      },
    },
  }
}
