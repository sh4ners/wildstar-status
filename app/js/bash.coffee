
class Bash
  initialized: false
  loaded: false
  $bashEl: null

  constructor: (app) ->
    @App = app

  init: ->
    @initialized = true
    @$bashEl = $(".loading")
    @$bashEl.addClass("show")
    setTimeout @runBashProxy, 600

  showLine: (n, delay) ->
    setTimeout( =>
      @$bashEl.find(".line-#{n}").addClass("show")
    , delay)

  startTyping: ->
    $(".loading .typed").typed({
      strings: ["", "./wildstar-status -a list"],
      typeSpeed: 0,
      backDelay: 300
      callback: =>
        @$bashEl.find("#typed-cursor").addClass('hide')
        @showLine(2, 0).apply
    })

  setLoaded: ->
    @showLine(3, 0).apply
    @showLine(4, 100).apply
    setTimeout ( => @$bashEl.removeClass("show") ), 200
    setTimeout ( => @App.set("loaded", true) ), 1200

  runBashProxy: => @runBash()

  runBash: ->
    @showLine(1, 0)
    @startTyping()


module.exports = Bash