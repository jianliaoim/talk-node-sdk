http = require 'http'

should = require 'should'
express = require 'express'
supertest = require 'supertest'

talk = require '../src/talk'

predict = require './predict'

before predict.fakeServer

describe 'Talk#Main', ->

  describe 'client and call apis', ->

    _userId = '53be41be138556909068769f'
    token = '5e7f8ead-47fa-4256-9a27-4e2166cfcfac'
    talk.init(predict.config)

    it 'should get an NO_PERMISSIONT error without authorization', (done) ->

      talk.call 'user.readOne', _id: _userId, (err) ->
        should(err).not.eql null
        done()

    it 'should call the user.readOne with authorization', (done) ->

      authClient = talk.authClient(token)
      authClient.call 'user.readOne', _id: _userId, (err, user) ->
        user.should.have.properties 'name'
        done err

  describe 'service and listen for events', ->

    service = talk.service()

    it 'should intialize the express server and call the api', (done) ->

      supertest(service.app).post('/').end (err, res) ->
        res.text.should.eql 'PONG'
        done err

    it 'should listen for the user.readOne event', (done) ->

      service.once 'user.readOne', (data) ->
        data.should.eql 'ok'
        done()

      supertest(service.app).post('/')
        .set "Content-Type": "application/json"
        .send JSON.stringify(event: 'user.readOne', data: 'ok')
        .end(->)

    it 'should listen for the wildcard * event', (done) ->

      service.once '*', (data) ->
        data.should.eql 'ok'
        done()

      supertest(service.app).post '/'
        .set "Content-Type": "application/json"
        .send JSON.stringify(event: 'user.readOne', data: 'ok')
        .end(->)
