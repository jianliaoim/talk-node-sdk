request = require 'request'

exports.request = (url, method, params = {}, callback = ->) ->

  if toString.call(params) is '[object Function]'
    callback = params
    params = {}

  options =
    method: method.toUpperCase?() or 'GET'
    url: url

  options.headers = "Content-Type": "application/json"

  if options.method is 'GET'
    options.qs = params
  else
    options.body = JSON.stringify params

  options.timeout = 10000

  request options, (err, res, body) ->

    try
      body = JSON.parse body
    catch e
      body = {}

    if err? or res?.statusCode isnt 200
      err or= new Error(body.message)
      err.code or= body.code
      callback err
    else
      callback null, body
