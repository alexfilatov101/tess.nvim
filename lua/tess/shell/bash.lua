---@type tess.shell
local bash = {
	shell = "bash",
	start = function(self, opts)
		local cmd = { self.shell }
		local env = {
			TESS_SESSION = 1,
			HISTCONTROL = "ignorespace",
		}
		local metaPath = opts.root .. "/.nvim"
		if opts.source == "default" then
			opts.source = metaPath .. "/tess/source/s_" .. tostring(opts.id)
		end
		if opts.source then
			env.SOURCEFILE = opts.source
		end
		if opts.history.enabled then
			local histPath = metaPath .. "/tess/history/t_" .. tostring(opts.id)
			local histFile = io.open(histPath, "a")
			if histFile then
				histFile:close()
				env.HISTFILE = histPath
			end
		end
		local job_id = vim.fn.jobstart(cmd, {
			term = true,
			cwd = opts.cwd,
			env = env,
		})
		if opts.source then
			local f = io.open(opts.source, "r")
			if f then
				f:close()
				self.send(job_id, "source $SOURCEFILE")
				self.send(job_id, "clear")
			end
		end
		return job_id
	end,
	stop = function(id)
		vim.fn.jobstop(id)
	end,
	send = function(id, cmd)
		vim.fn.chansend(id, " " .. cmd .. "\n")
	end,
}

return bash
