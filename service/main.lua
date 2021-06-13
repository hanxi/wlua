local skynet = require "skynet.manager"
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
    local listen_id = socket.listen(host, port)
    log.info("Start web. host:", host, ",port:", port)
    socket.start(listen_id , function(id, addr)
        skynet.send(agents[balance], "lua", "socket", "request", id, addr)
        balance = balance + 1
        if balance > #agents then
            balance = 1
        end
    end)
end

-- other skynet cmd
local CMD = {}
local function reload_agents(protocol, agents)
    local app_agent_start = config.get("wlua_app_agent_start")
    for agent_id,agent in pairs(agents) do
        log.info("Try to close agent. protocol:", protocol, ", agent_id:", agent_id)
        skynet.send(agent, "lua", "close")

        local new_agent = skynet.newservice(app_agent_start, protocol, agent_id)
        skynet.call(new_agent, "lua", "open", protocol, agent_id)
        agents[agent_id] = new_agent
    end
end
function CMD.reload()
    local cache = require "skynet.codecache"
    cache.clear()
    for protocol, agents in pairs(app_agents) do
        reload_agents(protocol, agents)
    end
end

skynet.start(function()
    skynet.register(".main")
    local debug_port = config.get("wlua_debug_port")
    if debug_port then
        skynet.newservice("debug_console", debug_port)
    end

    skynet.dispatch("lua", function(_, _, cmd, subcmd, ...)
        local f = assert(CMD[cmd])
        skynet.ret(skynet.pack(f(subcmd, ...)))
    end)

    start("http")

    if not pcall(require, "ltls.c") then
        log.error("No ltls module, https is not supported")
    else
        start("https")
    end

    log.info("Hello wlua.")
    config.dump_all_config()
end)

