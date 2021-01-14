local skynet = require "skynet.manager"
local socket = require "skynet.socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local log = require "log"
local config = require "config"

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

local function handle_request(id, url, method, header, body, interface)
    local path, query_str = urllib.parse(url)
    local query
    if query_str then
        query = urllib.parse_query(query_str)
    else
        query = {}
    end

    log.debug("Handle requrest. url:", url, ",method:", method)
    if method == "OPTIONS" then
        response(id, interface.write, 204, '', resp_header)
        return
    end

    local msg = "hello world"
    response(id, interface.write, 200, msg, resp_header)
end

local SSLCTX_SERVER = nil
local function gen_interface(protocol, fd)
    if protocol == "http" then
        return {
            init = nil,
            close = nil,
            read = sockethelper.readfunc(fd),
            write = sockethelper.writefunc(fd),
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
            init = tls.init_responsefunc(fd, tls_ctx),
            close = tls.closefunc(tls_ctx),
            read = tls.readfunc(fd, tls_ctx),
            write = tls.writefunc(fd, tls_ctx),
        }
    else
        log.error("Invalid protocol:", protocol)
    end
end

local function close_socket(id, interface)
    socket.close(id)
    if interface and interface.close then
        interface.close()
    end
end

function SOCKET.request(id)
    socket.start(id)
    --log.info("start id:", id)
    local interface = gen_interface(protocol, id)
    if interface.init then
        interface.init()
    end

    -- limit request body size
    local max_request_body_size = config.get("wlua_max_request_body_size")
    local code, url, method, header, body = httpd.read_request(interface.read, max_request_body_size)
    -- TODO: access.log
    log.info("Request. url:", url)
    if not code then
        if url == sockethelper.socket_error then
            log.warn("Socket closed. id:", id)
        else
            log.warn("Request error. id:", id, ",url:", url)
        end
        close_socket(id, interface)
        return
    end

    if code ~= 200 then
        response(id, interface.write, code)
        close_socket(id, interface)
        return
    end

    handle_request(id, url, method, header, body, interface)
    close_socket(id, interface)
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

local M = {}
function M.run()
    skynet.start(function()
        skynet.dispatch("lua", function (_, _, cmd, subcmd, ...)
            if cmd == "socket" then
                if opened then
                    local ok,msg = xpcall(SOCKET[subcmd], debug.traceback, ...)
                    if not ok then
                        log.error("Error dispatch socket. err:", msg)
                    end
                else
                    log.error("Wlua agent unopened.")
                    socket.close(...)
                end
            else
                local f = assert(CMD[cmd])
                skynet.ret(skynet.pack(f(subcmd, ...)))
            end
        end)
    end)
end

return M
