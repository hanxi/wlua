local skynet = require "skynet"

local M = {}
local conf = {}

function M.get(key)
    if conf[key] ~= nil then
        return conf[key]
    end

    local value = skynet.getenv(key)
    if value == nil then
        return
    end

    local tmp = tonumber(value)
    if tmp ~= nil then
        value = tmp
    end

    if value == "true" then
        value = true
    elseif value == "false" then
        value = false
    end

    conf[key] = value
    return conf[key]
end

function M.get_tbl(key)
    local s = M.get(key)
    if type(s) == "string" then
        s = load("return " .. s)()
        conf[key] = s
    end
    return s
end

return M
