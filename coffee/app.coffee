$ ->
  window.SAT = {}
  SAT.isLogged = false

  ### Models ###
  ### Collections ###
  ### Views ###
  class SAT.loginView extends Backbone.View
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

  class SAT.indexView extends Backbone.View
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
