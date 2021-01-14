local tinsert = table.insert
local tsort = table.sort

local M = {}

function M.sort_pairs(t, f)
    local a = {}
    for n in pairs(t) do
        tinsert(a, n)
    end
    tsort(a, f)

    local i = 0
    return function ()
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
end

return M
