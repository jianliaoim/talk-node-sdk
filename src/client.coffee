async = require 'async'
logger = require 'graceful-logger'

api = require './api'
util = require './util'
config = require './config'

class Client

  constructor: (@token = null) ->

  auth: (@token) -> this

  # Send request
  call: (apiKey, params, callback = ->) ->

    api.list (err, apiMap) =>

      if typeof params is 'function'
        callback = params
        params = {}

      return callback(err or new Error('NO_SUCH_API')) unless apiMap[apiKey]?

      {path, method} = apiMap[apiKey]

      url = config.apiHost + path.split('/').map((k)->
        return k unless k[0] is ':'
        k = k[1..]
        _k = params[k]
        delete params[k]
        return _k
        ).join('/')

      # Add authorization info
      params.token = @token if @token
      params.appToken = config.appToken

      logger.info "send request: #{url}"

      util.request url, method, params, callback

module.exports = Client
