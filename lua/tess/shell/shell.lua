---@class tess.shell
---@field shell     string shell process name
---@field start     fun(self:tess.shell, opts:tess.shell.opts):number|nil Start shell job
---@field stop      fun(id:number)  Stop shell job
---@field send      fun(id:number, cmd:string) Send command to shell

--- Shell options class definition
---@class tess.shell.opts
---@field id number Session ID
---@field cwd string|nil Current working directory
---@field root string Project root directory
---@field source string|nil Path to shell configuration file to source on startup
---@field history tess.shell.opts.history History options

--- Shell history options
---@class tess.shell.opts.history
---@field enabled boolean Enable session history
---@field size number? History size
---@field filesize number? History file size

return {
	bash = require("tess.shell.bash"),
}
