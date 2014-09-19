express = require 'express'
json = require('body-parser').json
logger = require('graceful-logger')

class Service

  constructor: (@talk, @app, options = {}) ->
    @app or= express()
    {prefix} = options
    prefix or= '/'
    @app.use json()
    @app.post prefix, @emit

  emit: (req, res, next) =>
    {event, data} = req.body or {}
    res.end 'PONG'
    return unless event

    @talk.emit event, data
    @talk.emit '*', data

  listen: (port, callback = ->) ->
    @app.listen port, (err) ->
      logger.info "service listen on #{port}"
      callback err
    this

module.exports = Service
