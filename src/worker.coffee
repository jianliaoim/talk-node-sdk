{EventEmitter} = require 'events'
Promise = require 'bluebird'
logger = require 'graceful-logger'
_util = require 'util'

class Worker extends EventEmitter

  # The default handler for convert integrations to task
  _addTasks = (integration) ->
    {token, notifications, url} = integration
    {tasks} = this
    # Integration based on token and notifications. e.g. weibo/firim
    # These integration requests are made by a pair of token and notification event
    if token and notifications
      Object.keys(notifications).forEach (notification) ->
        taskKey = "#{token}_#{notification}"
        tasks[taskKey] or=
          notification: notification
          token: token
          integrations: {}
        tasks[taskKey].integrations[integration._id] = integration
    # Integration based on open url such as rss feed
    # These integration make request with a stable url
    else if url
      taskKey = url.trim()
      tasks[taskKey] or=
        url: taskKey
        integrations: {}
      tasks[taskKey].integrations[integration._id] = integration

  _removeTasks = (integration) ->
    {_id} = integration
    return unless _id
    {tasks} = this
    Object.keys(tasks).forEach (taskKey) ->
      task = tasks[taskKey]
      delete task.integrations[_id]
      delete tasks[taskKey] unless Object.keys(task.integrations).length

  constructor: (options = {}) ->
    @tasks = {}
    @fetchTasks()
    @bindEvents()
    @options =
      interval: 300000  # 5 minutes
    _util._extend @options, options

  fetchTasks: ->
    retryMaxTimes = 3
    retryInterval = 100
    talk = require './talk'
    self = this

    Promise.reduce [retryMaxTimes..0], (integrations, current, times) ->
      return integrations if integrations
      throw new Error('retry time out') if current is 0
      retryTime = retryInterval * 2 ** times
      Promise.delay retryTime
      .then ->
        talk.call 'integration.batchread', (err, integrations) ->
          if err then null else integrations
    , null

    .then (integrations = []) ->
      integrations.forEach (integration) ->
        self.emit 'integration.create', integration

    .catch logger.warn

  bindEvents: ->
    self = this
    @on 'integration.create', (integration) ->
      self.addTasks integration
    @on 'integration.update', (integration) ->
      self.removeTasks integration
      self.addTasks integration
    @on 'integration.remove', (integration) ->
      self.removeTasks integration

  run: ->
    {interval} = @options
    self = this
    @runOnce()
    .timeout interval  # Kill the current task loop when execute time greater than interval
    .catch logger.warn
    .then -> Promise.delay interval
    .then -> self.run()

  runOnce: ->
    self = this
    {runner} = @options
    Promise.each Object.keys(tasks), (key) ->
      task = tasks[key]
      self.emit 'execute', task
      Promise.promisify(runner) task if typeof runner is 'function'

  addTasks: (integration) ->
    {addTasks} = @options
    addTasks or= _addTasks
    addTasks.call this, integration

  removeTasks: (integration) ->
    {removeTasks} = @options
    removeTasks or= _removeTasks
    removeTasks.call this, integration

  # Watch service events
  watch: (service) ->
    self = this
    service.on 'integration.create', (integration) ->
      self.emit 'integration.create', integration
    service.on 'integration.update', (integration) ->
      self.emit 'integration.update', integration
    service.on 'integration.remove', (integration) ->
      self.emit 'integration.remove', integration
    this

worker = -> new Worker

module.exports = worker
