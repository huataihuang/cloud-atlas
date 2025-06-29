require("lazy").setup({
   -- ...
   -- LSP manager
    { "mason-org/mason.nvim", opts = {} },
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = {
            "mason-org/mason.nvim",
            "neovim/nvim-lspconfig",
	    	config = function()
	    	    local lspconfig = require("lspconfig")

	    	    lspconfig.pylsp.setup({})
	        end,
        },
        opts = {
            ensure_installed = { "pylsp", "lua_ls", "bashls", "ruby_lsp" },
        },
    },
    {
      "pmizio/typescript-tools.nvim",
      dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
      opts = {},
    },
})
