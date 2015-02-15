http = require 'http'

should = require 'should'
express = require 'express'
supertest = require 'supertest'
Promise = require 'bluebird'

talk = require '../src/talk'

app = require './app'

describe 'Talk#Main', ->

  talk.init(app.config)

  describe 'retry connecting', ->

    it 'should work when api server is started after the client', (done) ->

      talk.call 'ping', (err, data) ->
        data.should.eql 'pong'
        done err

      setTimeout app.fakeServer, 500

  describe 'client and call apis', ->

    _userId = '53be41be138556909068769f'
    token = '5e7f8ead-47fa-4256-9a27-4e2166cfcfac'

    it 'should get an NO_PERMISSIONT error without authorization', (done) ->

      talk.call 'user.readOne', _id: _userId, (err) ->
        should(err).not.eql null
        done()

    it 'should call the user.readOne with authorization', (done) ->

      authClient = talk.client(token)
      authClient.call 'user.readOne', _id: _userId, (err, user) ->
        user.should.have.properties 'name'
        done err

  describe 'service and listen for events', ->

    exApp = express()  # Express application

    service = talk.service(exApp)

    it 'should intialize the express server and call the api', (done) ->

      supertest(exApp).post('/').end (err, res) ->
        res.text.should.eql '{"pong":1}'
        done err

    it 'should listen for the user.readOne event', (done) ->

      service.once 'user.readOne', (data) ->
        data.should.eql 'ok'
        done()

      supertest(exApp).post('/')
        .set "Content-Type": "application/json"
        .send JSON.stringify(event: 'user.readOne', data: 'ok')
        .end(->)

    it 'should listen for the wildcard * event', (done) ->

      service.once '*', (data) ->
        data.should.eql 'ok'
        done()

      supertest(exApp).post '/'
        .set "Content-Type": "application/json"
        .send JSON.stringify(event: 'user.readOne', data: 'ok')
        .end(->)

  describe 'worker and test for what he should do', ->

    @timeout 3000

    it 'should run the tasks every 100ms', (done) ->

      ticks = 0

      testTask = (task) ->
        worker.tasks.should.have.keys '2.00abc_mention', '2.00def_mention', '2.00def_repost'
        task.should.have.properties 'token', 'notification'
        if task.token is '2.00abc'
          task.notification.should.eql 'mention'

      worker = talk.worker
        interval: 100  # Execute task every 100 ms
        runner: (task) ->  # Task runner
          new Promise (resolve, reject) ->
            ticks += 1
            testTask task
            if ticks is 6  # Stop work after 2 * 3 times
              worker.stop()
              done()
            resolve()

      worker.run()

    it 'should execute the tasks each second by cron-like schedule', (done) ->

      ticks = 0

      textTask = (task) ->
        worker.tasks.should.have.keys ''

      worker = talk.worker
        cron: '* * * * * *'
        runner: (task) ->
          ticks += 1
          if ticks is 6
            worker.stop()
            done()

      worker.run()

    it 'should not bother the other tasks when a task crashed', (done) ->

      ticks = 0
      worker = talk.worker
        interval: 100
        runner: (task) ->
          num = ticks += 1
          new Promise (resolve, reject) ->
            setTimeout ->
              # The first task will crash
              return reject(new Error('something error')) if num is 1
              # The second task will also work
              if num is 2
                worker.stop()
                task.token.should.eql '2.00def'
                done()
            , 20 * num

      worker.run()

    it 'should send a error integration to server when task failed', (done) ->

      worker = talk.worker
        interval: 100
        maxErrorTimes: 1
        runner: (task) ->
          new Promise (resolve, reject) ->
            return reject(new Error('OMG, they killed kenny!')) if task.token is '2.00abc'
            resolve()

      app.test = (req, res) ->
        req.body.should.have.properties 'appToken', 'errorInfo'
        req.url.should.containEql '54533b3ac4cc9aa41acc3cf6'
        app.test = ->
        setTimeout ->
          # Should not have the invalid task
          worker.tasks.should.have.keys '2.00def_mention', '2.00def_repost'
          worker.stop()
          done()
        , 100

      worker.run()


