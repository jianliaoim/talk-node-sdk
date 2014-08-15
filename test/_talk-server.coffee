# Fake talk server

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
