should = require 'should'
talk = require '../'
_config = require './_config'
_data = require './_data'

describe 'Talk#Init', ->

  it 'should get init object of talk', ->
    talk = talk.init(_config)
    should(talk.options).have.properties('clientId', 'clientSecret')

describe 'Talk#Discover', ->

  it 'should get the discovered client', (done) ->
    talk.discover 'v1', (err, client) ->
      _data.client = client
      console.log client.discover
      done()
