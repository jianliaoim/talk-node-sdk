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
    talk.discover 'v1', (err, client) ->
      data.client = client
      client.should.have.properties('oauth')
      client.oauth.should.have.properties('traceToken')
      talk.client.should.not.eql(null)
      (talk.expire > Date.now()).should.eql(true)
      done()

describe 'Talk#Client', ->

  # Get token of user
  describe 'Client#Oauth#TraceToken', ->

    it 'should get the token infomation back', (done) ->
      params = traceId: data.traceId
      data.client.oauth.traceToken.exec params, (err, token) ->
        token.should.have.properties('accessToken', 'refreshToken')
        data.accessToken = token.accessToken
        done(err)

  # Test GET method
  describe 'Client#User#ReadOne', ->

    it 'should get info of myself', (done) ->
      params =
        accessToken: data.accessToken
        _id: 'me'
      data.client.user.readOne.exec params, (err, user) ->
        user.should.have.properties('name', '_id', 'created', 'updated')
        data._userId = user._id
        done(err)

  # Test PUT method
  describe 'Client#User#Update', ->

    it 'should update user info', (done) ->
      params =
        accessToken: data.accessToken
        _id: data._userId
        name: 'xjx'
      data.client.user.update.exec params, (err, user) ->
        user.should.have.properties('name', '_id', 'created', 'updated')
        user.name.should.eql('xjx')
        done(err)
