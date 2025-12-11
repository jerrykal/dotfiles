return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts_extend = { "ensure_installed" },
    opts = {
      -- PATH = "append",
      ensure_installed = {},
    },
    config = function(_, opts)
      require("mason").setup(opts)

      local mr = require("mason-registry")
      mr.refresh(function()
        for _, pkg_name in ipairs(opts.ensure_installed) do
          local p = mr.get_package(pkg_name)
          if not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },
}
