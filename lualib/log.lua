local skynet = require "skynet"
local config = require "config"
local traceback = debug.traceback

local M = {}
local levels = {
    debug = 1,
    info = 2,
    warn = 3,
    error = 4,
}
local loglevel = levels[config.get("wlua_loglevel")] or 1

function M.debug(...)
    if levels.debug < loglevel then return end
    skynet.error("[DEBUG]", ...)
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

return M