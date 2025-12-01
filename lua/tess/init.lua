require("tess.buffer")

local buffers = {}

local defaults = {
	win = {
		relative = "editor",
		anchor = "NW",
		row = 3,
		col = 20,
		width = vim.o.columns - 40,
		height = vim.o.lines - 8,
		border = "single",
		title_pos = "center",
	},
	binds = {
		open = "<leader>t",
		override = "<leader>to",
		rename = "<C-n>",
		hide = "<ESC>",
		close = "<C-q>",
		normal = "jk",
	},
}

local o = {}

Tess = {}

local M = {}

function Tess.override()
	local c = vim.v.count1
	if buffers[c] then
		buffers[c]:kill()
	end
	buffers[c] = Buffer:new()
	buffers[c]:open(o)
end

function Tess.open()
	local c = vim.v.count1
	if buffers[c] then
		buffers[c]:open(o)
	else
		buffers[c] = Buffer:new()
		buffers[c]:open(o)
	end
end

function M.setup(opts)
	o = vim.tbl_deep_extend("keep", opts or {}, defaults)
	print(o.binds.rename)
	vim.keymap.set("n", o.binds.open, function()
		Tess.open()
	end, { desc = "Open terminal" })
	vim.keymap.set("n", o.binds.override, function()
		Tess.override()
	end, { desc = "Override terminal" })
end

return M
