local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local log = require "log"

local M = {}
local mt = { __index = M }

function M:new(id, interface)
    local instance = {
        id = id,
        interface = interface,
        resp_header = {}, -- TODO:
        status = 200,
    }
    -- router = router:new()
    return setmetatable(instance, mt)
end

function M:send(text, status)
    local ok, err = httpd.write_response(self.interface.write, status or self.status, text, self.resp_header)
    if not ok then
        if err ~= sockethelper.socket_error then
            log.warn("Error in response. fd:", self.id, ",err:", err)
        end
    end
end

return M
