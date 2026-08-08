return {
  "neovim/nvim-lspconfig",
  opts = {
    -- options for vim.diagnostic.config()
    diagnostics = {
      -- disable inline virtual text (still shown via signs/underline and hover)
      virtual_text = false,
    },
  },
}
