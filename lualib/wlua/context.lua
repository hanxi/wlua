local log = require "log"
local wlua_request = require "wlua.request"
local wlua_response = require "wlua.response"

local M = {}
local mt = { __index = M }

function M:new(app, id, interface, addr)
    local req = wlua_request:new(id, interface)
    if not req then
        return
    end

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
        addr = addr,
    }
    return setmetatable(instance, mt)
end

function M:next()
    self.index = self.index + 1
    while self.index <= #self.handlers do
        self.handlers[self.index](self)
        self.index = self.index + 1
    end
end

-- M:send(text, status)
function M:send(...)
    self.res:send(...)
end

-- M:send_json({AA="BB"})
function M:send_json(...)
    self.res:send_json(...)
end

return M
