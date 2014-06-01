Bash = require('./bash.coffee')

s = skrollr.init
  smoothScrolling: false

module.exports = window.App = App = Ember.Application.create()

App.Bash = new Bash(App)

App.loaded = false
App.rendered = false

App.Router.map ->
  this.resource('index', { path: '/' })


# SERVERS LIST STUFF
App.Servers = Ember.Object.create
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
    s.refresh()
    App.Bash.setLoaded() unless App.loaded
    App.Servers.set "list", data.servers


$ -> s.refresh()