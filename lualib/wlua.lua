--local config = require "config"
local wlua_agent = require "wlua.agent"
local wlua_methods = require "wlua.methods"
local wlua_routergroup = require "wlua.routergroup"
local log = require "log"
local r3 = require "r3"

local M = { VERSION = '0.01' }
local mt = { __index = M }

function M:new()
    local instance = {
        router = r3.new(),
    }
    log.debug("wlua new.")
    instance.routergroup = wlua_routergroup:new(instance, '/')
    return setmetatable(instance, mt)
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
end

-- M:get(path, handle1, handle2, ...)
-- M:post(path, handle1, handle2, ...)
for method,_ in pairs(wlua_methods) do
    local l_name = string.lower(method)
	M[l_name] = function (self, path, ...)
		self.routergroup.handle(self.routergroup, method, path, ...)
	end
end

return M
