Bash = require('./bash.coffee')

module.exports = window.App = App = Ember.Application.create()

App.Bash = new Bash(App)

App.loaded = false
App.rendered = false

App.Router.map ->
  @resource('index', { path: '/' })

# SERVERS LIST STUFF
App.Servers = Ember.ArrayProxy.create
  list: []

# INDEX
App.IndexController = Ember.ObjectController.extend
  init: -> @set "content", App.Servers

App.IndexRoute = Ember.Route.extend
  render: ->
    setInterval getServersData, 3000
    @_super()

App.IndexView = Ember.View.extend
  didInsertElement: ->
    App.Bash.init() unless App.Bash.initialized

getServersData = ->
  $.ajax
    url: "/api/servers/list"
    context: document.body
  .done (data) =>
    App.Bash.setLoaded() unless App.loaded
    App.Servers.set "list", data.servers.sortBy("name")

