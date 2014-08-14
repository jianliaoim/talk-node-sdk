json = require('body-parser').json()

server = module.exports

server.response = (req, res) ->
  {event} = req.body or {}
  res.end 'PONG'
  return unless event

  talk = require './talk'
  talk.emit event, req.body
  talk.emit '*', req.body

server.initialHandler = (app, options = {}) ->
  server.app = app
  {prefix} = options
  prefix or= '/'
  app.post prefix, (req, res) ->
    if req.body then server.response(req, res) else json req, res, ->
      server.response req, res
  return server
