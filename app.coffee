
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

app.get '/api/servers/list', (req, res) ->
  res.setHeader('Content-Type', 'application/json')
  servers = []
  for key, value of ping.servers
    servers.push value
  res.end(JSON.stringify(servers, null, 3))

module.exports = webserver

