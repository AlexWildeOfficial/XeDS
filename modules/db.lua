local fs = require('fs')
local path = require('path')
local json = require('json')

local db = {}

local db_path = './data/db.json'

-- Ensure
local function ensure_data_folder()
    local folder = path.dirname(db_path)
    if not fs.existsSync(folder) then
        fs.mkdirSync(folder)
    end
end

function db:load()
    self.data = {}

    if fs.existsSync(db_path) then
        local success, content = pcall(fs.readFileSync, db_path, 'utf8')
        if success and content then
            self.data = json.decode(content) or {}
        end
    end
end

function db:save()
    if not self.data then return end
    ensure_data_folder()

    pcall(function()
        fs.writeFileSync(db_path, json.encode(self.data))
    end)
end

return db
