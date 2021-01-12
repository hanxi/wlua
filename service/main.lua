local skynet = require "skynet"
local socket = require "skynet.socket"
local config = require "config"

local app_agents = {
    http = {},
    https = {},
}

local function start(protocol)
    local port_config_key = string.format("wlua_app_%s_port", protocol)
    local port = config.get(port_config_key)
    if not port then
        skynet.error("Disable", protocol, "server")
        return
    end

	local app_agent_cnt = config.get("wlua_app_agent_cnt")
    local app_agent_start = config.get("wlua_app_agent_start")
    local agents = app_agents[protocol]
    for i = 1,app_agent_cnt do
        agents[i] = skynet.newservice("app_agent_start", i, protocol)
    end

    local host_config_key = string.format("wlua_app_%s_host", protocol)
    local host = config.get(host_config_key)
    local balance = 1
    local id = socket.listen(host, port)
    skynet.error("Listen web port:", port)
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

skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
        local f = assert(CMD[cmd])
        skynet.ret(skynet.pack(f(subcmd, ...)))
    end)
    start("http")
    start("https")
end)

