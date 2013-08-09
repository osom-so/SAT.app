$ ->
  window.SAT = 
    isLogged: on
    goBack: off
    currentView: 0
    history: []

  prefixes = ['moz', 'webkit']
  $('#app, #app2').bind "#{_.map(prefixes, (pfx)-> "#{pfx}AnimationStart").join(' ')}", (e)->
    if ~['slidein', 'slidein-back'].indexOf e.originalEvent.animationName
      $in = $(@)
      $out = $("#app, #app2").filter(":not(##{$(@).attr('id')})")
      $in.css
        top: window.scrollY
      if ($zbra_out = $out.find('.zebra-list')).size() and !$zbra_out.is('.reverse')
        $in.find('.zebra-list').addClass 'reverse'
  .bind "#{_.map(prefixes, (pfx)-> "#{pfx}AnimationEnd").join(' ')}", (e)->
    if ~['slideout', 'slideout-back'].indexOf e.originalEvent.animationName
      $out = $(@)
      $in = $("#app, #app2").filter(":not(##{$(@).attr('id')})")
      $out.empty()
      $in.css
        top: 0
    if ~['slidein', 'slidein-back'].indexOf e.originalEvent.animationName
      window.scrollTo 0,0
      $in = $(@)
      $in.css
        top: 0

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
      'click .notificacion a': 'evt_ver_notif'
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
      $(e.currentTarget).closest('header').toggleClass 'notifications-open'
    evt_help: (e)->
      e.preventDefault()
      router.navigate '/ayuda', true
    evt_ver_notif: (e)->
      e.preventDefault()
      router.navigate '/notificacion/1', true
    render: ->
      @$el.html @template
      @

  class SAT.loginView extends Backbone.AnimView
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

  class SAT.notificacionView extends Backbone.AnimView
    template: _.template $('#tmpl-notificacion').html()
    render: ->
      @$el.html @template
      @


  class SAT.indexView extends Backbone.AnimView
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
    template: _.template $('#tmpl-feedback').html()
    events:
      'click a': 'evt_menuitem'
    evt_menuitem: (e)->
      e.preventDefault()
      router.navigate $(e.currentTarget).attr('href'), true
    render: ->
      @$el.html @template
      @

  class SAT.feedbackSugerenciaView extends Backbone.AnimView
    template: _.template $('#tmpl-feedback-sugerencia').html()
    events:
      'submit form': 'evt_submit'
    evt_submit: (e)->
      e.preventDefault()
      router.navigate $(e.currentTarget).attr('action'), true
    render: ->
      @$el.html @template
      @

  class SAT.herramientasView extends Backbone.AnimView
    template: _.template $('#tmpl-herramientas').html()
    events:
      'click a': 'evt_menuitem'
    evt_menuitem: (e)->
      e.preventDefault()
      router.navigate $(e.currentTarget).attr('href'), true
    render: ->
      @$el.html @template
      @

  class SAT.herramientasCalculadorasView extends Backbone.AnimView
    template: _.template $('#tmpl-herramientas-calculadoras').html()
    events:
      'click a': 'evt_menuitem'
    evt_menuitem: (e)->
      e.preventDefault()
      router.navigate $(e.currentTarget).attr('href'), true
    render: ->
      @$el.html @template
      @

  class SAT.herramientasCalculadoraIsrView extends Backbone.AnimView
    template: _.template $('#tmpl-herramientas-calculadora-isr').html()
    events:
      'submit form': 'evt_submit'
      'blur .inputnumber': 'evt_submit'
      'click #periodo td': 'evt_cambiar_periodo'
    evt_submit: (e)->
      e.preventDefault()
      @$el.find('#resultado').show()
    evt_cambiar_periodo: (e)->
      $this = $(e.currentTarget)
      $this.closest('table').find('td.selected').removeClass 'selected'
      $this.addClass 'selected'
    render: ->
      @$el.html @template
      @

  class SAT.ayudaView extends Backbone.AnimView
    template: _.template $('#tmpl-ayuda').html()
    events:
      'click a': 'evt_menuitem'
    evt_menuitem: (e)->
      e.preventDefault()
      router.navigate $(e.currentTarget).attr('href'), true
    render: ->
      @$el.html @template
      @

  class SAT.citaAgendarView extends Backbone.AnimView
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
    template: _.template $('#tmpl-cita-agendar-confirmacion').html()
    render: ->
      @$el.html @template
      @

  class SAT.missingView extends Backbone.AnimView
    template: _.template $('#tmpl-404').html()
    render: ->
      @$el.html @template
      @

  ### Router ###
  class SAT.Router extends Backbone.Router
    routes:
      '': 'index'
      'login': 'login'
      'notificacion/:id': 'notificacion'
      'citas': 'citas'
      'citas/agendar': 'citas_agendar'
      'citas/agendar/lugares': 'citas_agendar_lugares'
      'citas/agendar/confirmar': 'citas_agendar_confirmar'
      'citas/agendar/confirmacion': 'citas_agendar_confirmacion'
      'pagos': 'pagos'
      'feedback': 'feedback'
      'feedback/:id': 'feedback_view'
      'herramientas': 'herramientas'
      'herramientas/calculadoras': 'herramientas_calculadoras'
      'herramientas/calculadora/isr': 'herramientas_calculadora_isr'
      'ayuda': 'ayuda'
      '*fourohfour': 'fourohfour'
    index: ->
      return @navigate 'login', true unless SAT.isLogged
      indexview = new SAT.indexView
      indexview.render()
    login: ->
      view = new SAT.loginView
      view.render()
    notificacion: ->
      view = new SAT.notificacionView
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
    feedback_view: ->
      view = new SAT.feedbackSugerenciaView
      view.render()
    herramientas: ->
      view = new SAT.herramientasView
      view.render()
    herramientas_calculadoras: ->
      view = new SAT.herramientasCalculadorasView
      view.render()
    herramientas_calculadora_isr: ->
      view = new SAT.herramientasCalculadoraIsrView
      view.render()
    ayuda: ->
      view = new SAT.ayudaView
      view.render()
    fourohfour: ->
      view = new SAT.missingView
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
