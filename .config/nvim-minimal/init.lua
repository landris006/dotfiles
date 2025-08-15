vim.pack.add({
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/nvim-lua/plenary.nvim",

  "https://github.com/folke/tokyonight.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",

  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",

  "https://github.com/hoob3rt/lualine.nvim",
})

require('options')
require('colors')


vim.keymap.set('n', '<leader>R', ':restart<CR>')
vim.keymap.set('n', '<leader>O', ':update<CR> :source<CR>')
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':quit<CR>')
vim.keymap.set('n', '<leader>e', ':Explore<CR>')

vim.keymap.set('n', '<leader>sH', ':Telescope help_tags<CR>')
vim.keymap.set('n', '<leader>sf', ':Telescope find_files<CR>')
vim.keymap.set('n', '<leader>st', ':Telescope live_grep<CR>')
vim.keymap.set('n', '<leader>,', ':Telescope buffers sort_mru=true sort_lastused=true<CR>')
vim.keymap.set('n', '<leader>fr', ':Telescope oldfiles<CR>')

vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)

require("mason").setup()
require("mason-lspconfig").setup()

require("nvim-treesitter.configs").setup({
  highlight = {
    enable = true,
    -- disable = { "csv" },
  },
  indent = { enable = true },
  auto_install = true,
})

local function augroup(name)
  return vim.api.nvim_create_augroup("custom" .. name, { clear = true })
end

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = augroup("lsp"),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client:supports_method('textDocument/implementation') then
      -- Create a keymap for vim.lsp.buf.implementation ...
    end

    -- Enable auto-completion. Note: Use CTRL-Y to select an item. |complete_CTRL-Y|
    if client:supports_method('textDocument/completion') then
      -- Optional: trigger autocompletion on EVERY keypress. May be slow!
      local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
      client.server_capabilities.completionProvider.triggerCharacters = chars

      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end

    -- Auto-format ("lint") on save.
    -- Usually not needed if server supports "textDocument/willSaveWaitUntil".
    if not client:supports_method('textDocument/willSaveWaitUntil')
        and client:supports_method('textDocument/formatting') then
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = vim.api.nvim_create_augroup('my.lsp', { clear = false }),
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
        end,
      })
    end
  end,
})




vim.keymap.set('i', '<c-space>', function()
  vim.lsp.completion.get()
end)


local function attached_clients()
  local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
  if #buf_clients == 0 then
    return "LSP Inactive"
  end

  local buf_ft = vim.bo.filetype
  local buf_client_names = {}
  local copilot_active = false

  for _, client in pairs(buf_clients) do
    if client.name ~= "GitHub Copilot" and client.name ~= "null-ls" then
      table.insert(buf_client_names, client.name)
    end

    if client.name == "GitHub Copilot" then
      copilot_active = true
    end
  end

  local conform = pcall(require, "conform")
  if conform then
    local attached_formatters = require("conform").list_formatters_for_buffer(0)
    vim.list_extend(buf_client_names, attached_formatters)
  end

  local lint_s, lint = pcall(require, "lint")
  if lint_s then
    for ft_k, ft_v in pairs(lint.linters_by_ft) do
      if type(ft_v) == "table" then
        for _, linter in ipairs(ft_v) do
          if buf_ft == ft_k then
            table.insert(buf_client_names, linter)
          end
        end
      elseif type(ft_v) == "string" then
        if buf_ft == ft_k then
          table.insert(buf_client_names, ft_v)
        end
      end
    end
  end

  local unique_client_names = table.concat(buf_client_names, ", ")
  local language_servers = string.format("[%s]", unique_client_names)

  if copilot_active then
    language_servers = language_servers
        .. "%#SLCopilot#"
        .. " "
        .. require("config.utils").icons.git.Octoface
        .. "%*"
  end

  return language_servers
end


-- vim.lsp.enable({ "lua_ls", "rust_analyzer" })

require('lualine').setup({
  sections = {
    lualine_x = {
      {
        attached_clients,
        -- color = { gui = "bold" },
      },
      'encoding', 'fileformat', 'filetype'
    },
  },
})
