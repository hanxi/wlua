local wlua_agent = require "wlua.agent"
local wlua_methods = require "wlua.methods"
local wlua_routergroup = require "wlua.routergroup"
local log = require "log"
local r3 = require "r3"
local logger = require "middleware.logger"

local M = { VERSION = '0.0.1' }
local mt = { __index = M }

function M:new()
    local instance = {
        router = r3.new(),
        no_route = {},
        all_no_route = {},
    }
    log.debug("wlua new.")
    instance.routergroup = wlua_routergroup:new(instance, '/')
    return setmetatable(instance, mt)
end

function M:default()
    local app = M:new()
    app:use(logger())
    return app
end

function M:set_no_route(...)
    self.no_route = {...}
    self:reset_no_route()
end

function M:reset_no_route()
    self.all_no_route = self.routergroup:combine_handlers(self.no_route)
end

function M:run()
    self.router:compile()
    wlua_agent.run(self)
end

function M:add_route(method, absolute_path, handlers)
    log.debug("add_route:", method, absolute_path, handlers)
    self.router:insert(method, absolute_path, handlers)
end

-- M:use(middleware1, middleware2, ...)
function M:use(...)
    self.routergroup:use(...)
    self:reset_no_route()
end

-- M:group("v1", ...)
function M:group(relative_path, ...)
    return self.routergroup:group(relative_path, ...)
end

-- M:get(path, handle1, handle2, ...)
-- M:post(path, handle1, handle2, ...)
for method,_ in pairs(wlua_methods) do
    local l_name = string.lower(method)
    M[l_name] = function (self, path, ...)
        self.routergroup:handle(method, path, ...)
    end
end

-- M:static_file("favicon.ico", "./favicon.ico")
function M:static_file(relative_path, filepath)
    self.routergroup:static_file(relative_path, filepath)
end

-- M:static_dir("/static", "./")
function M:static_dir(relative_path, static_path)
    self.routergroup:static_dir(relative_path, static_path)
end

return M
