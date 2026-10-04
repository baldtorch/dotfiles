-- Minimal Neovim with native LSP. Add language servers to home/packages.nix or devshells/.
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.clipboard = "unnamedplus" -- wl-clipboard handles Wayland clipboard access.
vim.opt.signcolumn = "yes"
vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Save" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnostic" })
vim.lsp.enable({ "gopls", "rust_analyzer", "clangd" })
local function colors()
  local state = vim.env.XDG_STATE_HOME or (vim.env.HOME .. "/.local/state")
  local file = io.open(state .. "/rice/current/palette.json", "r")
  if not file then return end
  local text = file:read("*a"); file:close()
  local ok, p = pcall(vim.json.decode, text)
  if not ok then return end
  vim.api.nvim_set_hl(0, "Normal", { fg = p.on_surface, bg = p.surface })
  vim.api.nvim_set_hl(0, "NormalFloat", { fg = p.on_surface, bg = p.surface_container })
  vim.api.nvim_set_hl(0, "StatusLine", { fg = p.on_primary, bg = p.primary })
  vim.api.nvim_set_hl(0, "Visual", { bg = p.surface_container })
  vim.api.nvim_set_hl(0, "Keyword", { fg = p.primary })
  vim.api.nvim_set_hl(0, "String", { fg = p.secondary })
  vim.api.nvim_set_hl(0, "Function", { fg = p.tertiary })
end
colors()
vim.api.nvim_create_autocmd("FocusGained", { callback = colors })
vim.api.nvim_create_user_command("RiceTheme", colors, {})
