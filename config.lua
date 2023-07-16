lvim.plugins = {
	{ "github/copilot.vim" },
	{ "ellisonleao/gruvbox.nvim" },
	{ "petertriho/nvim-scrollbar" },
	{ "alexghergh/nvim-tmux-navigation" },
	{ "f-person/git-blame.nvim" },
	{ "kevinhwang91/nvim-bqf" },
	{ "norcalli/nvim-colorizer.lua" },
	{ "mechatroner/rainbow_csv" },
}

vim.clipboard = "unnamedplus"

vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.relativenumber = true

vim.g.gitblame_delay = 1000

lvim.colorscheme = "tokyonight"
require("tokyonight").setup({
	style = "night",
	transparent = true, -- Enable this to disable setting the background color
	terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
	styles = {
		comments = { italic = false },
		keywords = { italic = false },
		functions = {},
		variables = {},
		-- Background styles. Can be "dark", "transparent" or "normal"
		sidebars = "transparent", -- style for sidebars, see below
		floats = "transparent", -- style for floating windows
	},
	sidebars = { "qf", "help" }, -- Set a darker background on sidebar-like windows. For example: `["qf", "vista_kind", "terminal", "packer"]`
	day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style. Number between 0 and 1, from dull to vibrant colors
	hide_inactive_statusline = false, -- Enabling this option, will hide inactive statuslines and replace them with a thin border instead. Should work with the standard **StatusLine** and **LuaLine**.
	dim_inactive = false, -- dims inactive windows
	lualine_bold = false, -- When `true`, section headers in the lualine theme will be bold
	on_highlights = function(highlights, colors)
		highlights.Function = { fg = colors.yellow }
		highlights.CmpItemKindFunction = { fg = colors.yellow }
		highlights.NoiceCompletionItemKindFunction = { fg = colors.yellow }
		highlights.typescriptFunctionMethod = { fg = colors.yellow }
		highlights.NavicIconsFunction = { fg = colors.yellow }
		highlights["@parameter"] = { fg = colors.blue }
		highlights["@variable"] = { fg = colors.blue }
		highlights.Type = { fg = colors.teal }
	end,
})

-- general
lvim.log.level = "info"
lvim.format_on_save = {
	enabled = true,
	timeout = 1000,
}
lvim.leader = "space"
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
lvim.keys.normal_mode["<S-l>"] = ":BufferLineCycleNext<CR>"
lvim.keys.normal_mode["<S-h>"] = ":BufferLineCyclePrev<CR>"
lvim.keys.normal_mode["<leader>t"] = ":ToggleTerm<CR>"
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"

require("nvim-tmux-navigation").setup({
	disable_when_zoomed = true, -- defaults to false
	keybindings = {
		left = "<C-h>",
		down = "<C-j>",
		up = "<C-k>",
		right = "<C-l>",
		-- last_active = "<C-\\>",
		-- next = "<C-Space>",
	},
})

lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = true
lvim.builtin.nvimtree.setup.sync_root_with_cwd = false
lvim.builtin.nvimtree.setup.update_focused_file.update_root = false

vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true
vim.g.copilot_tab_fallback = "<S-Tab>"

local _, actions = pcall(require, "telescope.actions")
lvim.builtin.telescope.defaults.mappings = {
	-- for input mode
	i = {
		["<C-j>"] = actions.move_selection_next,
		["<C-k>"] = actions.move_selection_previous,
		["<C-n>"] = actions.cycle_history_next,
		["<C-p>"] = actions.cycle_history_prev,
	},
	-- for normal mode
	n = {
		["<C-j>"] = actions.move_selection_next,
		["<C-k>"] = actions.move_selection_previous,
	},
}

lvim.builtin.telescope.defaults.path_display = { "full" }
-- lvim.builtin.telescope.defaults.layout_strategy = "horizontal"
-- lvim.builtin.telescope.defaults.layout_config.width = 0.8
-- lvim.builtin.telescope.defaults.layout_config.preview_cutoff = 75

-- lvim.builtin.telescope.pickers.live_grep = {
--   layout_strategy = "horizontal",
-- }
-- lvim.builtin.telescope.pickers.find_files = {
--   layout_strategy = "horizontal",
-- }
-- lvim.builtin.telescope.pickers.git_files = {
--   layout_strategy = "horizontal",
-- }
-- lvim.builtin.telescope.pickers.live_grep = {
--   layout_strategy = "horizontal",
-- }

