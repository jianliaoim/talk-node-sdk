predict = module.exports

predict.config =
  appToken: 'fa53d5a0-bfb9-11e3-9a30-337b04324e79'
  apiHost: 'http://localhost:7001'

predict.fakeServer = ->
  express = require 'express'
  app = express()

  auth = (req, res, next) ->
    return next() if req.query?.token
    next new Error('NOT_LOGIN')

  app.listen 7001

  app.get '/v1/discover', (req, res) ->
    data = {"user.readOne":{"path":"/v1/users/:_id","method":"get"}, "discover.index":{"path":"/v1/discover","method":"get"}}
    res.json data

  app.get '/v1/users/:_id', [auth], (req, res) ->
    res.json name: 'lurenjia'

  app.use (err, req, res, next) ->
    res.status(400).json
      code: 400
      message: err.message
