local cjson = require "cjson"

local M = {}

M.encode = cjson.encode
M.decode = cjson.decode
M.null = cjson.null

return M
