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

function M:send(text, status)
    self.status = status or self.status
    self:write(text)
end

function M:send_json(lua_table)
    local text = util_json.encode(lua_table)
    self.resp_header["Content-Type"] = "application/json"
    self:write(text)
end

function M:write(data)
    self.written = true
    local ok, err = httpd.write_response(self.interface.write, self.status, data, self.resp_header)
    if not ok then
        if err ~= sockethelper.socket_error then
            log.warn("Error in response. fd:", self.id, ",status:", self.status, ",err:", err)
        end
    end
end

return M
