request = require 'request'
_ = require 'lodash'

util =
  request: (options = {}, callback = ->) ->
    request options, (err, res, result) ->
      return callback(err) if err? or not result?
      try
        result = JSON.parse(result)
      catch e
        result = {}
      callback(err, result)

module.exports = util
