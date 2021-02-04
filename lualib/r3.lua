local r3_core = require "r3.core"

local function gc_free(self)
    r3_core.free(self.tree)
end

local M = { VERSION = '0.01' }
local mt = { __index = M, __gc = gc_free }

local _METHOD_GET     = 2
local _METHOD_POST    = 2 << 1
local _METHOD_PUT     = 2 << 2
local _METHOD_DELETE  = 2 << 3
local _METHOD_PATCH   = 2 << 4
local _METHOD_HEAD    = 2 << 5
local _METHOD_OPTIONS = 2 << 6

local _METHODS = {
    GET     = _METHOD_GET,
    POST    = _METHOD_POST,
    PUT     = _METHOD_PUT,
    DELETE  = _METHOD_DELETE,
    PATCH   = _METHOD_PATCH,
    HEAD    = _METHOD_HEAD,
    OPTIONS = _METHOD_OPTIONS,
}

function M:new(cap)
    local instance = {
        tree = r3_core.create(cap or 10),
        idinc = 0,
        id2data = {},
    }
    return setmetatable(instance, mt)
end

-- return: ok, err
function M:insert(method, path, data)
    if type(path) ~= "string" then
        error("invalid argument path")
    end

    if not method or not path or not data then
        return nil, "invalid argument of route"
    end

    local bit_methods
    if type(method) ~= "table" then
        bit_methods = method and _METHODS[method] or 0
    else
        bit_methods = 0
        for _, m in ipairs(method) do
            bit_methods = bit_methods | _METHODS[m]
        end
    end
    self.idinc = self.idinc + 1
    local id = self.idinc
    self.id2data[id] = data
    return r3_core.insert(self.tree, bit_methods, path, id)
end

-- return: ok, err
function M:compile()
    return r3_core.compile(self.tree)
end

function M:dump()
    r3_core.dump(self.tree)
end

-- return: data, params
function M:match(path, method)
    local bit_method = _METHODS[method] or 0
    local id, slugs, tokens = r3_core.match_route(self.tree, path, bit_method)
    if not id or not self.id2data[id] then
        return
    end

    local params = {}
    local idx = 0
    for i,key in ipairs(slugs) do
        local value = tokens[i]
        if key == "" then
            idx = idx + 1
            params[idx] = value
        else
            params[key] = value
        end
    end
    return self.id2data[id], params
end

return M
