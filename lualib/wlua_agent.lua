local skynet = require "skynet.manager"
local socket = require "skynet.socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local log = require "log"
local web_router = require "web_agent.web_router"
local router = require 'router'
local util_table = require "util.table"
local user_mng = require "web_agent.user.user_mng"

local agent_id, protocol = ...
local protocol = protocol or "http"

local SOCKET = {}
local CMD = {}

local r = router.new()
web_router(r)

local resp_header = {
    ["Access-Control-Allow-Origin"] = "*",
    ["Access-Control-Allow-Credentials"] = "true",
    ["Access-Control-Allow-Methods"] = "*",
    ["Access-Control-Allow-Headers"] = "*",
}

local function response(id, write, ...)
    local ok, err = httpd.write_response(write, ...)
    if not ok then
        -- if err == sockethelper.socket_error , that means socket closed.
        log.warn(string.format("fd = %d, %s", id, err))
    end
    --log.info("fd=", id, ...)
end

local function handle_request(id, url, method, header, body, interface)
    local path, query_str = urllib.parse(url)
    local query
    if query_str then
        query = urllib.parse_query(query_str)
    else
        query = {}
    end

    log.debug(url, method)
    if method == "OPTIONS" then
        response(id, interface.write, 204, '', resp_header)
        return
    end

    local ok, msg, code, _resp_header = r:execute(method, path, query, {header = header, body = body})
    if ok then
        --log.info(msg, code)
        if _resp_header then
            util_table.merge(_resp_header, resp_header)
        else
            _resp_header = resp_header
        end
        response(id, interface.write, code or 200, msg, _resp_header)
    else
        response(id, interface.write, 404, "404 Not found", resp_header)
    end
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
            log.debug("certfile:", certfile)
			log.debug("keyfile:", keyfile)
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
        log.error(string.format("Invalid protocol: %s", protocol))
    end
end

local function close_socket(id, interface)
    socket.close(id)
    if interface.close then
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

    -- limit request body size to 1M (you can pass nil to unlimit)
    local max_request_data_size = config.get("wlua_max_request_data_size")
    local code, url, method, header, body = httpd.read_request(interface.read, max_request_data_size)
    -- TODO: access.log
    log.info("request url:", url)
    if not code then
        if url == sockethelper.socket_error then
            log.warn("socket closed")
        else
            log.warn("request error. url:", url)
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

skynet.start(function()
    local agent_name = string.format(".wlua_agent_%s_%s", protocol, agent_id)
    skynet.register(agent_name)

    skynet.dispatch("lua", function (_, _, cmd, subcmd, ...)
        if cmd == "socket" then
            local f = SOCKET[subcmd]
            f(...)
        else
            local f = assert(CMD[cmd])
            skynet.ret(skynet.pack(f(subcmd, ...)))
        end
    end)
end)

