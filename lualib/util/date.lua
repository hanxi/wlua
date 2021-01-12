local skynet = require "skynet"

local M = {}

function M.now()
    return math.floor(skynet.time())
end

function M.get_next_zero(cur_time, zero_point)
    zero_point = zero_point or 0
    cur_time = cur_time or M.now()

    local t = os.date("*t", cur_time)
    if t.hour >= zero_point then
        t = os.date("*t", cur_time + 24*3600)
    end
    local zero_date = {
        year = t.year,
        month = t.month,
        day = t.day,
        hour = zero_point,
        min = 0,
        sec = 0,
    }
    return os.time(zero_date)
end

return M
