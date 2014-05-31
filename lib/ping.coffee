
# Net Ping
tcpp          = require("tcp-ping")
config        = require("config")
events        = require('events')
EventEmitter  = require('events').EventEmitter

serversConfig = config.Servers
base          = config.Base


class Ping extends EventEmitter
  servers: {}

  constructor: -> @scanKnownInterval()

  scanKnownInterval: ->
    @scanKnownProxy()
    callback = =>
      this.removeAllListeners("probing:complete", callback)
      setInterval @scanKnownProxy, 3000
    this.on "probing:complete", callback

  scanKnownProxy: => @scanKnown()

  probe: (server) ->
    status = "offline"
    tcpp.ping {adress: server.ip, port: server.port}, (error, data) =>

      unless server.name?
        name = "#{data.adress}:#{data.port}"
      else name = server.name
      msg = "[#{name}] "

      unless isNaN(data.avg)
        status = "online"

      msg += status

      if status == "online"
        msg += " - #{Math.round(data.avg)}ms"

      serverData = {
        name: server.name
        status: status
        type: server.type
        delay: Math.round(data.avg)
      }

      this.emit 'probed', name, serverData, msg

  scanKnown: ->
    console.log "\n### INITIALIZING KNOWN SCAN!!!\n"

    for key, server of serversConfig
      @probe(server)

    totalServers = (k for own k of serversConfig).length
    probeCount = 0

    handleProbe = (name, data, msg) =>
      console.log msg

      @servers[data.name] = data
      probeCount++
      if (probeCount == totalServers)

        # seriously, clean up the listener immediately!
        this.removeAllListeners('probed', handleProbe)
        console.log "KNOWN SCAN :: DONE"
        this.emit "probing:complete"

    this.on 'probed', handleProbe

  superScan: ->
    console.log "\n### INITIALIZING SUPER SCAN!!!\n"

    superServers = {}
    for i in [0..10]
      server = {}
      i = "0" + i if i < 10
      server.ip = base.ip + i
      for k in [0..10]
        k = "0" + k if k < 10
        server.port = base.port + k
        @probe(server)

    totalServers = superServers.length
    probeCount = 0

    this.on 'probed', (name, data, msg) =>
      console.log msg if (data.status == 'online')
      probeCount++
      if (probeCount == totalServers)
        console.log "KNOWN SCAN :: DONE"
        this.emit "probing:complete"

    console.log "SS::DONE"



module.exports = new Ping()
