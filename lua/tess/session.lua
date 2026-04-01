---Terminal Session
---@class tess.session
---@field shell tess.shell? Session shell
---@field job_id number? Session job ID
---@field id number Session ID
---@field bufnr number? Session buffer number
---@field window number? Session window number

---Session options
---@class tess.session.opts
---@field window vim.api.keyset.win_config Window configuration
---@field shell tess.shell.opts Shell opts
---@field keymaps any Window keymaps

---@class tess.session
local Session = {
	id = -1,
}

---Create new session
---@param shell tess.shell Shell to use
---@param id number? Session Id, vim.v.count1 if unset
---@return tess.session session New session
function Session:new(shell, id)
	if not id then
		id = vim.v.count1
	end
	local o = {}
	o.id = id
	o.title = "Terminal [" .. tostring(o.id) .. "]"
	o.shell = shell
	setmetatable(o, self)
	self.__index = self
	return o
end

---Rename session
---@param title string New session title
function Session:rename(title)
	self.title = title
	if self.window then
		vim.api.nvim_win_set_config(self.window, { title = "󰆍 " .. title })
	end
end

---Invoke prompt and rename session on successful input
function Session:rename_prompt()
	vim.ui.input({ prompt = "Enter new terminal name: " }, function(input)
		vim.cmd("startinsert")
		if not input then
			return
		end
		if self.window then
			if self.window == vim.api.nvim_get_current_win() then
				vim.cmd("startinsert")
			end
			self:rename(input)
		end
	end)
end

---Open session window
---@param config vim.api.keyset.win_config Window configuration
---@return number? window Window ID
function Session:open_window(config)
	assert(self.shell, "Tess panic: session shell is not defined")
	assert(self.bufnr, "Tess panic: session buffer is not defined")
	assert(vim.api.nvim_buf_is_loaded(self.bufnr), "Tess panic: session buffer was unloaded without proper handling")
	if self.window then
		local valid = vim.api.nvim_win_is_valid(self.window)
		if not valid then
			self.window = nil
		else
			return self.window
		end
	end
	config.title = " 󰆍 " .. self.title .. " "
	self.window = vim.api.nvim_open_win(self.bufnr, true, config)
	if self.window == 0 then
		self.window = nil
		return self.window
	end
	vim.cmd("startinsert")
	return self.window
end

---Close session window if open
function Session:close_window()
	if not self.window then
		return
	end
	if vim.api.nvim_win_is_valid(self.window) then
		vim.api.nvim_win_close(self.window, true)
	end
	self.window = nil
end

local function set_keymaps(session, opts)
	local bo = { buffer = true, silent = true }
	vim.keymap.set("t", opts.hide, function()
		session:close_window()
	end, bo)
	vim.keymap.set("t", opts.normal, [[<C-\><C-n>]], bo)
	vim.keymap.set("t", opts.close, function()
		session:kill()
	end, bo)
	vim.keymap.set("t", opts.rename, function()
		session:rename_prompt()
	end, bo)
	vim.api.nvim_create_autocmd("BufUnload", {
		callback = function()
			session.bufnr = nil
			session.job_id = nil
		end,
		buffer = session.bufnr,
	})
end

---Initalize session buffer
---@param config tess.session.opts
function Session:init_buffer(config)
	assert(self.shell, "Tess panic: session shell is not defined")
	if self.bufnr then
		local loaded = vim.fn.bufexists(self.bufnr)
		if not loaded then
			self.bufnr = nil
			self.job_id = nil
		else
			return self.bufnr
		end
	end
	self.bufnr = vim.api.nvim_create_buf(false, true)
	if self.bufnr == 0 then
		self.bufnr = nil
		return self.bufnr
	end
	self:open_window(config.window)
	self.job_id = self.shell:start(config.shell)
	set_keymaps(self, config.keymaps)
	return self.bufnr
end

---Close session buffer.
function Session:close_buffer()
	assert(self.shell, "Tess panic: session shell is not defined")
	self.shell.stop(self.job_id)
	if not self.bufnr then
		return
	end
	vim.api.nvim_buf_delete(self.bufnr, { force = true })
	self.bufnr = nil
	self.job_id = nil
end

function Session:kill()
	if self.window then
		self:close_window()
	end
	if self.bufnr then
		self:close_buffer()
	end
end

return Session
