{EventEmitter} = require 'events'

_ = require 'lodash'

config = require './config'
server = require './server'
Client = require './client'

class Talk extends EventEmitter

  constructor: ->
    @client = new Client

  init: (_config = {}) ->
    config = _.extend config, _config
    return this

  # Use express server instance
  # @param {Object} app
  # @param {Object} options
  useServer: (app, options = {}) ->
    server.initialHandler app, options

  auth: (token) ->
    client = new Client token
    return client

  discover: -> @client.discover.apply @client, arguments

  call: -> @client.call.apply @client, arguments

module.exports = new Talk
