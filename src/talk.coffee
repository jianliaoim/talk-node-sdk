{EventEmitter} = require 'events'

_ = require 'lodash'

config = require './config'
server = require './server'
Client = require './client'

class Talk extends EventEmitter

  constructor: ->
    @_client = new Client

  init: (_config = {}) ->
    config = _.extend config, _config
    return this

  # Use express server instance
  # @param {Object} app
  # @param {Object} options
  server: (app, options = {}) ->
    server.initialHandler app, options
    return this

  client: (token) -> new Client token

  auth: ->
    @_client.auth.apply @_client, arguments
    return this

  discover: ->
    @_client.discover.apply @_client, arguments
    return this

  call: ->
    @_client.call.apply @_client, arguments
    return this

module.exports = new Talk
