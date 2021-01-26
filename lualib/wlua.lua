--local config = require "config"
local wlua_agent = require "wlua.agent"
local wlua_methods = require "wlua.methods"
local wlua_routergroup = require "wlua.routergroup"
local log = require "log"
local router = require "router" -- TODO: 使用 libr3 替换

local M = { VERSION = '0.01' }
local mt = { __index = M }

function M:new()
    log.debug("wlua new")
    local instance = {
        router = router.new(),
    }
    instance.routergroup = wlua_routergroup:new(instance, '/')
    return setmetatable(instance, mt)
end

function M:run()
    wlua_agent.run(self)
end

function M:add_route(method, absolute_path, handlers)
    log.debug("add_route:", method, absolute_path)
    self.router:match(method:upper(), absolute_path, function(params)
        self.tmp_handlers = handlers
        log.debug("callback:", params, handlers)
    end)
end

-- M:use(middleware1, middleware2, ...)
function M:use(...)
    self.routergroup:use(...)
end

-- M:get(path, handle1, handle2, ...)
-- M:post(path, handle1, handle2, ...)
for method,_ in pairs(wlua_methods) do
	M[method] = function (self, path, ...)
		self.routergroup[method](self.routergroup, path, ...)
	end
end

return M
