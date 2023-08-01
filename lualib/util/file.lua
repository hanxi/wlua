local config = require "config"
local puremagic = require "util.puremagic"
local log = require "log"
local sformat = string.format

local iopen = io.open
local via_content = puremagic.via_content

local M = {}

function M.get_content(filepath)
    local f = iopen(filepath, "rb")
    if not f then
        return
    end

    local content = f:read("*a")
    f:close()
    return content
end

function M.get_first_line(filepath)
    local f = iopen(filepath, "r")
    if not f then
        return
    end

    local first_line = f:read("l")
    f:close()
    return first_line
end

function M.path_join(a, b)
    if a:sub(-1) == "/" then
        if b:sub(1, 1) == "/" then
            return a .. b:sub(2)
        end
        return a .. b
    end
    if b:sub(1, 1) == '/' then
        return a .. b
    end
    return sformat("%s/%s", a, b)
end

local static_root_path = config.get("wlua_static_root_path", "./static/")
local filecache = setmetatable({}, { __mode = "kv"  })
local function read_filecache(_, filepath)
    local v = filecache[filepath]
    if v then
        return v
    end
    local fpath = static_root_path .. filepath
    log.debug("read_filecache. fpath:", fpath)
    local f = iopen(fpath)
    if f then
        local content = f:read "a"
        f:close()
		if content then
			local mimetype = via_content(content, filepath)
			filecache[filepath] = { content, mimetype }
		else
			filecache[filepath] = {}
		end
    else
        filecache[filepath] = {}
    end
    return filecache[filepath]
end

M.static_file = setmetatable({}, { __index = read_filecache })

return M
