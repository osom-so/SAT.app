$ ->
  window.SAT = 
    isLogged: on
    goBack: off
    currentView: 0
    history: []

  prefixes = ['moz', 'webkit']
  $('#app, #app2').bind "#{_.map(prefixes, (pfx)-> "#{pfx}AnimationEnd").join(' ')}", (e)->
    if ~['slideout', 'slideout-back'].indexOf e.originalEvent.animationName
      $out = $(@)
      $in = $("#app, #app2").filter(":not(##{$(@).attr('id')})")
      $out.empty()
      $in.css
        top: 0
  .bind "#{_.map(prefixes, (pfx)-> "#{pfx}AnimationStart").join(' ')}", (e)->
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
      SAT.history.unshift '' if history.length is 0 and !~['login', ''].indexOf(@getFragment())
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
    unshift: (el)->
      history = @get 'history'
      history.unshift(el)
      @set 'history', history
      @trigger 'history:change', @
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

  class SAT.pagoModel extends Backbone.Model

  ### Collections ###
  class SAT.pagosCollection extends Backbone.Collection
    model: SAT.pagoModel

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
    events:
      'click a': 'evt_menuitem'
    evt_menuitem: (e)->
      e.preventDefault()
      router.navigate $(e.currentTarget).attr('href'), true
    render: ->
      @$el.html @template
      @

  class SAT.pagosView extends Backbone.AnimView
    el: '#app'
    template: _.template $('#tmpl-pagos').html()
    initialize: (ini)->
      @pagos = ini.pagos
    render: ->
      view = @
      @$el.html @template
      @pagos.each (pago)->
        el = new SAT.pagoEl
        view.$el.find("#pagos-list").append el.render(pago).el
      @

  class SAT.pagoEl extends Backbone.View
    template: _.template $('#tmpl-pago-el').html()
    tagName: 'li'
    render: (pago)->
      @$el.addClass("st-#{pago.get('status')}").html @template(pago:pago)
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

  class SAT.citaAgendarView extends Backbone.AnimView
    el: '#app'
    template: _.template $('#tmpl-cita-agendar').html()
    events:
      'submit form': 'evt_submit'
    evt_submit: (e)->
      e.preventDefault()
      router.navigate $(e.currentTarget).attr('action'), true
    render: ->
      @$el.html @template
      @

  class SAT.citaAgendarLugaresView extends Backbone.AnimView
    el: '#app'
    template: _.template $('#tmpl-cita-agendar-lugares').html()
    events:
      'submit form': 'evt_submit'
    evt_submit: (e)->
      e.preventDefault()
      router.navigate $(e.currentTarget).attr('action'), true
    render: ->
      @$el.html @template
      @

  class SAT.citaAgendarConfirmarView extends Backbone.AnimView
    el: '#app'
    template: _.template $('#tmpl-cita-agendar-confirmar').html()
    events:
      'submit form': 'evt_submit'
    evt_submit: (e)->
      e.preventDefault()
      router.navigate $(e.currentTarget).attr('action'), true
    render: ->
      @$el.html @template
      @

  class SAT.citaAgendarConfirmacionView extends Backbone.AnimView
    el: '#app'
    template: _.template $('#tmpl-cita-agendar-confirmacion').html()
    render: ->
      @$el.html @template
      @

  ### Router ###
  class SAT.Router extends Backbone.Router
    routes:
      '': 'index'
      'login': 'login'
      'citas': 'citas'
      'citas/agendar': 'citas_agendar'
      'citas/agendar/lugares': 'citas_agendar_lugares'
      'citas/agendar/confirmar': 'citas_agendar_confirmar'
      'citas/agendar/confirmacion': 'citas_agendar_confirmacion'
      'citas/:id': 'citas'
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
    citas_agendar: ->
      view = new SAT.citaAgendarView
      view.render()
    citas_agendar_lugares: ->
      view = new SAT.citaAgendarLugaresView
      view.render()
    citas_agendar_confirmar: ->
      view = new SAT.citaAgendarConfirmarView
      view.render()
    citas_agendar_confirmacion: ->
      view = new SAT.citaAgendarConfirmacionView
      view.render()
    pagos: ->
      view = new SAT.pagosView(pagos: pagos)
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

  # Models & Stuff
  pagos = new SAT.pagosCollection
  pagos.add [
    id: 50713885
    status: 'pagado'
    fecha: '15 de Marzo 2013'
    importe: '$1,438.00'
  ,
    id: 52686212
    status: 'pagado'
    fecha: '17 de Abril 2013'
    importe: '$11,348.00'
  ,
    id: 54599274
    status: 'pendiente'
    fecha: '17 de Mayo 2013'
    importe: '$30,022.00'
  ,
    id: 26228503
    status: 'error'
    fecha: '12 de Junio 2013'
    importe: '$100,123.00'
  ]

  # Start 
  router = new SAT.Router
  Backbone.history.start()

  $(document).on 'change', ' input.full-select', (e)->
    $(this).closest('ul').find('li').addClass('was-full-selected').removeClass 'full-selected'
    $(this).closest('li').removeClass('was-full-selected').addClass 'full-selected'
