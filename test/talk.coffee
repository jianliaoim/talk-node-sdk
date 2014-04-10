should = require 'should'
config = require './config'
talk = require '../'
data = require './data'

describe 'Talk#Init', ->

  it 'should get init object of talk', ->
    talk = talk.init(config)
    should(talk.options).have.properties('clientId', 'clientSecret')

describe 'Talk#Discover', ->

  it 'should get the discovered client', (done) ->
    talk
    talk.discover 'v1', (err, client) ->
      data.client = client
      client.should.have.properties('oauth')
      client.oauth.should.have.properties('traceToken')
      done()

describe 'Talk#Client', ->

  describe 'Client#TraceToken', ->

    it 'should get the token infomation back', (done) ->
      params = traceId: data.traceId
      data.client.oauth.traceToken.exec params, (err, token) ->
        token.should.have.properties('accessToken', 'refreshToken')
        done()
