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
  servers: Ember.A()


App.Server = Ember.Object.extend
  latencyWord: (->
    n = @get('latency')
    n = if n? then n + "ms" else "OFFLINE"
    return n
  ).property("latency")

App.ServerController = Ember.ObjectController.extend
  init: -> calmsoul.debug "App.ServerController::init ->"

App.ServersObjectProxy = Ember.ObjectProxy.extend
  init: ->
    @servers = Ember.Object.create()
    @set("content", App.RealmStatus)
    @_super()


  filterAndUpdateServers:  ->
    na = App.RealmStatus.servers.filterBy("location", "na").sortBy("name")
    eu = App.RealmStatus.servers.filterBy("location", "eu").sortBy("name")
    @servers.set "NA", na
    @servers.set "EU", eu


  findServerIndex: (data) ->
    calmsoul.debug "findServerIndex"
    for server, index in App.RealmStatus.servers
      return index if server.id == data.id

  updateServerData: (data) ->
    calmsoul.debug "updateServerData"
    for server, index in data.servers
      serverIndex = @findServerIndex(server)
      calmsoul.debug " > #{serverIndex}"
      if serverIndex > -1
        # Found the server
        calmsoul.debug "Found the Server"
        App.RealmStatus.servers[serverIndex].setProperties(server)

      else
        # Can't locate the server
        calmsoul.debug "Can't locate the server"
        App.RealmStatus.servers.push(App.Server.create(server))

    @filterAndUpdateServers()

App.Servers = App.ServersObjectProxy.create()



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

