local skynet = require "skynet.manager"
local socket = require "skynet.socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local log = require "log"
local request = require "wlua.request"

local traceback = debug.traceback
local xpcall = xpcall

local protocol
local agent_id
local opened = false

local SOCKET = {}
local CMD = {}

local resp_header = {
    ["Access-Control-Allow-Origin"] = "*",
    ["Access-Control-Allow-Credentials"] = "true",
    ["Access-Control-Allow-Methods"] = "*",
    ["Access-Control-Allow-Headers"] = "*",
}

local function response(id, write, ...)
    local ok, err = httpd.write_response(write, ...)
    if not ok then
        if err ~= sockethelper.socket_error then
            log.warn("Error in response. fd:", id, ",err:", err)
        end
    end
end

local function _handle_request(req)
    log.debug("Handle requrest. url:", req.url, ",method:", req.method)
    if req.method == "OPTIONS" then
        response(req.id, req.interface.write, 204, '', resp_header)
        return
    end

    local msg = "hello world"
    response(req.id, req.interface.write, 200, msg, resp_header)
end

local function handle_request(id, interface)
    local req = request:new(id, interface)
    if not req then
        return
    end

    -- TODO: access.log 远程主机ip 请求时间 method url code sendbyte
    log.info("Request. url:", req.url, ", method:", req.method)

    if req.code ~= 200 then
        response(id, interface.write, req.code)
        return
    end

    _handle_request(req)
end

local SSLCTX_SERVER = nil
local function gen_interface(id)
    if protocol == "http" then
        return {
            init = nil,
            close = nil,
            read = sockethelper.readfunc(id),
            write = sockethelper.writefunc(id),
        }
    elseif protocol == "https" then
        local tls = require "http.tlshelper"
        if not SSLCTX_SERVER then
            SSLCTX_SERVER = tls.newctx()
            -- gen cert and key
            -- openssl req -x509 -newkey rsa:2048 -days 3650 -nodes -keyout server-key.pem -out server-cert.pem
            local certfile = skynet.getenv("wlua_certfile") or "./server-cert.pem"
            local keyfile = skynet.getenv("wlua_keyfile") or "./server-key.pem"
            log.debug("Set https cert file. wlua_certfile:", certfile, "wlua_keyfile:", keyfile)
            SSLCTX_SERVER:set_cert(certfile, keyfile)
        end
        local tls_ctx = tls.newtls("server", SSLCTX_SERVER)
        return {
            init = tls.init_responsefunc(id, tls_ctx),
            close = tls.closefunc(tls_ctx),
            read = tls.readfunc(id, tls_ctx),
            write = tls.writefunc(id, tls_ctx),
        }
    else
        log.error("Invalid protocol:", protocol)
    end
end

function SOCKET.request(id)
    socket.start(id)

    --log.info("start id:", id)
    local interface = gen_interface(id)
    if interface.init then
        interface.init()
    end

    local ok,err = xpcall(handle_request, traceback, id, interface)
    if not ok then
        log.error("Error handle_request. id:", id, ", err:", err)
    end

    socket.close(id)
    if interface and interface.close then
        interface.close()
    end
end

function CMD.open(_protocol, _agent_id)
    if opened then
        return
    end
    protocol = _protocol
    agent_id = _agent_id

    log.info("Open wlua agent. protocol:", protocol, ", agent_id:", agent_id)
    local agent_name = string.format(".wlua_agent_%s_%s", protocol, agent_id)
    skynet.register(agent_name)
    opened = true
end

function CMD.close()
    opened = false
    -- TODO: add timer to exit
    skynet.exit()
end

local function dispatch_socket(subcmd, id, ...)
    if opened then
        local ok,err = xpcall(SOCKET[subcmd], traceback, id, ...)
        if not ok then
            log.error("Error dispatch socket. err:", err)
        end
    else
        log.error("Wlua agent unopened.")
        socket.close(id)
    end
end

local M = {}
function M.run()
    skynet.start(function()
        skynet.dispatch("lua", function (_, _, cmd, subcmd, ...)
            if cmd == "socket" then
                dispatch_socket(subcmd, ...)
            else
                local f = assert(CMD[cmd])
                skynet.ret(skynet.pack(f(subcmd, ...)))
            end
        end)
    end)
end

return M
