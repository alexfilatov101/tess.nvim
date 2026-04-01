local git = require("tess.util.git")
local meta = require("tess.util.metadata")
local Session = require("tess.session")
local Shell = require("tess.shell.shell")

---@type tess.session[]
local sessions = {}

---@class tess.opts.shell
---@field app string? Shell type to use
---@field history tess.shell.opts.history? Shell history options
---@field source string|nil? Source file path
---@field relative string? Working directory lookup. 'win' - use window directory, 'root' - use project root directory

---@class tess.opts
---@field window vim.api.keyset.win_config? Window config
---@field keymaps any? Keymap config
---@field shell tess.opts.shell? Shell config

---@type tess.opts
local defaults = {
	shell = {
		app = "bash",
		history = {
			enabled = true,
			size = 10000,
			filesize = 20000,
		},
		source = nil,
		relative = "win",
	},
	window = {
		relative = "editor",
		anchor = "NW",
		row = 3,
		col = 20,
		width = vim.o.columns - 40,
		height = vim.o.lines - 8,
		border = "single",
		title_pos = "center",
	},
	keymaps = {
		open = "<leader>t",
		override = "<leader>to",
		rename = "<C-n>",
		hide = "<ESC>",
		close = "<C-q>",
		normal = "jk",
	},
}

---@type tess.opts
local config

local M = {}

local shells = {
	bash = Shell.bash,
}

Tess = {}

local function getSessionOpts(id)
	local sop = {
		window = config.window,
		keymaps = config.keymaps,
		shell = {
			id = id,
			cwd = vim.fn.getcwd(),
			root = vim.fn.getcwd(),
			source = config.shell.source,
			history = config.shell.history,
		},
	}
	if config.shell.relative == "win" then
		sop.cwd = vim.fn.getcwd(vim.api.nvim_get_current_win())
	end
	return sop
end

function Tess.override()
	local c = vim.v.count1
	if sessions[c] then
		sessions[c]:kill()
	end
	local sop = getSessionOpts(c)
	sessions[c] = Session:new(shells[config.shell.app], c)
	sessions[c]:init_buffer(sop)
	sessions[c]:open_window(sop.window)
end

function Tess.open()
	local c = vim.v.count1
	if not sessions[c] or not sessions[c].bufnr then
		local sop = getSessionOpts(c)
		sessions[c] = Session:new(shells[config.shell.app], c)
		sessions[c]:init_buffer(sop)
	end
	sessions[c]:open_window(config.window)
end

---@param opts tess.opts
function M.setup(opts)
	config = vim.tbl_deep_extend("keep", opts or {}, defaults)
	if config.shell.history.enabled then
		local wd = vim.fn.getcwd()
		local root = git.root(wd)
		local metaPath = wd .. "/.nvim"
		meta.new(metaPath, { "tess" })
		if root then
			git.exclude(root, metaPath)
		end
	end
	vim.keymap.set("n", config.keymaps.open, function()
		Tess.open()
	end, { desc = "Open terminal" })
	vim.keymap.set("n", config.keymaps.override, function()
		Tess.override()
	end, { desc = "Override terminal" })
end

return M
