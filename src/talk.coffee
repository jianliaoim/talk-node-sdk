_util = require 'util'
logger = require('graceful-logger').format('medium')

config = require './config'
api = require './api'

Client = require './client'
client = new Client

class Talk

  init: (_config = {}) ->
    config = _util._extend config, _config
    api.fetch()
    this

  authClient: (token) -> new Client token

  call: -> client.call.apply client, arguments

talk = new Talk
talk.service = require './service'
talk.worker = require './worker'

module.exports = talk
