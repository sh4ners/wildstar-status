
# Net Ping
tcpp         = require("tcp-ping")
config       = require("config")
events       = require('events')
EventEmitter = require('events').EventEmitter

servers      = config.Servers
base         = config.Base


class Ping extends EventEmitter
  servers: {}

  constructor: -> return

  probe: (server) ->
    server.status = "offline"
    tcpp.ping {adress: server.ip, port: server.port}, (error, data) =>

      unless server.name?
        name = "#{data.adress}:#{data.port}"
      else name = server.name
      msg = "[#{name}] "

      unless isNaN(data.avg)
        server.status = "online"

      msg += server.status

      if server.status == "online"
        msg += " - #{Math.round(data.avg)}ms"

      console.log "#{msg}"
      serverData = {
        name: server.name
        status: server.status
        type: server.type
      }
      @servers[name] = serverData
      this.emit 'probed'

  scanKnown: ->
    console.log "\n### INITIALIZING KNOWN SCAN!!!\n"

    for key, server of servers
      @probe(server)

    totalServers = (k for own k of servers).length
    probeCount = 0

    this.on 'probed', =>
      probeCount++
      if (probeCount == totalServers)
        console.log "KNOWN SCAN :: DONE"
        this.emit "probing:complete"

  superScan: ->
    console.log "\n### INITIALIZING SUPER SCAN!!!\n"

    for i in [0..10]
      server = {}
      i = "0" + i if i < 10
      server.ip = base.ip + i
      for k in [0..10]
        k = "0" + k if k < 10
        server.port = base.port + k
        @probe(server)

    console.log "SS::DONE"



module.exports = new Ping()