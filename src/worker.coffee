{EventEmitter} = require 'events'
Promise = require 'bluebird'
logger = require 'graceful-logger'
{CronJob} = require 'cron'
_util = require 'util'

class Worker extends EventEmitter

  constructor: (options = {}) ->
    @tasks = {}
    @fetchTasksPromise = @fetchTasks()
    @bindEvents()
    @options =
      interval: 300000  # 5 minutes
      concurrency: 2
      maxErrorTimes: 10
      taskInterval: 1000  # Sleep between each task
    _util._extend @options, options

    {addTasks, removeTasks} = @options
    @addTasks = addTasks if typeof addTasks is 'function'
    @removeTasks = removeTasks if typeof removeTasks is 'function'

  fetchTasks: ->
    retryTimes = 0
    retryMaxTimes = 3
    retryInterval = 100
    talk = require './talk'
    self = this

    _fetchTasks = ->
      talk.call 'integration.batchread'
      .catch (err) ->
        retryTimes += 1
        retryDuration = retryInterval * 2 ** retryTimes
        if retryTimes > retryMaxTimes
          throw new Error('could not fetch the integration list from server')
        Promise.delay retryDuration
        .then _fetchTasks

    _fetchTasks()
    .then (integrations = []) ->
      integrations.forEach (integration) ->
        self.emit 'integration.create', integration

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
    return if @isStopped
    return @runCron() if @options.cron
    {interval} = @options
    self = this
    @fetchTasksPromise
    .then -> self.runOnce()
    .timeout interval  # Kill the current task loop when execute time greater than interval
    .catch (err) -> logger.warn err.stack
    .then -> Promise.delay interval
    .then -> self.run()

  ###*
   * Execute the tasks by cron-like schedule
   * @return {[type]} [description]
  ###
  runCron: ->
    {cron} = @options
    @cronJob = new CronJob
      cronTime: cron
      onTick: @runOnce
      start: true

  runOnce: =>
    self = this
    {runner, concurrency, maxErrorTimes, taskInterval} = @options
    {tasks} = this
    talk = require './talk'
    Promise.map Object.keys(tasks), (key) ->
      task = tasks[key]
      unless task and typeof(runner) is 'function'
        delete tasks[key]
        return false

      Promise.resolve()

      .then -> runner task

      .then -> task.errorTimes = 0

      .catch (err) ->
        # Handle error integration
        logger.warn err.stack
        task.errorTimes = (task.errorTimes or 0) + 1
        return unless task.errorTimes >= maxErrorTimes

        {integrations} = task
        _sendIntegrationError = (ikey) ->
          integration = integrations[ikey]
          talk.call 'integration.error',
            _id: integration._id
            errorInfo: err.message
          .then ->
            self.emit 'integration.remove', integration
          .catch (err) -> logger.warn err.stack

        Object.keys(integrations).forEach _sendIntegrationError

      .delay taskInterval

    , concurrency: concurrency

  stop: ->
    @isStopped = true
    @cronJob?.stop()

  # The default handler for convert integrations to task
  addTasks: (integration) ->
    {token, events, url} = integration
    {tasks} = this
    # Integration based on token and events. e.g. weibo/firim
    # These integration requests are made by a pair of token and event
    if token and events?.length
      events.forEach (event) ->
        taskKey = "#{token}_#{event}"
        tasks[taskKey] or=
          event: event
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

  removeTasks: (integration) ->
    {_id} = integration
    return unless _id
    {tasks} = this
    Object.keys(tasks).forEach (taskKey) ->
      task = tasks[taskKey]
      delete task.integrations[_id]
      delete tasks[taskKey] unless Object.keys(task.integrations).length

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

worker = (options) -> new Worker options

module.exports = worker
