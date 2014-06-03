calmsoul = require('calmsoul')
Bash = require('./bash.coffee')

module.exports = window.App = App = Ember.Application.create()

App.Bash = new Bash(App)

App.loaded = false
App.rendered = false

App.Router.map ->
  @resource('index', { path: '/' })

# SERVERS LIST STUFF
App.RealmStatus = Ember.ArrayProxy.create
  servers: []

App.Server = Ember.Object.extend
  latencyWord: (->
    n = @get('latency')
    n = if n? then n + "ms" else "OFFLINE"
    return n
  ).property("latency")

App.ServerController = Ember.ObjectController.extend
  init: -> calmsoul.debug "App.ServerController::init ->"

App.ServersArray = Ember.ArrayProxy.extend
  init: ->
    @servers = Ember.A()
    @set("content", @servers)
    @_super()

  findServerIndex: (data) ->
    calmsoul.debug "findServerIndex"
    for server, index in @servers
      return index if server.id == data.id

  updateServerData: (data) ->
    calmsoul.debug "updateServerData"
    for server, index in data.servers
      serverIndex = @findServerIndex(server)
      calmsoul.debug " > #{serverIndex}"
      if serverIndex > -1
        # Found the server
        calmsoul.debug "Found the Server"
        @servers[serverIndex].setProperties(server)

      else
        # Can't locate the server
        calmsoul.debug "Can't locate the server"
        @servers.push(App.Server.create(server))

App.Servers = App.ServersArray.create()

App.ServersController = Ember.ArrayController.extend
  sortProperties: ['name']
  sortAscending: true
  itemController: "server"

# INDEX
App.IndexController = Ember.ObjectController.extend
  init: -> calmsoul.debug "IndexController::init()"

App.IndexRoute = Ember.Route.extend
  render: ->
    setInterval getServersData, 3000
    @_super()

App.IndexView = Ember.View.extend
  didInsertElement: ->
    App.Bash.init() unless App.Bash.initialized

getServersData = ->
  $.ajax
    url: "/api/servers"
    context: document.body
  .done (data) =>
    App.Bash.setLoaded() unless App.loaded
    App.Servers.updateServerData(data)

