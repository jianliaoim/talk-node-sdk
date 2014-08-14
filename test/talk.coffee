should = require 'should'
talk = require '../'
_config = require './_config'
_data = require './_data'

describe 'Talk#Main', ->

  describe 'Discover', ->

    it 'should list the apis from the discover api', (done) ->

      talk.init(_config).discover (err, apis) ->
        (Object.keys(apis).length > 10).should.eql true
        apis.should.have.properties 'discover.index'
        done(err)

  describe 'Call', ->

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
