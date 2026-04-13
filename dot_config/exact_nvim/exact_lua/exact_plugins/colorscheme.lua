return {
  {
    "catppuccin/nvim",
    opts = {
      flavour = "macchiato",
      auto_integrations = true,
    },
    enabled = false,
  },

  {
    "eldritch-theme/eldritch.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "eldritch",
    },
  },

  {
    "folke/snacks.nvim",
    opts = {
      lazygit = {
        configure = false,
      },
    },
  },
}
