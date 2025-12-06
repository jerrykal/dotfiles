return {
  {
    "NickvanDyke/opencode.nvim",
    event = "VeryLazy",
    config = function()
      vim.g.opencode_opts = {
        provider = {
          enabled = "tmux",
          tmux = {
            options = "-h -l 30%",
          },
        },
      }
    end,
    -- stylua: ignore
    keys = {
      { "<leader>oq", mode = { "n", "x" }, function() require("opencode").ask("@this: ", { submit = true }) end, desc = "Ask opencode", },
      { "<leader>os", mode = { "n", "x" }, function() require("opencode").select() end, desc = "Execute opencode action…", },
      { "<leader>oa", mode = { "n", "x" }, function() require("opencode").prompt("@this") end, desc = "Add to opencode", },
      { "<leader>oc", function() require("opencode").toggle() end, desc = "Toggle opencode"},
    },
  },
}
