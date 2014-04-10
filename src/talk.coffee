_ = require 'lodash'
request = require 'request'
config = require './config'
Client = require './client'
util = require './util'

class Talk

  constructor: (options = {}) ->
    @init(options)

  init: (options) ->
    @options = _.extend(_.clone(config), options)
    return this

  discover: (version = 'v1', callback = ->) ->
    client = new Client(@options)
    callback(null, client)

talk = new Talk
talk.Talk = Talk
module.exports = talk
