local skynet = require "skynet"
local config = require "config"
local wlua_agent = require "wlua_agent"
local log = require "log"

local M = { VERSION = '0.01' }
local mt = { __index = M }

function M:new()
    --log.debug("wlua new")
    -- router = router:new()
    return setmetatable({}, mt)
end

function M:run()
    wlua_agent.run()
end

return M
