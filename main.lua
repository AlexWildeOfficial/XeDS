
-- Modules
local Http = require('http')
local Json = require('json')
local Router = require('./modules/router')
local Timer  = require('timer')
_G.Db = require('./modules/db')
_G.ServerConfig = require('./config')   -- YES, GLOBAL | SMH

-- Variables
local Config = _G.ServerConfig -- Alias
local ConfigTypes = {
	
	['Port'] = 'number',
	-- ['HostName'] = 'string', -- This is a server bruh
	['Debug'] = 'boolean',
	['DebugMode'] = 'number'
	
}

-- Functions
local function dprint(lvl, ...)
	if not lvl then lvl = 1 end
	
	if (Config.Debug and Config.DebugMode >= lvl) or lvl == 0 then -- 0 means print anyway
		print('[LocalDatastore Server Debug]:', ...)
	end
end

-- Pre-Checks
for k, v in pairs(Config) do -- Check for correct types
	if ConfigTypes[k] and ConfigTypes[k] ~= type(v) then
		error(ConfigTypes[k] .. ' expected, got ' .. type(v))
	end
end

for k, v in pairs(ConfigTypes) do -- Check for nil
	if Config[k] == nil then
		error('Required parameter ' .. k .. ' not found or nil')
	end
end

Db:load()   -- Load data
Db.data.keys = {}
Db.data.keys['YOUR-API-KEY-HERE'] = true -- Temporarly key


Http.createServer(function(req, res)
    local success, err = pcall(function()
        return Router.Handler(req, res)
    end)

    if not success then
        print('Something went wrong when tried to handle the request: '..err)
        res:finish(Json.encode({error = err}))
    end

end):listen(Config.Port)

Timer.setInterval(60000, function()
    print('Saving data')
    Db:save()
end)

print('Running Local Datastore Server on "http://localhost:' .. Config.Port)