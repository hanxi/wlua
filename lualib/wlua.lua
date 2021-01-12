local skynet = require "skynet"
local config = require "config"

local env_list = {
    "app_dir", "wlua_dir",
    "luaservice", "lualoader", "lua_path", "lua_cpath", "cpath", "snax", 
    "thread", "harbor", "bootstrap", "start", "daemon", "logger", "logservice",
    "wlua_logpath", "wlua_auto_cutlog", "wlua_sighup_file",
}
local function dump_env()
    skynet.error("----- begin dump env -----")
    for _, key in pairs(env_list) do
        skynet.error(key, "=", config.get(key))
    end
    skynet.error("----- end dump env -----")
end

local M = { VERSION = '0.01' }

function M:new()
    -- router = router:new()
    local mt = {
        __index = self,
        __call = self.handle,
    }
    return setmetatable({}, mt)
end

--function M:handle(req, res, callback)
function M:handle(a,b,c)
    skynet.error("hello handle", a, b, c)
end
skynet.error("fuck", M.handle)

function M:run()
    skynet.start(function ()
        skynet.error("Hello wlua")
        dump_env()
        skynet.exit()
    end)
end



return M
