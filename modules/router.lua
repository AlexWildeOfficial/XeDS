local url = require('url')
local qs = require('querystring')
local json = require('json')

local Router = {}
local Routes = {

    ['GET'] = {},
    ['POST'] = {},

}

function AddRoute(path, method, handlerFunc) -- simpliest thing on earth
    if Routes[method] then
        Routes[method][path] = handlerFunc
    end
end

function RemoveRoute(path, method) -- simpliest thing on earth
    if Routes[method] then
        Routes[method][path] = nil
    end
end


-- Routes 
AddRoute('/404', 'GET', function(data, parsedUrl, parsedqs)
    local res = data.res
    res:finish(json.encode({error = 'Not Found'}))
end)

AddRoute('/get', 'GET', function(data, parsedUrl, parsedqs)
    local res = data.res
    local apikey = parsedqs.apikey
    local dsname = parsedqs.dsname
    local dskey = parsedqs.dskey

    print('Get Key Request:')
    print(' Key: '.. (apikey and apikey or 'No Api Key Provided'))
    print(' Datastore: '.. (dsname and dsname or 'No Datastore Name Provided'))
    print(' Key: '.. (dskey and dskey or 'No Key Provided'))
    print('\n')

    if not apikey then
        res:finish(json.encode({error = 'No api key provided'}))
        print('No api key provided')
        return

    elseif not Db.data.keys[apikey] then
        res:finish(json.encode({error = 'Invalid Key'}))
        print('Invalid Key')
        return

    end

    if not Db.data.datastores then Db.data.datastores = {} end
    if not Db.data.datastores[apikey] then Db.data.datastores[apikey] = {} end
    if not Db.data.datastores[apikey][dsname] then Db.data.datastores[apikey][dsname] = {} end

    local key = Db.data.datastores[apikey][dsname][dskey]
    res:finish(json.encode({data = key}))
    return
end)

AddRoute('/set', 'POST', function(data, parsedUrl, parsedqs, body)
    local res = data.res
    local apikey = parsedqs.apikey
    local dsname = parsedqs.dsname
    local dskey = parsedqs.dskey
    local body = body and json.decode(body)
    local data = body and body.data

    print('Set Key Request:')
    print(' Key: '.. (apikey and apikey or 'No Api Key Provided'))
    print(' Datastore: '.. (dsname and dsname or 'No Datastore Name Provided'))
    print(' Key: '.. (dskey and dskey or 'No Key Provided'))
    print('\n')



    if not apikey then
        res:finish(json.encode({error = 'No api key provided'}))
        print('No api key provided')
        return

    elseif not Db.data.keys[apikey] then
        res:finish(json.encode({error = 'Invalid Key'}))
        print('Invalid Key')
        return

    end

    if not Db.data.datastores then Db.data.datastores = {} end
    if not Db.data.datastores[apikey] then Db.data.datastores[apikey] = {} end
    if not Db.data.datastores[apikey][dsname] then Db.data.datastores[apikey][dsname] = {} end

    if data then
        Db.data.datastores[apikey][dsname][dskey] = data
        res:finish(json.encode({success = true}))
    end

    return
end)

AddRoute('/ping', 'GET', function(rs)
    rs.res:finish(json.encode({pong = true}))
end)


function Router.Handler(req, res)
    local ParsedUrl, parsedqs
    ParsedUrl = url.parse(req.url)
    ParsedQs = qs.parse(ParsedUrl.query) or {}
    local body = ""

    req:on('data', function (chunk)
        body = body .. chunk
    end)

    req:on('end', function ()
        print(ParsedUrl.pathname)
        local Handler = Routes[req.method:upper()][ParsedUrl.pathname]
        
        if Handler then
            Handler({req = req, res = res}, ParsedUrl, ParsedQs, body)
        else
            Routes['GET']['/404']({req = req, res = res})
        end
    end)

    

end

return Router