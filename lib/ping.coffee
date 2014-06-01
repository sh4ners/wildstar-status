
# Net Ping
tcpp          = require("tcp-ping")
colors        = require('colors')
config        = require("config")
events        = require('events')
EventEmitter  = require('events').EventEmitter

serversConfig = config.servers


base =
  ip: "64.25.34.2"
  port: 240


class Ping extends EventEmitter
  servers: []
  realmstatus: null
  services:
    "naauth": null
    "euauth": null
    "http": null
    "forums": null


  constructor: -> @scanKnownInterval()

  scanKnownInterval: ->
    @getServerData()
    callback = =>
      this.removeAllListeners("probing:complete", callback)
      setInterval @getServerData, 3000
    this.on "probing:complete", callback

  getServerData: => @scanKnown()

  findServerIndex: (data) ->
    for server, index in @servers
      return index if server.id == data.id

  updateServerData: (data) ->
    serverIndex = @findServerIndex(data)
    if serverIndex > -1
      # Found the server
      @servers[serverIndex] = data

    else
      # Can't locate the server
      @servers.push data



  probe: (server) ->
    status = "offline"
    tcpp.ping {adress: server.ip, port: server.port}, (error, data) =>

      status = "online" unless isNaN(data.avg)
      latency = null
      latency = Math.round(data.avg) if status == "online"

      speed = null
      if (latency <= 100) then speed = "fast"
      else if (latency > 100) then speed = "medium"
      else if (latency < 300) then speed = "slow"

      serverData = {
        id: server.id
        name: server.name
        status: status
        location: server.location
        type: server.type
        latency: latency
        speed: speed
      }

      this.emit 'probed', serverData

  scanKnown: ->
    state = "INITIALIZING".red
    console.log "\n# ***************************************\n  <#{state}> SCANNING KNOWN SERVERS".white

    for key, server of serversConfig
      @probe(server)

    totalServers = (k for own k of serversConfig).length
    probeCount = 0

    handleProbe = (data) =>
      # console.log msg
      @updateServerData(data)

      probeCount++
      if (probeCount == totalServers)

        # seriously, clean up the listener immediately!
        this.removeAllListeners('probed', handleProbe)
        this.emit "probing:complete"

        state = "RESULT".red
        console.log "\n  :: <#{state}> LISTING KNOWN SERVERS\n".white
        for server in @servers
          @logServer(server)

        state = "EXECUTED".red
        console.log "\n  <#{state}> KNOWN SERVERS SCANNED\n# ***************************************\n".white

    this.on 'probed', handleProbe

  logServer: (server) ->

    colors.setTheme(
      online: 'white'
      offline: 'grey'
      fast: 'green'
      medium: 'yellow'
      slow: 'red'
    )

    msg = {}
    msg.namePrefix = "    > [".grey
    msg.nameSuffix = "]".grey
    msgSpeed = if (server.speed) then server.speed else "white"

    msg.name = "#{server.name}"[server.status]
    msg.latency = " #{server.latency}ms"[msgSpeed]
    msg.location = "#{server.location}, ".grey
    msg.type = "#{server.type}".grey

    console.log msg.namePrefix + msg.name + msg.nameSuffix + msg.latency + " (".grey + msg.location + msg.type + ")".grey



  getRealmStatus: ->



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

    this.on 'probed', (data) =>
      console.log data if (data.status == 'online')
      probeCount++
      if (probeCount == totalServers)
        console.log "KNOWN SCAN :: DONE"
        this.emit "probing:complete"

    console.log "SS::DONE"



module.exports = new Ping()
