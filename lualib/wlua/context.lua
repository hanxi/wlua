local log = require "log"
local wlua_request = require "wlua.request"
local wlua_response = require "wlua.response"
local util_file = require "util.file"

local M = {}
local mt = { __index = M }

function M:new(app, id, interface, addr)
    local req = wlua_request:new(id, interface)
    if not req then
        return
    end

    local res = wlua_response:new(id, interface)

    local handlers, params = app.router:match(req.path, req.method)
    log.debug("wlua context new. path:", req.path, ", method:", req.method, ", params:", params)

    if log.is_debug() then
        app.router:dump()
    end

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

--中断调用,比如中间件验证失败
function M:abort()
    self.index = #self.handlers + 1
end

-- M:send(text, status, content_type)
function M:send(...)
    self.res:send(...)
end

-- M:send_json({AA="BB"})
function M:send_json(...)
    self.res:send_json(...)
end

function M:file(filepath)
    local ret = util_file.static_file[filepath]
    local content = ret[1]
    local mimetype = ret[2]
    if not content then
        self.found = false
        self.res.status = 404
        log.debug("file not exist:", filepath)
        return
    end
    log.debug("file. filepath:", filepath, ", mimetype:", mimetype)
    self:send(content, 200, mimetype)
end

function M:set_res_header(header_key, header_value)
    self.res:set_header(header_key, header_value)
end

return M
