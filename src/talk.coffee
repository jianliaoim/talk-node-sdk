logger = require('graceful-logger').format('medium')
_ = require 'lodash'

config = require './config'
api = require './api'

Client = require './client'
client = new Client

class Talk

  init: (_config = {}) ->
    config = _.extend config, _config
    api.fetch()
    this

  authClient: (token) -> new Client token

  call: -> client.call.apply client, arguments

talk = new Talk
talk.service = require './service'

module.exports = talk
