{EventEmitter} = require 'events'
express = require 'express'
json = require('body-parser').json
logger = require('graceful-logger')

class Service extends EventEmitter

  constructor: (@app, options = {}) ->
    @app or= express()
    {prefix} = options
    prefix or= '/'
    @app.use json()
    @app.post prefix, @_emit

  _emit: (req, res, next) =>
    {event, data} = req.body or {}
    res.end 'PONG'
    return unless event

    logger.info "emit event: #{event}"

    @emit event, data
    @emit '*', data

  listen: (port, callback = ->) ->
    @app.listen port, (err) ->
      logger.info "service listen on #{port}"
      callback err
    this

service = (app, options = {}) ->
  return new Service app, options

module.exports = service
