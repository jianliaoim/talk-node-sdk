{EventEmitter} = require 'events'
logger = require('graceful-logger').format('medium')

_ = require 'lodash'

config = require './config'
Client = require './client'
Service = require './service'

class Talk extends EventEmitter

  constructor: -> @_client = new Client

  # Talk service wait for the server call
  service: (app, options = {}) -> new Service(this, app, options)

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

talk = (_config = {}) ->
  config = _.extend config, _config
  return new Talk

module.exports = talk
