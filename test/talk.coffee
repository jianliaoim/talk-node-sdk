http = require 'http'

should = require 'should'
express = require 'express'
supertest = require 'supertest'

talk = require '../'
_config = require './_config'
_data = require './_data'

describe 'Talk#Main', ->

  app = express()
  app.listen 3000

  describe 'discover', ->

    it 'should list the apis from the discover api', (done) ->

      talk.init(_config).discover (err, apis) ->
        (Object.keys(apis).length > 1).should.eql true
        apis.should.have.properties 'discover.index'
        done(err)

  describe 'call', ->

    _userId = '53be41be138556909068769f'
    token = '5e7f8ead-47fa-4256-9a27-4e2166cfcfac'

    it 'should get an NO_PERMISSIONT error without authorization', (done) ->

      talk.call 'user.readOne', _id: _userId, (err) ->
        should(err).not.eql null
        done()

    it 'should call the user.readOne with authorization', (done) ->

      authClient = talk.auth(token)
      authClient.call 'user.readOne', _id: _userId, (err, user) ->
        user.should.have.properties 'name'
        done err

  describe 'server', ->

    it 'should intialize the express server and call the api', (done) ->
      talk.server app

      supertest(app).post('/').end (err, res) ->
        res.text.should.eql 'PONG'
        done err

  describe 'on', ->

    it 'should listen for the user.readOne event', (done) ->

      talk.once 'user.readOne', (data) ->
        data.should.have.properties 'user'
        done()

      supertest(app).post('/')
        .set "Content-Type": "application/json"
        .send JSON.stringify(event: 'user.readOne', user: 'ok')
        .end(->)

    it 'should listen for the wildcard * event', (done) ->

      talk.once '*', (data) ->
        data.should.have.properties 'user'
        done()

      supertest(app).post '/'
        .set "Content-Type": "application/json"
        .send JSON.stringify(event: 'user.readOne', user: 'ok')
        .end(->)
