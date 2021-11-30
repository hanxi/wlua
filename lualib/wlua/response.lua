local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local log = require "log"
local util_json = require "util.json"

local M = {}
local mt = { __index = M }

function M:new(id, interface)
    local instance = {
        id = id,
        interface = interface,
        resp_header = {}, -- TODO:
        status = 200,
        written = false,
    }
    return setmetatable(instance, mt)
end

function M:get_header(header_key)
    return self.resp_header[header_key]
end

function M:set_header(header_key, header_value)
    self.resp_header[header_key] = header_value
end

function M:set_content_type(content_type)
    self:set_header("Content-Type", content_type)
end

function M:send(text, status, content_type)
    self.status = status or self.status
    content_type = content_type or "text/plain"
    self:set_content_type(content_type)
    self:write(text)
end

function M:send_json(lua_table)
    local text = util_json.encode(lua_table)
    self:set_content_type("application/json")
    self:write(text)
end

function M:write(data)
    self.written = true
    log.debug("write. resp_header:", self.resp_header)
    local ok, err = httpd.write_response(self.interface.write, self.status, data, self.resp_header)
    if not ok then
        if err ~= sockethelper.socket_error then
            log.warn("Error in response. fd:", self.id, ",status:", self.status, ",err:", err)
        end
    end
end

return M
