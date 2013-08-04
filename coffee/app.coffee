$ ->
  window.SAT = {}
  SAT.isLogged = false
  SAT.goBack = false
  SAT.currentView = 0
  SAT.history = []

  $('#app, #app2').bind 'webkitAnimationEnd', (e)->
    if ~['slideout', 'slideout-back'].indexOf e.originalEvent.animationName
      $out = $(@)
      $in = $("#app, #app2").filter(":not(##{$(@).attr('id')})")
      $out.empty()
      $in.css
        top: 0
  .bind 'webkitAnimationStart', (e)->
    if ~['slidein', 'slidein-back'].indexOf e.originalEvent.animationName
      $in = $(@)
      $in.css
        top: window.scrollY

  Backbone.history.bind 'route', ->
    if SAT.history.length > 1 and @getFragment() is SAT.history[-2..][0]
      SAT.history.pop()
      SAT.goBack = true
    else
      SAT.history.push @getFragment()

  class Backbone.AnimView extends Backbone.View
    switchEl: ->
      @$prev = Backbone.$(if SAT.currentView%2 then '#app' else '#app2')
      @$el = Backbone.$(if SAT.currentView%2 then '#app2' else '#app')
    setElement: ->
      super
      @switchEl()
      view = @
      setTimeout ->
        if SAT.currentView
          view.$prev.attr 'class', "slide-out #{if SAT.goBack then "slide-back" else ''}"
          view.$el.attr 'class', "slide-in #{if SAT.goBack then "slide-back" else ''}"
          SAT.goBack = false
        SAT.currentView++

  ### Models ###
  ### Collections ###
  ### Views ###
  class SAT.headerView extends Backbone.View
    el: '#app-header'
    template: _.template $('#tmpl-header').html()
    events:
      'click a.back': 'evt_back'
      'click a.notif': 'evt_notif'
      'click a.help': 'evt_help'
    evt_back: (e)->
      e.preventDefault()
      router.navigate SAT.history[-2..][0], true
    evt_notif: (e)->
      e.preventDefault()
    evt_help: (e)->
      e.preventDefault()
    render: ->
      @$el.html @template
      @

  class SAT.loginView extends Backbone.AnimView
    el: '#app'
    template: _.template $('#tmpl-login').html()
    events:
      'submit form#login': 'evt_login'
    evt_login: (e)->
      e.preventDefault()
      SAT.isLogged = true
      router.navigate '', true
    render: ->
      @$el.html @template
      @

  class SAT.indexView extends Backbone.AnimView
    el: '#app'
    template: _.template $('#tmpl-index').html()
    events:
      'click a': 'evt_menuitem'
    evt_menuitem: (e)->
      e.preventDefault()
      router.navigate $(e.currentTarget).attr('href'), true
    render: ->
      @$el.html @template
      @

  class SAT.citasView extends Backbone.AnimView
    el: '#app'
    template: _.template $('#tmpl-citas').html()
    render: ->
      @$el.html @template(url: window.location.hash)
      @

  ### Router ###
  class SAT.Router extends Backbone.Router
    routes:
      '': 'index'
      'login': 'login'
      'citas': 'citas'
      'pagos': 'citas'
      'notificaciones': 'citas'
      'ayuda': 'citas'
    index: ->
      return @navigate 'login', true unless SAT.isLogged
      indexview = new SAT.indexView
      indexview.render()

    login: ->
      loginview = new SAT.loginView
      loginview.render()

    citas: ->
      citasview = new SAT.citasView
      citasview.render()

  router = new SAT.Router
  Backbone.history.start()

  header = new SAT.headerView
  header.render()
