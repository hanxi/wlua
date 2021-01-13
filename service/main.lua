local skynet = require "skynet"
local socket = require "skynet.socket"
local config = require "config"
local log = require "log"

local app_agents = {
    http = {},
    https = {},
}

local function start(protocol)
    local port_config_key = string.format("wlua_app_%s_port", protocol)
    local port = config.get(port_config_key)
    if not port then
        log.warn("Disable", protocol, "server.")
        return
    end

	local app_agent_cnt = config.get("wlua_app_agent_cnt")
    local app_agent_start = config.get("wlua_app_agent_start")
    local agents = app_agents[protocol]
    for agent_id = 1,app_agent_cnt do
        agents[agent_id] = skynet.newservice(app_agent_start, protocol, agent_id)
        skynet.call(agents[agent_id], "lua", "open", protocol, agent_id)
    end

    local host_config_key = string.format("wlua_app_%s_host", protocol)
    local host = config.get(host_config_key)
    local balance = 1
    local id = socket.listen(host, port)
    log.info("Start web. host:", host, ",port:", port)
    socket.start(id , function(id, addr)
        skynet.send(agents[balance], "lua", "socket", "request", id)
        balance = balance + 1
        if balance > #agents then
            balance = 1
        end
    end)
end

-- other skynet cmd
local CMD = {}

local env_list = {
    "app_dir", "wlua_dir",
    "luaservice", "lualoader", "lua_path", "lua_cpath", "cpath", "snax", 
    "thread", "harbor", "bootstrap", "start", "daemon", "logger", "logservice",
    "wlua_logpath", "wlua_auto_cutlog", "wlua_sighup_file",
}
local function dump_env()
    log.debug("----- begin dump env -----")
    for _, key in pairs(env_list) do
        log.debug(key, "=", config.get(key))
    end
    log.debug("----- end dump env -----")
end

skynet.start(function()
    local debug_port = config.get("wlua_debug_port")
    if debug_port then
        skynet.newservice("debug_console", debug_port)
    end

    skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
        local f = assert(CMD[cmd])
        skynet.ret(skynet.pack(f(subcmd, ...)))
    end)

    start("http")
    start("https")

    log.info("Hello wlua.")
    dump_env()
end)

