{EventEmitter} = require 'events'
{json} = require 'body-parser'
logger = require 'graceful-logger'

class Service extends EventEmitter

  constructor: (@app, options = {}) ->
    {prefix} = options
    prefix or= '/'
    @app.use json()
    @app.post prefix, @_emit

  _emit: (req, res) =>
    {event, data} = req.body or {}
    res.json pong: 1

    return unless event

    logger.info "emit event: #{event}"

    @emit event, data
    @emit '*', data

service = (app, options = {}) -> new Service app, options

module.exports = service
