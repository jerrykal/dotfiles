return {
  -- OpenCode integration for Neovim
  {
    "NickvanDyke/opencode.nvim",
    config = function()
      vim.g.opencode_opts = {
        events = {
          enabled = false,
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
