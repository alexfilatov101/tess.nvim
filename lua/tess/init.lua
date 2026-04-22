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
	window = {},
	keymaps = {
		open = "<leader>t",
		override = "<leader>to",
		rename = "<C-n>",
		hide = "<ESC>",
		close = "<C-q>",
		next = "<C-L>",
		prev = "<C-H>",
		normal = "jk",
	},
}

---@type tess.opts
local config

local shells = {
	bash = Shell.bash,
}

Tess = {}

local function setTessKeymaps(buf)
	vim.keymap.set("t", config.keymaps.next, function()
		Tess.swap(Tess.active_id + vim.v.count1)
	end, { desc = "Next terminal", buffer = buf })
	vim.keymap.set("t", config.keymaps.prev, function()
		Tess.swap(Tess.active_id - vim.v.count1)
	end, { desc = "Next terminal", buffer = buf })
end

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
	local b = sessions[c]:init_buffer(sop)
	setTessKeymaps(b)
	sessions[c]:open_window(sop.window)
	Tess.active_id = c
end

function Tess.sessions()
	return sessions
end

function Tess.open()
	local c = vim.v.count1
	if not sessions[c] or not sessions[c].bufnr then
		local sop = getSessionOpts(c)
		sessions[c] = Session:new(shells[config.shell.app], c)
		local b = sessions[c]:init_buffer(sop)
		setTessKeymaps(b)
	end
	Tess.active_id = c
	sessions[c]:open_window(config.window)
end

function Tess.swap(id)
	if id < 1 then
		return
	end
	local active_win = sessions[Tess.active_id].window
	sessions[Tess.active_id].window = nil
	if not sessions[id] or not sessions[id].bufnr then
		local sop = getSessionOpts(id)
		sessions[id] = Session:new(shells[config.shell.app], id)
		local b = sessions[id]:init_buffer(sop)
		setTessKeymaps(b)
	end
	if sessions[id].window then
		return
	end
	sessions[id]:swap_window(active_win)
	Tess.active_id = id
end

---@param opts tess.opts
function Tess.setup(opts)
	config = vim.tbl_deep_extend("keep", opts or {}, defaults)
	if config.shell.history.enabled then
		local wd = vim.fn.getcwd()
		local root = git.root(wd)
		local metaPath = wd .. "/.nvim"
		meta.new(metaPath, { "tess/history", "tess/source" })
		if root then
			git.exclude(root, ".nvim")
		end
	end
	vim.keymap.set("n", config.keymaps.open, function()
		Tess.open()
	end, { desc = "Open terminal" })
	vim.keymap.set("n", config.keymaps.override, function()
		Tess.override()
	end, { desc = "Override terminal" })
end

return Tess
