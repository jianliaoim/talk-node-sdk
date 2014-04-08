_ = require 'lodash'
config = require './config'

class Talk

  constructor: (options = {}) ->
    @options = options

  auth: (accessKey, secretKey) ->
    @options.accessKey = accessKey
    @options.secretKey = secretKey
    this

  # Generate landing url of talk
  # @params token token of user
  # @params target
  landingUrl: (token, room) ->

talk = new Talk
talk.Talk = Talk
module.exports = talk
