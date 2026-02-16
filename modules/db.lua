local fs = require('fs')
local json = require('json')

local db = {}

function db:load()
    self.data = {}
    local success, data = pcall(function()
        local f = io.open('./data/db.json', 'r')
        if f then
            local c = f:read("*a")
            f:close()
            return c
        end
    end)

    if data then
        self.data = json.decode(data or '{}') or {}
    end

    if not self.data then
        self.data = {}
    end
end

function db:save()
    if self.data then
        local s, r = pcall(function()
            local f = io.open('./data/db.json', 'w')
            f:write(json.encode(self.data))
            f:flush()
        end)
    end
end


return db