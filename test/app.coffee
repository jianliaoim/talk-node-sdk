express = require 'express'
{json} = require 'body-parser'

module.exports = app = express()

app.config =
  appToken: 'fa53d5a0-bfb9-11e3-9a30-337b04324e79'
  apiHost: 'http://localhost:7001'

app.fakeServer = ->
  auth = (req, res, next) ->
    return next() if req.headers?.authorization
    next new Error('not login')

  app.listen 7001

  app.use json()

  app.get '/v2/discover', (req, res) ->
    data =
      "discover.index":
        "path": "/v2/discover",
        "method": "get"
      "user.readOne":
        "path": "/v2/users/:_id",
        "method": "get"
      "ping":
        "path": "/v2/ping",
        "method": "get"
      "integration.batchread":
        "path": "/v2/integrations"
        "method": "get"
      "integration.error":
        "path": "/v2/integrations/:_id/error"
        "method": "post"
    res.json data

  app.get '/v2/ping', (req, res) ->
    res.json 'pong'

  app.get '/v2/users/:_id', [auth], (req, res) ->
    res.json name: 'lurenjia'

  app.get '/v2/integrations', (req, res) ->
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

  app.post '/v2/integrations/:_id/error', (req, res) ->
    app.test req, res
    res.json ok: 1

  # Error handler
  app.use (err, req, res, next) ->
    res.status(400).json code: 400, message: err.message

app.test = ->
