$ ->
  window.SAT = {}
  SAT.isLogged = false
  SAT.currentView = 0

  class Backbone.AnimView extends Backbone.View
    switchEl: ->
      @$prev = Backbone.$(if SAT.currentView%2 then '#app' else '#app2')
      @$el = Backbone.$(if SAT.currentView%2 then '#app2' else '#app')
    setElement: ->
      super
      @switchEl()
      if SAT.currentView
        @$prev.removeClass('slide-in slide-out').addClass 'slide-out'
        @$el.removeClass('slide-in slide-out').addClass 'slide-in'
      SAT.currentView++

  ### Models ###
  ### Collections ###
  ### Views ###
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
    render: ->
      @$el.html @template
      @

  ### Router ###
  class SAT.Router extends Backbone.Router
    routes:
      '': 'index'
      'login': 'login'
    index: ->
      return @navigate 'login', true unless SAT.isLogged
      indexview = new SAT.indexView
      indexview.render()

    login: ->
      loginview = new SAT.loginView
      loginview.render()

  router = new SAT.Router
  Backbone.history.start()
