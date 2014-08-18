Talk-Node-Sdk
======

# Usage

```coffeescript
talk = require 'talk-node-sdk'
app = express()

config =
  clientId: 'xxxxxxx-eeee-11e3-9a30-337b04324e79'
  clientSecret: 'yyyyyy-ffff-gggg-hhhh-aaaaaaaaaaa'
  apiHost: 'http://localhost:7001'

token = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

talk.init(config).server(app).auth(token).discover()

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

## 0.2.0

- bump to new version

## 0.1.1

- Use methods from `discover` api
- Add support for 'GET', 'PUT', 'POST', 'DELETE' methods
- Replace url params with the correct value
