local log = require "log"
local wlua_methods = require "wlua.methods"
local sformat = string.format

local M = {}
local mt = { __index = M }

function M:new(app, base_path)
    log.debug("routergroup new")
    local instance = {
        app = app,
        base_path = base_path,
        handlers = {},
    }
    return setmetatable(instance, mt)
end

function M:calculate_absolute_path(relative_path)
    log.debug("calculate_absolute_path", self.base_path, relative_path)
    if self.base_path:sub(-1) == '/' then
        if relative_path:sub(1) == '/' then
            return self.base_path .. relative_path:sub(2)
        end
        return self.base_path .. relative_path
    end

    if relative_path:sub(1) == '/' then
        return self.base_path .. relative_path
    end
    return sformat("%s/%s", self.base_path, relative_path)
end

function M:combine_handlers(handlers)
    local merged_handlers = {}
    for k,v in ipairs(self.handlers) do
        merged_handlers[k] = v
    end
    local n = #self.handlers
    for k,v in ipairs(handlers) do
        merged_handlers[n+k] = v
    end
    return merged_handlers
end

function M:handle(method, relative_path, ...)
    local absolute_path = self:calculate_absolute_path(relative_path)
    local handlers = self:combine_handlers({...})
    self.app:add_route(method, absolute_path, handlers)
end

-- M:use(middleware1, middleware2, ...)
function M:use(...)
    local i = #self.handlers
    for _,v in pairs({...}) do
        i = i + 1
        self.handlers[i] = v
    end
end

-- M:get(path, handle1, handle2, ...)
-- M:post(path, handle1, handle2, ...)
for method,_ in pairs(wlua_methods) do
	M[method] = function (self, path, ...)
		self.handle(self, method, path, ...)
	end
end

return M
