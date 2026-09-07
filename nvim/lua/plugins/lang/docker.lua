return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "dockerfile" } },
  },

  {
    "mason.nvim",
    opts = { ensure_installed = { "hadolint" } },
  },

  {
    "nvim-lspconfig",
    init = function()
      -- nvim's runtime never assigns yaml.docker-compose, so the compose half
      -- of docker_language_server would otherwise never attach
      vim.filetype.add({
        filename = {
          ["docker-compose.yaml"] = "yaml.docker-compose",
          ["docker-compose.yml"] = "yaml.docker-compose",
          ["compose.yaml"] = "yaml.docker-compose",
          ["compose.yml"] = "yaml.docker-compose",
        },
        pattern = {
          -- variants like compose.override.yaml, docker-compose.prod.yml
          [".*/docker%-compose%..*%.ya?ml"] = "yaml.docker-compose",
          [".*/compose%..*%.ya?ml"] = "yaml.docker-compose",
        },
      })
    end,
    opts = {
      servers = {
        docker_language_server = {},
      },
    },
  },

  {
    "nvim-lint",
    opts = {
      linters_by_ft = {
        dockerfile = { "hadolint" },
      },
    },
  },
}
