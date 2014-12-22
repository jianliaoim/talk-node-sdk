_util = require 'util'
logger = require('graceful-logger').format('medium')

config = require './config'

class Talk

  init: (_config = {}) ->
    config = _util._extend config, _config

    @client = require './client'
    @worker = require './worker'
    @service = require './service'

    @_client = @client()  # The default client without token of user
    this

  call: -> @_client.call.apply @_client, arguments

talk = new Talk

module.exports = talk
