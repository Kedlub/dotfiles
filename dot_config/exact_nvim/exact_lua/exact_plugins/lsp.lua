return {
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.go = {}
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          before_init = function(_, config)
            local util = require("lspconfig.util")

            local function find_python(startpath)
              return util.search_ancestors(startpath, function(path)
                local python = util.path.join(path, ".venv", "bin", "python")
                if util.path.exists(python) then
                  return python
                end
              end)
            end

            local python = find_python(vim.fn.getcwd())

            if python then
              config.settings = config.settings or {}
              config.settings.python = config.settings.python or {}

              config.settings.python.pythonPath = python
            end
          end,
        },
      },
    },
  },
}
