return {
  {
    "catppuccin/nvim",
    opts = {
      flavour = "macchiato",
      auto_integrations = true,
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
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
