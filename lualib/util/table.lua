local tinsert = table.insert
local tsort = table.sort
local gsub = string.gsub
local match = string.match

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

function M.swap_key_value(t)
    local ret = {}
    for k,v in pairs(t) do
        ret[v] = k
    end
    return ret
end

---------------------------------
-- table.tostring(tbl)
---------------------------------
-- fork from http://lua-users.org/wiki/TableUtils
local function append_result(result, ...)
    local n = select('#', ...)
    for i=1,n  do
        result.i = result.i + 1
        result[result.i] = select(i, ...)
    end
end

local function val_to_str(v, result, depth)
    local tp = type(v)
    if "string" == tp then
        v = gsub(v, "\n", "\\n")
        if match(gsub(v, "[^'\"]", ""), '^"+$') then
            append_result(result, "'")
            append_result(result, v)
            append_result(result, "'")
        else
            append_result(result, '"')
            v = gsub(v, '"', '\\"')
            append_result(result, v)
            append_result(result, '"')
        end
    elseif "table" == tp then
        M.tostring_tbl(v, result, depth)
    elseif "function" == tp then
        append_result(result, '"', tostring(v), '"')
    else
        append_result(result, tostring(v))
    end
end

local function key_to_str(k, result, depth)
    if "string" == type(k) and match(k, "^[_%a][_%a%d]*$") then
        append_result(result, k)
    else
        append_result(result, "[")
        val_to_str(k, result, depth)
        append_result(result, "]")
    end
end

local MAX_STR_TBL_CNT = 1024*1024 -- result has 1M element
M.tostring_tbl = function (tbl, result, depth)
    if not result.i then
        result.i = 0
    end
    depth = (depth or 0) + 1
    if depth > 50 then
        return
    end
    append_result(result, "{")
    for k,v in pairs(tbl) do
        if result.i > MAX_STR_TBL_CNT then
            break
        end
        key_to_str(k, result, depth)
        append_result(result, "=")
        val_to_str(v, result, depth)
        append_result(result, ",")
    end
    append_result(result, "}")
end

M.concat_tostring_tbl = function (result)
    result.i = nil
    return table.concat(result, "")
end

M.tostring = function(tbl)
    local result = {}
    result.i = 0
    val_to_str(tbl, result)
    return M.concat_tostring_tbl(result)
end

return M
