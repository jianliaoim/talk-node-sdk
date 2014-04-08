should = require 'should'
config = require './config'
talk = require '../'

describe 'Talk#Init', ->

  it 'should get init object of talk', ->
    talk = talk.auth(config.accessKey, config.secretKey)
    should(talk.options).have.properties('accessKey', 'secretKey')

describe 'Talk#UserToken', ->

  it 'should get token of the specific id', ->

