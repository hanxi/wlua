local log = require "log"
local wlua_request = require "wlua.request"
local wlua_response = require "wlua.response"

local M = {}
local mt = { __index = M }

function M:new(app, id, interface)
    local req = wlua_request:new(id, interface)
    local res = wlua_response:new(id, interface)
    log.debug("wlua new. method:", req.method, ",path:", req.path)

    app.router:execute(req.method, req.path)
    local instance = {
        app = app,
        req = req,
        res = res,
        index = 0,
        handlers = app.tmp_handlers or {},
    }
    return setmetatable(instance, mt)
end

function M:next()
    for i=self.index + 1, #self.handlers do
        self.handlers[i](self)
    end
    self.index = #self.handlers
end

-- M:send(text, status)
function M:send(...)
    self.res:send(...)
end

return M
