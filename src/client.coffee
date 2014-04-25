_ = require 'lodash'
util = require './util'
path = require 'path'

# map =
#   'oauth.traceToken':
#     method: 'get'
#     path: '/v1/oauth/tracetoken'
#     has: ['traceId']

class Client

  constructor: (@options) ->
    {apiHost, clientId, clientSecret, map} = @options

    _.keys(map).forEach (key) =>

      # Define caller object
      caller = {}
      _map = map[key]
      caller.exec = (params, callback = ->) ->
        params.clientId = clientId
        params.clientSecret = clientSecret

        # Make sure these params
        has = []
        if matches = _map.path.match /\:[a-z_-]+/ig
          has = has.concat(matches.map (str) -> str[1..])

        if _map.has?.length > 1
          has = has.concat(_map.has)

        if has.length > 1
          has.unshift(params)
          unless _.has.apply(_, has)
            return callback(new Error("MISS PARAM #{params.join(_map.has)}"))

        # Replace in url params
        _path = _map.path.replace /\:[a-z_-]+/ig, (code) ->
          val = params[code[1..]]
          delete params[code[1..]]
          return val

        _map.method = _map.method.toUpperCase()

        reqOptions =
          method: _map.method
          uri: apiHost + _path

        switch _map.method
          when 'GET'
            reqOptions.qs = params
          else
            reqOptions.headers = "Content-Type": "application/json"
            reqOptions.body = JSON.stringify(params)
        util.request(reqOptions, callback)

      # Bind keys to caller chains
      keys = key.split('.')
      if keys.length is 1
        Object.defineProperty this, key, get: -> caller
      else if keys.length is 2
        this[keys[0]] = {} unless this[keys[0]]
        Object.defineProperty this[keys[0]], keys[1], get: -> caller

module.exports = Client
