Talk-Node-Sdk
======

[![NPM version][npm-image]][npm-url]
[![Build Status][travis-image]][travis-url]
[![Talk topic][talk-image]][talk-url]

# Usage

```coffeescript
talk = require 'talk-node-sdk'
app = express()

config =
  clientId: 'xxxxxxx-eeee-11e3-9a30-337b04324e79'
  clientSecret: 'yyyyyy-ffff-gggg-hhhh-aaaaaaaaaaa'
  apiHost: 'http://localhost:7001'

token = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

talk.init(config).authClient(token)

# Use another client
client = talk.client(token)

```

# TODO

1. `talk.register` to register for the application
2. `talk.request` to request for the talk resource
3. `talk.subscribe` to listen for webhooks

# Events

- `*` listen to all event
- `message.create` message create event

# Apis

# ChangeLog

## 0.4.0
- add worker in sdk

## 0.3.0
- move event emitter to service
- reconnect the api server when the discover api failed

## 0.2.0

- bump to new version

## 0.1.1

- Use methods from `discover` api
- Add support for 'GET', 'PUT', 'POST', 'DELETE' methods
- Replace url params with the correct value

[npm-url]: https://npmjs.org/package/talk-node-sdk
[npm-image]: http://img.shields.io/npm/v/talk-node-sdk.svg

[travis-url]: https://travis-ci.org/teambition/talk-node-sdk
[travis-image]: http://img.shields.io/travis/teambition/talk-node-sdk.svg

[talk-url]: https://guest.talk.ai/rooms/9c81ff703b
[talk-image]: http://img.shields.io/badge/talk-node--sdk-blue.svg
