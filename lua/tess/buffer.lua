local Buffer = {}

local buffer_defaults = {
	title = "Terminal",
	id = 0,
	buf = 0,
	win = nil,
}

function Buffer:new(o)
	o = o or {}
	o = vim.tbl_deep_extend("keep", o, buffer_defaults)
	o.id = vim.v.count1
	o.title = "Terminal [" .. tostring(o.id) .. "]"
	setmetatable(o, self)
	self.__index = self
	return o
end

function Buffer:rename(title)
	self.title = title
	if self.win then
		vim.api.nvim_win_set_config(self.win, { title = "󰆍 " .. title })
	end
end

function Buffer:rename_prompt()
	vim.ui.input({ prompt = "Enter new terminal name: " }, function(input)
		vim.cmd("startinsert")
		if not input then
			return
		end
		if self.win then
			if self.win == vim.api.nvim_get_current_win() then
				vim.cmd("startinsert")
			end
			self:rename(input)
		end
	end)
end

local function set_keymaps(buf, opts)
	local bo = { buffer = true, silent = true }
	vim.keymap.set("t", opts.hide, function()
		buf:close()
	end, bo)
	vim.keymap.set("t", opts.normal, [[<C-\><C-n>]], bo)
	vim.keymap.set("t", opts.close, function()
		buf:kill()
	end, bo)
	vim.keymap.set("t", opts.rename, function()
		buf:rename_prompt()
	end, bo)
end

function Buffer:close()
	if not self.win then
		return
	end
	vim.api.nvim_win_close(self.win, true)
	self.win = nil
end

function Buffer:kill()
	if self.win then
		self:close()
	end
	if self.buf == 0 then
		return
	end
	vim.api.nvim_buf_delete(self.buf, { force = true })
	self.buf = 0
end

function Buffer:open(opts)
	if self.buf ~= 0 and vim.fn.bufexists(self.buf) == 0 then
		self.buf = 0
		self.win = nil
	end
	if self.win then
		return
	end
	opts.win.title = "󰆍 " .. self.title
	self.win = vim.api.nvim_open_win(self.buf, true, opts.win)
	if self.buf == 0 then
		vim.cmd("term")
		self.buf = vim.api.nvim_get_current_buf()
		vim.cmd("set nobuflisted")
		set_keymaps(self, opts.binds)
	end
	vim.cmd("startinsert")
end

return Buffer
