local M = {}

function M.get_content(filename)
    local f = io.open(filename, "rb")
    if not f then
        return
    end

    local content = f:read("*a")
    f:close()
    return content
end

function M.get_first_line(filename)
    local f = io.open(filename, "r")
    if not f then
        return
    end

    local first_line = f:read("l")
    f:close()
    return first_line
end

return M
