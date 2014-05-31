
skrollr = require('../../bower_components/skrollr/dist/skrollr.min.js')
s = skrollr.init
  smoothScrolling: false

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
    setInterval getData, 3000
    console.log "loaded"

getData = ->
  $.ajax
    url: "/api/servers/list"
    context: document.body
  .done (data) =>
    App.Servers.set "list", data.servers
    s.refresh()

