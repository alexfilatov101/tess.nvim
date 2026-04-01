---@type tess.shell
local bash = {
	shell = "bash",
	start = function(self, opts)
		local cmd = { self.shell }
		if opts.source then
			cmd = { self.shell, "--rcfile", opts.source }
		end
		local env = {
			TESS_SESSION = 1,
		}
		if opts.history.enabled then
			local metaPath = opts.root .. "/.nvim"
			local histPath = metaPath .. "/tess/history/t_" .. tostring(opts.id)
			local histFile = io.open(histPath)
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
		return job_id
	end,
	stop = function(id)
		vim.fn.jobstop(id)
	end,
	send = function(id, cmd)
		vim.fn.chansend(id, "set +o history")
		vim.fn.chansend(id, cmd .. "\n")
		vim.fn.chansend(id, "set -o history")
	end,
}

return bash
