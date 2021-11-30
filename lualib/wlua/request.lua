local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local util_json = require "util.json"
local config = require "config"
local urllib = require "http.url"
local log = require "log"

local sfind = string.find
local setmetatable = setmetatable
local parse_query = urllib.parse_query
local parse_url = urllib.parse

-- limit request body size
local max_request_body_size = config.get("wlua_max_request_body_size", 1024 * 1024)

local M = {}
local mt = { __index = M }

-- new request: init args/body etc from http request
function M:new(id, interface)
    local code, url, method, headers, body_raw = httpd.read_request(interface.read, max_request_body_size)
    if not code then
        if url == sockethelper.socket_error then
            log.warn("Socket closed. id:", id)
        else
            log.warn("Request error. id:", id, ",url:", url)
        end
        return
    end

    local body = body_raw
    local content_type = headers['content-type']
    -- the post request have Content-Type header set
    if content_type then
        if sfind(content_type, "application/x-www-form-urlencoded", 1, true) then
            body = parse_query(body_raw)
        elseif sfind(content_type, "application/json", 1, true) then
            body = util_json.decode(body_raw)
        end
    -- the post request have no Content-Type header set will be parsed as x-www-form-urlencoded by default
    else
        body = parse_query(body)
    end

    local query = {}
    local path,query_str = parse_url(url)
    if query_str then
        query = parse_query(query_str)
    end

    return setmetatable({
        path = path, -- uri
        method = method,
        query = query,
        body = body,
        body_raw = body_raw,
        url = url,
        origin_uri = url,
        uri = url,
        headers = headers, -- request headers
        code = code,

        id = id,
        interface = interface,
    }, mt)
end

return M
