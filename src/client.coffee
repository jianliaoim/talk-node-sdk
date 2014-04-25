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
        if _map.has?.length > 1
          has = _.clone(_map.has)
          has.unshift(params)
          unless _.has.apply(_, has)
            return callback(new Error("MISS PARAM #{params.join(_map.has)}"))
        reqOptions =
          method: _map.method
          uri: apiHost + _map.path
          qs: params
        util.request(reqOptions, callback)

      # Bind keys to caller chains
      keys = key.split('.')
      if keys.length is 1
        Object.defineProperty this, key, get: -> caller
      else if keys.length is 2
        this[keys[0]] = {} unless this[keys[0]]
        Object.defineProperty this[keys[0]], keys[1], get: -> caller

module.exports = Client
