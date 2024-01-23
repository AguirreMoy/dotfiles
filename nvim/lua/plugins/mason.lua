return{  -- add any tools you want to have installed below
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      table.insert(opts.ensure_installed, "black")
      table.insert(opts.ensure_installed, "isort")
      table.insert(opts.ensure_installed, "ruff")
      table.insert(opts.ensure_installed, "stylua")
      table.insert(opts.ensure_installed, "shellcheck") 
      table.insert(opts.ensure_installed, "shfmt")
      table.insert(opts.ensure_installed, "flake8") 
    end,
  },
}