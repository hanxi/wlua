local log = require "log"
local request = require "wlua.request"
local response = require "wlua.response"

local M = {}
local mt = { __index = M }

function M:new(app, id, interface)
    log.debug("wlua new")
    local instance = {
        app = app,
        req = request:new(id, interface),
        res = response:new(id, interface),
        handlers = {}, -- TODO:
    }
    return setmetatable(instance, mt)
end

function M:next()
    local path = self.req.path
    log.debug("req.path", path)
    local callback = self.app.path2callback[path]
    if callback then
        callback(self)
    end
end

function M:send(...)
    self.res:send(...)
end

return M