local cmp = require("cmp")
lvim.builtin.cmp.mapping = cmp.mapping.preset.insert({
	["<C-k>"] = cmp.mapping.select_prev_item(),
	["<C-j>"] = cmp.mapping.select_next_item(),
	["<C-space>"] = cmp.mapping.complete(),
	["<C-e>"] = cmp.mapping.close(),
	["<Tab>"] = cmp.mapping.confirm({ select = true }),
	["<S-Tab>"] = cmp.mapping(function(fallback)
		cmp.mapping.abort()
		local copilot_keys = vim.fn["copilot#Accept"]()
		if copilot_keys ~= "" then
			vim.api.nvim_feedkeys(copilot_keys, "i", true)
		else
			fallback()
		end
	end),
})

local _, scrollbar = pcall(require, "scrollbar")
scrollbar.setup()

lvim.builtin.lualine.sections.lualine_a = { "mode" }

-- Automatically install missing parsers when entering buffer
lvim.builtin.treesitter.auto_install = true

-- lvim.builtin.treesitter.ignore_install = { "haskell" }

-- -- always installed on startup, useful for parsers without a strict filetype
lvim.builtin.treesitter.ensure_installed = { "comment", "markdown_inline", "regex" }

-- -- generic LSP settings <https://www.lunarvim.org/docs/languages#lsp-support>

-- --- disable automatic installation of servers
-- lvim.lsp.installer.setup.automatic_installation = false

-- ---configure a server manually. IMPORTANT: Requires `:LvimCacheReset` to take effect
-- ---see the full default list `:lua =lvim.lsp.automatic_configuration.skipped_servers`
-- vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })
-- local opts = {} -- check the lspconfig documentation for a list of all possible options
-- require("lvim.lsp.manager").setup("pyright", opts)

-- ---remove a server from the skipped list, e.g. eslint, or emmet_ls. IMPORTANT: Requires `:LvimCacheReset` to take effect
-- ---`:LvimInfo` lists which server(s) are skipped for the current filetype
-- lvim.lsp.automatic_configuration.skipped_servers = vim.tbl_filter(function(server)
--   return server ~= "emmet_ls"
-- end, lvim.lsp.automatic_configuration.skipped_servers)

-- -- you can set a custom on_attach function that will be used for all the language servers
-- -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end

local _, lsp_manager = pcall(require, "lvim.lsp.manager")
lsp_manager.setup("emmet_ls")
lsp_manager.setup("prismals")
lsp_manager.setup("taplo")
lsp_manager.setup("fortls")

-- linters, formatters and code actions <https://www.lunarvim.org/docs/languages#lintingformatting>
local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup({
	{ command = "stylua" },
	{
		command = "prettier",
		extra_args = { "--print-width", "100" },
		filetypes = { "typescript", "typescriptreact" },
	},
})
local linters = require("lvim.lsp.null-ls.linters")
linters.setup({
	{
		command = "shellcheck",
		args = { "--severity", "warning" },
	},
	-- { command = "eslint" }
})
local code_actions = require("lvim.lsp.null-ls.code_actions")
code_actions.setup({
	{
		exe = "eslint",
		filetypes = { "typescript", "typescriptreact" },
	},
})

-- -- Autocommands (`:help autocmd`) <https://neovim.io/doc/user/autocmd.html>
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "zsh",
--   callback = function()
--     -- let treesitter use bash highlight for zsh files as well
--     require("nvim-treesitter.highlight").attach(0, "bash")
--   end,
-- })

-- disable semantic highlights
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = { "tokyonight" },
	callback = function()
		for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
			vim.api.nvim_set_hl(0, group, {})
		end
	end,
})

local function open_nvim_tree(data)
	local directory = vim.fn.isdirectory(data.file) == 1

	if not directory then
		return
	end

	vim.cmd.cd(data.file)

	require("nvim-tree.api").tree.open()
end

vim.api.nvim_create_autocmd("VimEnter", {
	callback = open_nvim_tree,
})

local function join_lists(...)
	local result = {}
	for _, list in ipairs({ ... }) do
		for _, item in ipairs(list) do
			table.insert(result, item)
		end
	end
	return result
end

local null_ls = require("null-ls")
vim.api.nvim_create_user_command("Disable", function(opts)
	null_ls.disable(opts.fargs[1])
end, {
	nargs = 1,
	complete = function()
		return join_lists(vim.tbl_keys(null_ls.builtins.formatting), vim.tbl_keys(null_ls.builtins.diagnostics))
	end,
})
vim.api.nvim_create_user_command("Enable", function(opts)
	null_ls.enable(opts.fargs[1])
end, {
	nargs = 1,
	complete = function()
		return join_lists(vim.tbl_keys(null_ls.builtins.formatting), vim.tbl_keys(null_ls.builtins.diagnostics))
	end,
})
