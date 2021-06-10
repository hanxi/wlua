local log = require "log"
local wlua_request = require "wlua.request"
local wlua_response = require "wlua.response"

local M = {}
local mt = { __index = M }

function M:new(app, id, interface)
    local req = wlua_request:new(id, interface)
    local res = wlua_response:new(id, interface)

    local handlers, params = app.router:match(req.path, req.method)
    log.debug("wlua context new. path:", req.path, ", method:", req.method, handlers, params)

    app.router:dump()

    local found = false
    if handlers then
        found = true
    end
    local instance = {
        app = app,
        req = req,
        res = res,
        index = 0,
        handlers = handlers or {},
        params = params,
        found = found,
    }
    return setmetatable(instance, mt)
end

function M:next()
    log.debug("handlers len:", #self.handlers)
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
