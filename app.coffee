
http    = require('http')
express = require('express')
path    = require('path')
q       = require('q')
ping    = require('./lib/ping.coffee')

events  = require('events')
emitter = new events.EventEmitter()


app = express()
webserver = http.createServer(app)
basePath = path.join(__dirname)

app.engine('html', require('ejs').renderFile)

app.configure ->
  app.use('/assets', express.static(basePath + '/.generated/'))
  app.use('/vendor', express.static(basePath + '/bower_components/'))

port = process.env.PORT || 3002
webserver.listen(port)

app.get '/', (req, res) ->
  res.render(basePath + '/.generated/index.html')

app.get '/tyler', (req, res) ->
  res.render(basePath + '/.generated/tyler.html')

app.get '/api/servers', (req, res) ->
  res.setHeader('Content-Type', 'application/json')

  payload =
    realmstatus: null
    services:
      "naauth": null
      "euauth": null
      "http": null
      "forums": null
    servers: []

  for key, value of ping.servers
    payload.servers.push value
  res.end(JSON.stringify(payload, null, 3))

module.exports = webserver

