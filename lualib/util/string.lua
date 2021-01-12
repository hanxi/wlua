local M = {}

function M.trim(str)
    return str:match("^%s*(.-)%s*$")
end

return M
