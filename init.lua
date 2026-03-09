vim.o.number = true
vim.o.relativenumber = true
vim.o.autoindent = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.smarttab = true
vim.o.softtabstop = 4
vim.o.mouse = a
vim.o.cursorline = true
vim.o.scrolloff = 7
vim.o.encoding = utf8
vim.o.guifont = "DroidSansMono Nerd Font:h11"
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.o.termguicolors = true
vim.o.signcolumn = "yes"
vim.o.winborder = "rounded"
vim.o.autoread = true
vim.o.wrap = false
vim.o.undofile = true
vim.o.undodir = vim.fn.expand("~/.config/nvim/undo")
vim.opt.undolevels = 200 -- максимальное количество undo шагов

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.undotree_WindowLayout = 2

require("config.lazy")

require("nvim-surround").setup()

require("mason").setup()

require("mason-lspconfig").setup({
	auto_enable = true,
})

require("render-markdown").setup({
	completions = { lsp = { enabled = true } },
})

vim.lsp.config["jinja_lsp"] = {
	filetypes = { "htmldjango", "html" },
}

local dap = require("dap")
dap.defaults.fallback.force_external_terminal = true
dap.defaults.fallback.external_terminal = {
	command = 'tmux',
	args = { 'split-window', '-v' },
}
dap.adapters.cppdbg = {
	id = "cppdbg",
	type = "executable",
	command = vim.fn.stdpath("data") .. "/mason/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7",
}
dap.configurations.cpp = {
	{
		type = "cppdbg",
		request = "launch",
		name = "Launch gdb debugger",
		program = function()
			return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
		end,
		cwd = "${workspaceFolder}",
		stopAtEntry = true,
		console = "externalTerminal",
		setupCommands = {
			{
				text = "-enable-pretty-printing",
				description = "enable pretty printing",
				ignoreFailures = false,
			},
		},
	},
}

vim.keymap.set('n', '<leader>dbc', dap.continue)
vim.keymap.set('n', '<leader>dbt', dap.terminate)
vim.keymap.set('n', '<leader>dbl', dap.list_breakpoints)
vim.keymap.set('n', '<leader>dbr', dap.clear_breakpoints)
vim.keymap.set('n', '<leader>dbb', dap.toggle_breakpoint)
vim.keymap.set('n', '<leader>dbsi', function()
	dap.step_into({ askForTargets = true })
end)
vim.keymap.set('n', '<leader>dbso', dap.step_out)
vim.keymap.set('n', '<leader>dbn', dap.step_over)
vim.keymap.set('n', '<leader>dbp', dap.repl.toggle)
vim.keymap.set('n', '<leader>dbv', function()
	require("dap.repl").execute(".scopes")
end)

vim.api.nvim_create_user_command("Format", function()
	require("conform").format()
end, {})

require("nvim-web-devicons").setup({
	-- Установить по умолчанию
	default = true,
})

local function my_on_attach(bufnr)
	local api = require("nvim-tree.api")

	local function opts(desc)
		return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end

	local function open_file()
		local node = api.tree.get_node_under_cursor()
		if node.type == "directory" then
			-- Если папка - сделать корневой
			api.tree.change_root_to_node()
		else
			-- Если файл - открыть
			api.node.open.edit()
		end
	end

	-- default mappings
	api.config.mappings.default_on_attach(bufnr)

	-- custom mappings
	vim.keymap.set("n", "<C-t>", api.tree.change_root_to_parent, opts("Up"))
	vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
	vim.keymap.set("n", "<leader>h", api.node.open.horizontal, opts("Horizontal open"))
	vim.keymap.set("n", "<leader>v", api.node.open.vertical, opts("Vertical open"))
	vim.keymap.set("n", "<S-Tab>", open_file, opts("Open"))
end

require("nvim-tree").setup({
	on_attach = my_on_attach,
	diagnostics = {
		enable = true,
		show_on_dirs = true,
	},
})

