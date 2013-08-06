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
    history = SAT.history.get('history')
    return if history[-1..][0] is @getFragment()
    if history.length > 1 and @getFragment() is history[-2..][0]
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
  class SAT.historyModel extends Backbone.Model
    defaults:
      history: []
    pop: (el)->
      history = @get 'history'
      history.pop()
      @set 'history', history
      @trigger 'history:change', @
    push: (el)->
      history = @get 'history'
      history.push el
      @set 'history', history
      @trigger 'history:change', @

  ### Collections ###
  ### Views ###
  class SAT.headerView extends Backbone.View
    el: '#app-header'
    template: _.template $('#tmpl-header').html()
    events:
      'click a.back': 'evt_back'
      'click a.notif': 'evt_notif'
      'click a.help': 'evt_help'
    initialize: (ini)->
      @history = ini.history
      @listenTo @history, 'history:change', (h)->
        history = h.get('history')
        if history.length > 1
          @$el.prop 'class', 'has-history'
        else
          @$el.prop 'class', ''
    evt_back: (e)->
      e.preventDefault()
      history = SAT.history.get('history')
      router.navigate history[-2..][0], true
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
      setTimeout ->
        router.navigate '', true
      , 400
      SAT.history.set 'history', _.reject(SAT.history.get('history'), (h)-> h is 'login' )
      @$el.get(0).focus()
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
      @$el.html @template
      @

  class SAT.pagosView extends Backbone.AnimView
    el: '#app'
    template: _.template $('#tmpl-pagos').html()
    render: ->
      @$el.html @template
      @

  class SAT.feedbackView extends Backbone.AnimView
    el: '#app'
    template: _.template $('#tmpl-feedback').html()
    render: ->
      @$el.html @template
      @

  class SAT.herramientasView extends Backbone.AnimView
    el: '#app'
    template: _.template $('#tmpl-herramientas').html()
    render: ->
      @$el.html @template
      @

  class SAT.ayudaView extends Backbone.AnimView
    el: '#app'
    template: _.template $('#tmpl-ayuda').html()
    render: ->
      @$el.html @template
      @

  ### Router ###
  class SAT.Router extends Backbone.Router
    routes:
      '': 'index'
      'login': 'login'
      'citas': 'citas'
      'pagos': 'pagos'
      'feedback': 'feedback'
      'herramientas': 'herramientas'
      'ayuda': 'ayuda'
    index: ->
      return @navigate 'login', true unless SAT.isLogged
      indexview = new SAT.indexView
      indexview.render()
    login: ->
      view = new SAT.loginView
      view.render()
    citas: ->
      view = new SAT.citasView
      view.render()
    pagos: ->
      view = new SAT.pagosView
      view.render()
    feedback: ->
      view = new SAT.feedbackView
      view.render()
    herramientas: ->
      view = new SAT.herramientasView
      view.render()
    ayuda: ->
      view = new SAT.ayudaView
      view.render()

  SAT.history = new SAT.historyModel

  header = new SAT.headerView(history: SAT.history)
  header.render()

  router = new SAT.Router
  Backbone.history.start()
