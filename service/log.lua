-- skynet.error output
local skynet = require "skynet.manager"
local config = require "config"
local util_date = require "util.date"
local util_file = require "util.file"
local util_string = require "util.string"
local log = require "log"

-- is daemon
local daemon = config.get("daemon")

-- log config
local logpath = config.get("wlua_logpath")
local auto_cutlog = config.get("wlua_auto_cutlog")

-- sighup commond
local sighup_file = config.get("wlua_sighup_file")

local logfile
if daemon then
    logfile = io.open(logpath, "a+")
end

local function reopen_log()
    logfile:close()
    logfile = io.open(logpath, "a+")
end

local function auto_reopen_log()
    -- run clear at 0:00 am
    local futrue = util_date.get_next_zero() - util_date.now()
    skynet.timeout(futrue * 100, auto_reopen_log)

    local date_name = os.date("%Y%m%d%H%M%S", util_date.now())
    local newname = string.format("%s.%s", logpath, date_name)
    os.rename(logpath, newname)
    reopen_log()
end

-- get time str. one second format once
local last_time = 0
local last_str_time
local function get_str_time()
    local cur = util_date.now()
    if last_time ~= cur then
        last_str_time = os.date("%Y-%m-%d %H:%M:%S", cur)
    end
    return last_str_time
end

local function write_log(file, str)
    file:write(str, "\n")
    file:flush()
end

skynet.register_protocol {
    name = "text",
    id = skynet.PTYPE_TEXT,
    unpack = skynet.tostring,
    dispatch = function(_, addr, str)
        local time = get_str_time()
        str = string.format("[%08x][%s] %s", addr, time, str)
        if daemon then
            write_log(logfile, str)
        else
            print(str)
        end
    end
}

-- sighup cmd functions
local SIGHUP_CMD = {}

-- cmd for stop server
function SIGHUP_CMD.stop()
    -- TODO: broadcast stop signal
    log.warn("Handle SIGHUP, wlua will be stop.")
    skynet.sleep(100)
    skynet.abort()
end

-- cmd for cut log
function SIGHUP_CMD.cutlog()
    reopen_log()
end

local function get_sighup_cmd()
    local cmd = util_file.get_first_line(sighup_file)
    if not cmd then
        return
    end
    cmd = util_string.trim(cmd)
    return SIGHUP_CMD[cmd]
end

-- 捕捉sighup信号(kill -1)
skynet.register_protocol {
    name = "SYSTEM",
    id = skynet.PTYPE_SYSTEM,
    unpack = function(...) return ... end,
    dispatch = function()
        local func = get_sighup_cmd()
        if func then
            func()
        else
            log.error(string.format("Unknow sighup cmd, Need set sighup file. wlua_sighup_file: '%s'", sighup_file))
        end
    end
}

-- other skynet cmd
local CMD = {}

skynet.start(function()
    skynet.register ".log"
    skynet.dispatch("lua", function(_, _, cmd, ...)
        local f = CMD[cmd]
        if f then
            skynet.ret(skynet.pack(f(...)))
        else
            log.error("Invalid cmd. cmd:", cmd)
        end
    end)

    -- auto reopen log
    if auto_cutlog then
        local ok, msg = pcall(auto_reopen_log)
        if not ok then
            if not daemon then
                print(msg)
            else
                write_log(logfile, msg)
            end
        end
    end
end)
