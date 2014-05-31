module.exports = App = Ember.Application.create()

App.Router.map ->
  this.resource('index', { path: '/' })

App.Servers = Ember.Object.create
  list: []

App.IndexController = Ember.ObjectController.extend
  init: -> @set "content", App.Servers

App.IndexRoute = Ember.Route.extend
  render: ->
    @_super()
    init()

getData = ->
  $.ajax
    url: "/api/servers/list"
    context: document.body
  .done (data) =>
    servers = []
    for key, value of data
      servers.push value
    App.Servers.set "list", servers

init = -> setInterval( getData, 3000 )