_util = require 'util'
logger = require('graceful-logger').format('medium')

config = require './config'
api = require './api'

Client = require './client'
Worker = require './worker'
Service = require './service'

class Talk

  client = new Client()  # The default client without token of user

  init: (_config = {}) ->
    config = _util._extend config, _config
    api.fetch()
    this

  call: -> client.call.apply client, arguments

talk = new Talk

talk.service = Service
talk.worker = Worker
talk.client = Client

module.exports = talk
