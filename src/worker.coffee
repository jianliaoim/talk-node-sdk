Promise = require 'bluebird'

_loadMetaMap = ->

  Promise.reduce [0...3], (total, cur) ->
    throw new Error('retry time out') if cur is 3
  , 0

  # talk = require './talk'
  # retryMaxTimes -= 1

class Worker

  Portal: class Portal

  init: ->
    new Promise (resolve, reject) ->

  run: (callback = ->) ->

  timer: (interval = 60000) ->
    self = this
    @run ->
      setTimeout ->
        self.timer(interval)
      , interval
    this

module.exports = Worker
