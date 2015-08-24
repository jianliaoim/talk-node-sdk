logger = require 'graceful-logger'
Promise = require 'bluebird'
request = Promise.promisify require('request')

config = require './config'

callDiscover = ->
  options =
    method: 'GET'
    url: config.apiHost + '/v2/discover'
    json: true

  request(options)

  .spread (res, body) ->
    if res.statusCode isnt 200
      err = new Error(body.message)
      err.code = body.code
      throw err
    return body

apiMapPromise = null

getApiMap = ->
  return apiMapPromise if apiMapPromise
  retryTimes = 0
  retryMaxTimes = 5
  retryInterval = 100

  _getApiMap = ->
    callDiscover()
    .catch (err) ->
      retryTimes += 1
      retryDuration = retryInterval * 2 ** retryTimes
      if retryTimes > retryMaxTimes
        throw new Error('could not fetch the api list from server')
      Promise
      .delay retryDuration
      .then _getApiMap

  apiMapPromise = _getApiMap()

class Client

  constructor: (@token = null) ->

  # Send request
  call: (apiKey, params = {}, callback) ->

    if typeof params is 'function'
      callback = params
      params = {}

    {token} = this

    getApiMap()

    .then (apiMap) ->

      throw new Error('no such api') unless apiMap[apiKey]

      {path, method} = apiMap[apiKey]

      url = config.apiHost + path.split('/').map((k)->
        return k unless k[0] is ':'
        k = k[1..]
        _k = params[k]
        delete params[k]
        return _k
      ).join('/')

      # Add authorization info
      params.appToken = config.appToken

      logger.info "send request: #{url}"

      method or= 'GET'

      headers = "Content-Type": "application/json"
      headers.Authorization = "token #{token}" if token

      options =
        method: method.toUpperCase()
        url: url
        headers: headers
        json: true
        timeout: 10000

      if options.method is 'GET'
        options.qs = params
      else
        options.body = params

      request options

    .spread (res, body = {}) ->
      if res.statusCode isnt 200
        err = new Error(body.message)
        err.code = body.code
        throw err
      return body

    .then (data) ->
      callback? null, data
      return data

    .catch callback

client = (token) -> new Client token

module.exports = client
