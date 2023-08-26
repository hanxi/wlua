local skynet = require "skynet"
local config = require "config"
local util_table = require "util.table"
local traceback = debug.traceback

local M = {}
local levels = {
	debug = 1,
	info = 2,
	warn = 3,
	error = 4,
}
local level = config.get("wlua_loglevel", "debug")
local loglevel = levels[level]

function M.is_debug()
	if levels.debug < loglevel then return end
	return true
end

function M.debug(...)
	if levels.debug < loglevel then return end
	local tbl = {}
	for i = 1, select('#', ...) do
		local v = select(i, ...)
		if type(v) == "table" then
			tbl[i] = util_table.tostring(v)
		else
			tbl[i] = tostring(v) or "nil"
		end
	end
	skynet.error("[DEBUG]", table.concat(tbl, " "))
end

function M.info(...)
	if levels.info < loglevel then return end
	skynet.error("[INFO]", ...)
end

function M.warn(...)
	if levels.warn < loglevel then return end
	skynet.error("[WARN]", ...)
end

function M.error(...)
	if levels.error < loglevel then return end
	skynet.error("[ERROR]", ...)
	skynet.error("[ERROR]", traceback())
end

function M.log(...)
	skynet.error(...)
end

return M
