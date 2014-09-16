http = require 'http'

should = require 'should'
express = require 'express'
supertest = require 'supertest'

talk = require '../src/talk'
_config = require './_config'
_data = require './_data'

describe 'Talk#Main', ->

  describe 'client and call apis', ->

    _userId = '53be41be138556909068769f'
    token = '5e7f8ead-47fa-4256-9a27-4e2166cfcfac'
    _talk = talk(_config)

    it 'should list the apis from the discover api', (done) ->

      _talk.discover (err, apis) ->
        (Object.keys(apis).length > 1).should.eql true
        apis.should.have.properties 'discover.index'
        done(err)

    it 'should get an NO_PERMISSIONT error without authorization', (done) ->

      _talk.call 'user.readOne', _id: _userId, (err) ->
        should(err).not.eql null
        done()

    it 'should call the user.readOne with authorization', (done) ->

      authClient = _talk.auth(token)
      authClient.call 'user.readOne', _id: _userId, (err, user) ->
        user.should.have.properties 'name'
        done err

  describe 'service and listen for events', ->

    _talk = talk(_config)
    service = _talk.service()

    it 'should intialize the express server and call the api', (done) ->

      supertest(service.app).post('/').end (err, res) ->
        res.text.should.eql 'PONG'
        done err

    it 'should listen for the user.readOne event', (done) ->

      _talk.once 'user.readOne', (data) ->
        data.should.eql 'ok'
        done()

      supertest(service.app).post('/')
        .set "Content-Type": "application/json"
        .send JSON.stringify(event: 'user.readOne', data: 'ok')
        .end(->)

    it 'should listen for the wildcard * event', (done) ->

      _talk.once '*', (data) ->
        data.should.eql 'ok'
        done()

      supertest(service.app).post '/'
        .set "Content-Type": "application/json"
        .send JSON.stringify(event: 'user.readOne', data: 'ok')
        .end(->)
