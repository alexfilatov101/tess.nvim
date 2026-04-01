local git = {}

---Locate git root directory.
---@param cwd string Current working directory
---@return string|nil root Git root directory
function git.root(cwd)
	local root = vim.fn.systemlist({ "git", "-C", cwd, "rev-parse", "--show-toplevel" })[1]
	if vim.v.shell_error ~= 0 then
		return nil
	end
	return root
end

---Add path to .gitignore
---@param root string Git root directory
---@param ignore_path string Path to exclude
function git.exclude(root, ignore_path)
	local exclude = root .. "/.git/info/exclude"
	vim.fn.mkdir(vim.fn.fnamemodify(exclude, ":h"), "p")
	vim.fn.writefile(vim.fn.readfile(exclude) or {}, exclude)
	local lines = vim.fn.readfile(exclude)
	for _, line in ipairs(lines) do
		if line == ignore_path then
			return
		end
	end
	table.insert(lines, ignore_path)
	vim.fn.writefile(lines, exclude)
end

return git
