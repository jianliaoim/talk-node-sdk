{EventEmitter} = require 'events'

_ = require 'lodash'
async = require 'async'

config = require './config'
util = require './util'
apis = require './apis'

class Talk extends EventEmitter

  constructor: ->
    @token = null

  init: (_config = {}) ->
    config = _.extend config, _config
    return this

  # Subscribe for the webhook
  subscribe: ->

  # Get the supported api list
  discover: (callback = ->) ->
    discoverUrl = config.apiHost + '/v1/discover'
    util.request discoverUrl, 'get', (err, data) ->
      unless err?
        apis = _.extend apis, data
      callback err, data
    return this

  auth: (token) ->
    _talk = new Talk
    _talk.token = token
    return _talk

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

    url = config.apiHost + path.replace /\:(.*)?\/?/i, (m1, m2) ->
      _m2 = params[m2]
      delete params[m2]
      return _m2

    # Add authorization info
    params.token = @token if @token

    util.request url, method, params, callback

module.exports = new Talk
