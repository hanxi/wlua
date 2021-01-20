--local config = require "config"
local wlua_agent = require "wlua.agent"
local log = require "log"

local M = { VERSION = '0.01' }
local mt = { __index = M }

function M:new()
    log.debug("wlua new")
    local instance = {
        path2callback = {},
    }
    -- router = router:new()
    return setmetatable(instance, mt)
end

function M:get(path, callback)
    self.path2callback[path] = callback
end

function M:run()
    wlua_agent.run(self)
end

return M
