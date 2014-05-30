
# Net Ping
tcpp = require("tcp-ping")
config = require("config")
servers = config.Servers
base = config.Base

probe = (server) ->
  status = "offline"
  tcpp.ping {adress: server.ip, port: server.port}, (error, data) ->

    unless server.name?
      name = "{ip: #{data.adress}, port: #{data.port}}"
    else name = server.name
    msg = "[#{name}] "

    unless isNaN(data.avg)
      status = "online"

    msg += status

    if status == "online"
      msg += " - #{Math.round(data.avg)}ms"

    console.log "#{msg}"

scanKnown = ->
  console.log "\n### INITIALIZING KNOWN SCAN!!!\n"

  for key, server of servers
    probe(server)

superScan = ->

  console.log "\n### INITIALIZING SUPER SCAN!!!\n"

  for i in [0..10]
    server = {}
    i = "0" + i if i < 10
    server.ip = base.ip + i
    for k in [0..10]
      k = "0" + k if k < 10
      server.port = base.port + k
      probe(server)

scanKnown()
superScan()
