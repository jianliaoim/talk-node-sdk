_ = require 'lodash'
async = require 'async'

apis = require './apis'
util = require './util'
config = require './config'

class Client

  constructor: (@token = null) ->

  auth: (@token) -> this

  # Get the supported api list
  discover: (callback = ->) ->
    discoverUrl = config.apiHost + '/v1/discover'
    util.request discoverUrl, 'get', (err, data) ->
      unless err?
        apis = _.extend apis, data
      callback err, data
    return this

  # Send request
  call: (api, params, callback = ->) ->
    # Try discover the apis first
    if _.isEmpty(apis)
      return async.waterfall [
        (next) =>
          @discover next
        (apis, next) =>
          @call api, params, next
      ], callback

    return callback(new Error('NO_SUCH_API')) unless apis[api]?

    {path, method} = apis[api]

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

    util.request url, method, params, callback

module.exports = Client
