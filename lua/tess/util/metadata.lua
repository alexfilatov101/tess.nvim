---@class tess.util.metadata
---@field root string Root metadata directory
---@field modules string[]? Available metadata modules (subfolders)
local meta = {}
meta.__index = meta

---Initialize metadata
---@param root string root metadata directory
---@param modules string[]? Available metadata modules (subfolders)
---@return tess.util.metadata
function meta.new(root, modules)
	local self = setmetatable({}, meta)
	self.root = root
	self.modules = modules
	self:init()
	return self
end

---Initialize metadata modules.
---Recreates modules folders if necessary
function meta:init()
	for _, m in ipairs(self.modules) do
		vim.fn.mkdir(self.root .. "/" .. m, "p")
	end
end

return meta