require("lualine").setup({
	options = {
		globalstatus = true,
	},
	sections = {
		lualine_a = { {
			"filename",
			path = 1,
		} },
	},
})

vim.keymap.set("n", "<M-j>", ":cnext<CR>")
vim.keymap.set("n", "<M-k>", ":cprev<CR>")

-- vim keymap
vim.keymap.set("n", "<leader>q", ":q<CR>")
vim.keymap.set("n", "<leader>w", ":wa<CR>")
vim.keymap.set("n", "<leader>o", ":update<CR> :source<CR>")
vim.keymap.set("n", "<leader>nh", ":nohl<CR>")

-- git setup
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

-- nvim-tree keymap
local opts = { noremap = true }
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", opts)
vim.keymap.set("n", "<C-c>", ":NvimTreeClose<CR>", opts)

-- render-markdown
local markdown = require("render-markdown")
vim.keymap.set("n", "<leader>mde", markdown.enable, { noremap = true })
vim.keymap.set("n", "<leader>mdd", markdown.disable, { noremap = true })

-- undotree keymap
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

-- lsp keymap
vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format)
vim.keymap.set("n", "<leader>le", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>lrf", vim.lsp.buf.references)
vim.keymap.set("n", "<leader>lD", vim.lsp.buf.type_definition)
vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition)
vim.keymap.set("n", "<leader>lvd", ":vsplit <CR> :lua vim.lsp.buf.definition({silent = false})<CR>")
vim.keymap.set("n", "<leader>lhd", ":split <CR> :lua vim.lsp.buf.definition({silent = false})<CR>")
vim.keymap.set("n", "<leader>lvD", ":vsplit <CR> :lua vim.lsp.buf.type_definition({silent = false})<CR>")
vim.keymap.set("n", "<leader>lhD", ":split <CR> :lua vim.lsp.buf.type_definition({silent = false})<CR>")
vim.keymap.set("n", "<leader>li", vim.lsp.buf.implementation)
vim.keymap.set("n", "<leader>lrn", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>lca", vim.lsp.buf.code_action)
vim.keymap.set("n", "]e", function()
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end)
vim.keymap.set("n", "[e", function()
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end)

-- yank and paste keymap
for i = string.byte("a"), string.byte("z") do
	local char = string.char(i)
	vim.keymap.set({ "n", "v" }, "<leader>y" .. char, '"' .. char .. "y", { noremap = true })
	vim.keymap.set({ "n", "v" }, "<leader>p" .. char, '"' .. char .. "p", { noremap = true })
end
for i = 0, 9 do
	vim.keymap.set({ "n", "v" }, "<leader>y" .. i, '"' .. i .. "y", { noremap = true })
	vim.keymap.set({ "n", "v" }, "<leader>p" .. i, '"' .. i .. "p", { noremap = true })
end

-- telescope keymap
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Telescope view git_commits" })
vim.keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "Telescope view git_branches" })

-- harpoon keymap
local harpoon = require("harpoon")
vim.keymap.set("n", "<leader>a", function()
	harpoon:list():add()
end)
vim.keymap.set("n", "<M-e>", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end)

vim.keymap.set("n", "<leader>1", function()
	harpoon:list():select(1)
end)
vim.keymap.set("n", "<leader>2", function()
	harpoon:list():select(2)
end)
vim.keymap.set("n", "<leader>3", function()
	harpoon:list():select(3)
end)
vim.keymap.set("n", "<leader>4", function()
	harpoon:list():select(4)
end)
vim.keymap.set("n", "<leader>5", function()
	harpoon:list():select(5)
end)
vim.keymap.set("n", "<leader>6", function()
	harpoon:list():select(6)
end)
vim.keymap.set("n", "<leader>7", function()
	harpoon:list():select(7)
end)
vim.keymap.set("n", "<leader>8", function()
	harpoon:list():select(8)
end)
