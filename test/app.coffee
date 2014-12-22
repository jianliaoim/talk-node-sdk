app = module.exports

app.config =
  appToken: 'fa53d5a0-bfb9-11e3-9a30-337b04324e79'
  apiHost: 'http://localhost:7001'

app.fakeServer = ->
  express = require 'express'
  app = express()

  auth = (req, res, next) ->
    return next() if req.query?.token
    next new Error('NOT_LOGIN')

  app.listen 7001

  app.get '/v1/discover', (req, res) ->
    data =
      "discover.index":
        "path": "/v1/discover",
        "method": "get"
      "user.readOne":
        "path": "/v1/users/:_id",
        "method": "get"
      "ping":
        "path": "/v1/ping",
        "method": "get"
      "integration.batchread":
        "path": "/v1/integrations"
        "method": "get"
    res.json data

  app.get '/v1/ping', (req, res) ->
    res.json 'pong'

  app.get '/v1/users/:_id', [auth], (req, res) ->
    res.json name: 'lurenjia'

  app.get '/v1/integrations', (req, res) ->
    res.json [
      {
        "_id": "54533b3ac4cc9aa41acc3cf6",
        "token": "2.00abc",
        "notifications": {
          "mention": 1
        }
      },
      {
        "_id": "545334bdc4cc9aa41acc3ce7",
        "token": "2.00def",
        "notifications": {
          "mention": 1,
          "repost": 1
        }
      }
    ]

  # Error handler
  app.use (err, req, res, next) ->
    res.status(400).json code: 400, message: err.message
