local skynet = require "skynet"
local util_table = require "util.table"

local M = {}
local conf = {}
local config_result

function M.get(key)
    if conf[key] ~= nil then
        return conf[key]
    end

    local value = config_result[key]
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

local load_config = [=[
    local result = {}
    local function getenv(name) return assert(os.getenv(name), [[os.getenv() failed: ]] .. name) end
    local sep = package.config:sub(1,1)
    local current_path = [[.]]..sep
    local function include(filename)
        local last_path = current_path
        local path, name = filename:match([[(.*]]..sep..[[)(.*)$]])
        if path then
            if path:sub(1,1) == sep then    -- root
                current_path = path
            else
                current_path = current_path .. path
            end
        else
            name = filename
        end
        local f = assert(io.open(current_path .. name))
        local code = assert(f:read [[*a]])
        code = string.gsub(code, [[%$([%w_%d]+)]], getenv)
        f:close()
        assert(load(code,[[@]]..filename,[[t]],result))()
        current_path = last_path
    end
    setmetatable(result, { __index = { include = include } })
    local config_name = ...
    include(config_name)
    setmetatable(result, nil)
    return result
]=]
function M.do_load_config()
    local wlua_dir = skynet.getenv("wlua_dir")
    local config_file = string.format("%s/conf/wlua.conf", wlua_dir)
    config_result = load(load_config)(config_file)
end

function M.dump_all_config()
    skynet.error("Begin dump_all_config.")
    for k,v in util_table.sort_pairs(config_result) do
        skynet.error(k, "=", v)
    end
    skynet.error("End dump_all_config.")
end

M.do_load_config()
return M
