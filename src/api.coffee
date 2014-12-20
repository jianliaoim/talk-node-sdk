_util = require 'util'
async = require 'async'
util = require './util'
config = require './config'

apiMap = {}

retryTimes = 0
# Max waiting times
maxRetryTimeout = 60000

api =
  ready: false

  fetch: (callback = ->) ->
    return callback(null, apiMap) if api.ready
    api.refresh (err, apiMap) ->
      if err?
        retryTimes += 1
        retryTimeout = 100 * 2 ** retryTimes
        return callback(err) if retryTimeout > maxRetryTimeout
        setTimeout ->
          api.fetch callback
        , retryTimeout
      else
        retryTimes = 0
        callback err, apiMap

  refresh: (callback = ->) ->
    discoverUrl = config.apiHost + '/v1/discover'
    util.request discoverUrl, 'get', (err, data = {}) ->
      unless err?
        apiMap = _util._extend apiMap, data
        api.ready = true
      callback err, apiMap

  list: (callback = ->) ->
    beginAt = Date.now()
    async.until(
      -> api.ready
    , (callback) ->
      return callback(new Error('could not fetch the api list from server')) if (Date.now() - beginAt) > maxRetryTimeout
      setTimeout callback, 100
    , (err) -> callback err, apiMap
    )

module.exports = api
