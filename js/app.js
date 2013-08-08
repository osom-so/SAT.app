(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  $(function() {
    var header, pagos, prefixes, router, _ref, _ref1, _ref10, _ref11, _ref12, _ref13, _ref14, _ref15, _ref16, _ref17, _ref18, _ref19, _ref2, _ref20, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9;
    window.SAT = {
      isLogged: true,
      goBack: false,
      currentView: 0,
      history: []
    };
    prefixes = ['moz', 'webkit'];
    $('#app, #app2').bind("" + (_.map(prefixes, function(pfx) {
      return "" + pfx + "AnimationStart";
    }).join(' ')), function(e) {
      var $in, $out, $zbra_out;
      if (~['slidein', 'slidein-back'].indexOf(e.originalEvent.animationName)) {
        $in = $(this);
        $out = $("#app, #app2").filter(":not(#" + ($(this).attr('id')) + ")");
        $in.css({
          top: window.scrollY
        });
        if (($zbra_out = $out.find('.zebra-list')).size() && !$zbra_out.is('.reverse')) {
          return $in.find('.zebra-list').addClass('reverse');
        }
      }
    }).bind("" + (_.map(prefixes, function(pfx) {
      return "" + pfx + "AnimationEnd";
    }).join(' ')), function(e) {
      var $in, $out;
      if (~['slideout', 'slideout-back'].indexOf(e.originalEvent.animationName)) {
        $out = $(this);
        $in = $("#app, #app2").filter(":not(#" + ($(this).attr('id')) + ")");
        $out.empty();
        $in.css({
          top: 0
        });
      }
      if (~['slidein', 'slidein-back'].indexOf(e.originalEvent.animationName)) {
        window.scrollTo(0, 0);
        $in = $(this);
        return $in.css({
          top: 0
        });
      }
    });
    Backbone.history.bind('route', function() {
      var history;
      history = SAT.history.get('history');
      if (history.slice(-1)[0] === this.getFragment()) {
        return;
      }
      if (history.length > 1 && this.getFragment() === history.slice(-2)[0]) {
        SAT.history.pop();
        return SAT.goBack = true;
      } else {
        if (history.length === 0 && !~['login', ''].indexOf(this.getFragment())) {
          SAT.history.unshift('');
        }
        return SAT.history.push(this.getFragment());
      }
    });
    Backbone.AnimView = (function(_super) {
      __extends(AnimView, _super);

      function AnimView() {
        _ref = AnimView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      AnimView.prototype.switchEl = function() {
        this.$prev = Backbone.$(SAT.currentView % 2 ? '#app' : '#app2');
        return this.$el = Backbone.$(SAT.currentView % 2 ? '#app2' : '#app');
      };

      AnimView.prototype.setElement = function() {
        var view;
        AnimView.__super__.setElement.apply(this, arguments);
        this.switchEl();
        view = this;
        return setTimeout(function() {
          if (SAT.currentView) {
            view.$prev.attr('class', "slide-out " + (SAT.goBack ? "slide-back" : ''));
            view.$el.attr('class', "slide-in " + (SAT.goBack ? "slide-back" : ''));
            SAT.goBack = false;
          }
          return SAT.currentView++;
        });
      };

      return AnimView;

    })(Backbone.View);
    /* Models*/

    SAT.historyModel = (function(_super) {
      __extends(historyModel, _super);

      function historyModel() {
        _ref1 = historyModel.__super__.constructor.apply(this, arguments);
        return _ref1;
      }

      historyModel.prototype.defaults = {
        history: []
      };

      historyModel.prototype.unshift = function(el) {
        var history;
        history = this.get('history');
        history.unshift(el);
        this.set('history', history);
        return this.trigger('history:change', this);
      };

      historyModel.prototype.pop = function(el) {
        var history;
        history = this.get('history');
        history.pop();
        this.set('history', history);
        return this.trigger('history:change', this);
      };

      historyModel.prototype.push = function(el) {
        var history;
        history = this.get('history');
        history.push(el);
        this.set('history', history);
        return this.trigger('history:change', this);
      };

      return historyModel;

    })(Backbone.Model);
    SAT.pagoModel = (function(_super) {
      __extends(pagoModel, _super);

      function pagoModel() {
        _ref2 = pagoModel.__super__.constructor.apply(this, arguments);
        return _ref2;
      }

      return pagoModel;

    })(Backbone.Model);
    /* Collections*/

    SAT.pagosCollection = (function(_super) {
      __extends(pagosCollection, _super);

      function pagosCollection() {
        _ref3 = pagosCollection.__super__.constructor.apply(this, arguments);
        return _ref3;
      }

      pagosCollection.prototype.model = SAT.pagoModel;

      return pagosCollection;

    })(Backbone.Collection);
    /* Views*/

    SAT.headerView = (function(_super) {
      __extends(headerView, _super);

      function headerView() {
        _ref4 = headerView.__super__.constructor.apply(this, arguments);
        return _ref4;
      }

      headerView.prototype.el = '#app-header';

      headerView.prototype.template = _.template($('#tmpl-header').html());

      headerView.prototype.events = {
        'click a.back': 'evt_back',
        'click a.notif': 'evt_notif',
        'click a.help': 'evt_help'
      };

      headerView.prototype.initialize = function(ini) {
        this.history = ini.history;
        return this.listenTo(this.history, 'history:change', function(h) {
          var history;
          history = h.get('history');
          if (history.length > 1) {
            return this.$el.prop('class', 'has-history');
          } else {
            return this.$el.prop('class', '');
          }
        });
      };

      headerView.prototype.evt_back = function(e) {
        var history;
        e.preventDefault();
        history = SAT.history.get('history');
        return router.navigate(history.slice(-2)[0], true);
      };

      headerView.prototype.evt_notif = function(e) {
        e.preventDefault();
        return $(e.currentTarget).closest('header').toggleClass('notifications-open');
      };

      headerView.prototype.evt_help = function(e) {
        e.preventDefault();
        return router.navigate('/ayuda', true);
      };

      headerView.prototype.render = function() {
        this.$el.html(this.template);
        return this;
      };

      return headerView;

    })(Backbone.View);
    SAT.loginView = (function(_super) {
      __extends(loginView, _super);

      function loginView() {
        _ref5 = loginView.__super__.constructor.apply(this, arguments);
        return _ref5;
      }

      loginView.prototype.template = _.template($('#tmpl-login').html());

      loginView.prototype.events = {
        'submit form#login': 'evt_login'
      };

      loginView.prototype.evt_login = function(e) {
        e.preventDefault();
        SAT.isLogged = true;
        setTimeout(function() {
          return router.navigate('', true);
        }, 400);
        SAT.history.set('history', _.reject(SAT.history.get('history'), function(h) {
          return h === 'login';
        }));
        return this.$el.get(0).focus();
      };

      loginView.prototype.render = function() {
        this.$el.html(this.template);
        return this;
      };

      return loginView;

    })(Backbone.AnimView);
    SAT.indexView = (function(_super) {
      __extends(indexView, _super);

      function indexView() {
        _ref6 = indexView.__super__.constructor.apply(this, arguments);
        return _ref6;
      }

      indexView.prototype.template = _.template($('#tmpl-index').html());

      indexView.prototype.events = {
        'click a': 'evt_menuitem'
      };

      indexView.prototype.evt_menuitem = function(e) {
        e.preventDefault();
        return router.navigate($(e.currentTarget).attr('href'), true);
      };

      indexView.prototype.render = function() {
        this.$el.html(this.template);
        return this;
      };

      return indexView;

    })(Backbone.AnimView);
    SAT.citasView = (function(_super) {
      __extends(citasView, _super);

      function citasView() {
        _ref7 = citasView.__super__.constructor.apply(this, arguments);
        return _ref7;
      }

      citasView.prototype.template = _.template($('#tmpl-citas').html());

      citasView.prototype.events = {
        'click a': 'evt_menuitem'
      };

      citasView.prototype.evt_menuitem = function(e) {
        e.preventDefault();
        return router.navigate($(e.currentTarget).attr('href'), true);
      };

      citasView.prototype.render = function() {
        this.$el.html(this.template);
        return this;
      };

      return citasView;

    })(Backbone.AnimView);
    SAT.pagosView = (function(_super) {
      __extends(pagosView, _super);

      function pagosView() {
        _ref8 = pagosView.__super__.constructor.apply(this, arguments);
        return _ref8;
      }

      pagosView.prototype.template = _.template($('#tmpl-pagos').html());

      pagosView.prototype.initialize = function(ini) {
        return this.pagos = ini.pagos;
      };

      pagosView.prototype.render = function() {
        var view;
        view = this;
        this.$el.html(this.template);
        this.pagos.each(function(pago) {
          var el;
          el = new SAT.pagoEl;
          return view.$el.find("#pagos-list").append(el.render(pago).el);
        });
        return this;
      };

      return pagosView;

    })(Backbone.AnimView);
    SAT.pagoEl = (function(_super) {
      __extends(pagoEl, _super);

      function pagoEl() {
        _ref9 = pagoEl.__super__.constructor.apply(this, arguments);
        return _ref9;
      }

      pagoEl.prototype.template = _.template($('#tmpl-pago-el').html());

      pagoEl.prototype.tagName = 'li';

      pagoEl.prototype.render = function(pago) {
        this.$el.addClass("st-" + (pago.get('status'))).html(this.template({
          pago: pago
        }));
        return this;
      };

      return pagoEl;

    })(Backbone.View);
    SAT.feedbackView = (function(_super) {
      __extends(feedbackView, _super);

      function feedbackView() {
        _ref10 = feedbackView.__super__.constructor.apply(this, arguments);
        return _ref10;
      }

      feedbackView.prototype.template = _.template($('#tmpl-feedback').html());

      feedbackView.prototype.render = function() {
        this.$el.html(this.template);
        return this;
      };

      return feedbackView;

    })(Backbone.AnimView);
    SAT.herramientasView = (function(_super) {
      __extends(herramientasView, _super);

      function herramientasView() {
        _ref11 = herramientasView.__super__.constructor.apply(this, arguments);
        return _ref11;
      }

      herramientasView.prototype.template = _.template($('#tmpl-herramientas').html());

      herramientasView.prototype.events = {
        'click a': 'evt_menuitem'
      };

      herramientasView.prototype.evt_menuitem = function(e) {
        e.preventDefault();
        return router.navigate($(e.currentTarget).attr('href'), true);
      };

      herramientasView.prototype.render = function() {
        this.$el.html(this.template);
        return this;
      };

      return herramientasView;

    })(Backbone.AnimView);
    SAT.herramientasCalculadorasView = (function(_super) {
      __extends(herramientasCalculadorasView, _super);

      function herramientasCalculadorasView() {
        _ref12 = herramientasCalculadorasView.__super__.constructor.apply(this, arguments);
        return _ref12;
      }

      herramientasCalculadorasView.prototype.template = _.template($('#tmpl-herramientas-calculadoras').html());

      herramientasCalculadorasView.prototype.events = {
        'click a': 'evt_menuitem'
      };

      herramientasCalculadorasView.prototype.evt_menuitem = function(e) {
        e.preventDefault();
        return router.navigate($(e.currentTarget).attr('href'), true);
      };

      herramientasCalculadorasView.prototype.render = function() {
        this.$el.html(this.template);
        return this;
      };

      return herramientasCalculadorasView;

    })(Backbone.AnimView);
    SAT.herramientasCalculadoraIsrView = (function(_super) {
      __extends(herramientasCalculadoraIsrView, _super);

      function herramientasCalculadoraIsrView() {
        _ref13 = herramientasCalculadoraIsrView.__super__.constructor.apply(this, arguments);
        return _ref13;
      }

      herramientasCalculadoraIsrView.prototype.template = _.template($('#tmpl-herramientas-calculadora-isr').html());

      herramientasCalculadoraIsrView.prototype.events = {
        'submit form': 'evt_submit',
        'click #periodo td': 'evt_cambiar_periodo'
      };

      herramientasCalculadoraIsrView.prototype.evt_submit = function(e) {
        e.preventDefault();
        return this.$el.find('#resultado').show();
      };

      herramientasCalculadoraIsrView.prototype.evt_cambiar_periodo = function(e) {
        var $this;
        $this = $(e.currentTarget);
        $this.closest('table').find('td.selected').removeClass('selected');
        return $this.addClass('selected');
      };

      herramientasCalculadoraIsrView.prototype.render = function() {
        this.$el.html(this.template);
        return this;
      };

      return herramientasCalculadoraIsrView;

    })(Backbone.AnimView);
    SAT.ayudaView = (function(_super) {
      __extends(ayudaView, _super);

      function ayudaView() {
        _ref14 = ayudaView.__super__.constructor.apply(this, arguments);
        return _ref14;
      }

      ayudaView.prototype.template = _.template($('#tmpl-ayuda').html());

      ayudaView.prototype.render = function() {
        this.$el.html(this.template);
        return this;
      };

      return ayudaView;

    })(Backbone.AnimView);
    SAT.citaAgendarView = (function(_super) {
      __extends(citaAgendarView, _super);

      function citaAgendarView() {
        _ref15 = citaAgendarView.__super__.constructor.apply(this, arguments);
        return _ref15;
      }

      citaAgendarView.prototype.template = _.template($('#tmpl-cita-agendar').html());

      citaAgendarView.prototype.events = {
        'submit form': 'evt_submit'
      };

      citaAgendarView.prototype.evt_submit = function(e) {
        e.preventDefault();
        return router.navigate($(e.currentTarget).attr('action'), true);
      };

      citaAgendarView.prototype.render = function() {
        this.$el.html(this.template);
        return this;
      };

      return citaAgendarView;

    })(Backbone.AnimView);
    SAT.citaAgendarLugaresView = (function(_super) {
      __extends(citaAgendarLugaresView, _super);

      function citaAgendarLugaresView() {
        _ref16 = citaAgendarLugaresView.__super__.constructor.apply(this, arguments);
        return _ref16;
      }

      citaAgendarLugaresView.prototype.template = _.template($('#tmpl-cita-agendar-lugares').html());

      citaAgendarLugaresView.prototype.events = {
        'submit form': 'evt_submit'
      };

      citaAgendarLugaresView.prototype.evt_submit = function(e) {
        e.preventDefault();
        return router.navigate($(e.currentTarget).attr('action'), true);
      };

      citaAgendarLugaresView.prototype.render = function() {
        this.$el.html(this.template);
        return this;
      };

      return citaAgendarLugaresView;

    })(Backbone.AnimView);
    SAT.citaAgendarConfirmarView = (function(_super) {
      __extends(citaAgendarConfirmarView, _super);

      function citaAgendarConfirmarView() {
        _ref17 = citaAgendarConfirmarView.__super__.constructor.apply(this, arguments);
        return _ref17;
      }

      citaAgendarConfirmarView.prototype.template = _.template($('#tmpl-cita-agendar-confirmar').html());

      citaAgendarConfirmarView.prototype.events = {
        'submit form': 'evt_submit'
      };

      citaAgendarConfirmarView.prototype.evt_submit = function(e) {
        e.preventDefault();
        return router.navigate($(e.currentTarget).attr('action'), true);
      };

      citaAgendarConfirmarView.prototype.render = function() {
        this.$el.html(this.template);
        return this;
      };

      return citaAgendarConfirmarView;

    })(Backbone.AnimView);
    SAT.citaAgendarConfirmacionView = (function(_super) {
      __extends(citaAgendarConfirmacionView, _super);

      function citaAgendarConfirmacionView() {
        _ref18 = citaAgendarConfirmacionView.__super__.constructor.apply(this, arguments);
        return _ref18;
      }

      citaAgendarConfirmacionView.prototype.template = _.template($('#tmpl-cita-agendar-confirmacion').html());

      citaAgendarConfirmacionView.prototype.render = function() {
        this.$el.html(this.template);
        return this;
      };

      return citaAgendarConfirmacionView;

    })(Backbone.AnimView);
    SAT.missingView = (function(_super) {
      __extends(missingView, _super);

      function missingView() {
        _ref19 = missingView.__super__.constructor.apply(this, arguments);
        return _ref19;
      }

      missingView.prototype.template = _.template($('#tmpl-404').html());

      missingView.prototype.render = function() {
        this.$el.html(this.template);
        return this;
      };

      return missingView;

    })(Backbone.AnimView);
    /* Router*/

    SAT.Router = (function(_super) {
      __extends(Router, _super);

      function Router() {
        _ref20 = Router.__super__.constructor.apply(this, arguments);
        return _ref20;
      }

      Router.prototype.routes = {
        '': 'index',
        'login': 'login',
        'citas': 'citas',
        'citas/agendar': 'citas_agendar',
        'citas/agendar/lugares': 'citas_agendar_lugares',
        'citas/agendar/confirmar': 'citas_agendar_confirmar',
        'citas/agendar/confirmacion': 'citas_agendar_confirmacion',
        'pagos': 'pagos',
        'feedback': 'feedback',
        'herramientas': 'herramientas',
        'herramientas/calculadoras': 'herramientas_calculadoras',
        'herramientas/calculadora/isr': 'herramientas_calculadora_isr',
        'ayuda': 'ayuda',
        '*fourohfour': 'fourohfour'
      };

      Router.prototype.index = function() {
        var indexview;
        if (!SAT.isLogged) {
          return this.navigate('login', true);
        }
        indexview = new SAT.indexView;
        return indexview.render();
      };

      Router.prototype.login = function() {
        var view;
        view = new SAT.loginView;
        return view.render();
      };

      Router.prototype.citas = function() {
        var view;
        view = new SAT.citasView;
        return view.render();
      };

      Router.prototype.citas_agendar = function() {
        var view;
        view = new SAT.citaAgendarView;
        return view.render();
      };

      Router.prototype.citas_agendar_lugares = function() {
        var view;
        view = new SAT.citaAgendarLugaresView;
        return view.render();
      };

      Router.prototype.citas_agendar_confirmar = function() {
        var view;
        view = new SAT.citaAgendarConfirmarView;
        return view.render();
      };

      Router.prototype.citas_agendar_confirmacion = function() {
        var view;
        view = new SAT.citaAgendarConfirmacionView;
        return view.render();
      };

      Router.prototype.pagos = function() {
        var view;
        view = new SAT.pagosView({
          pagos: pagos
        });
        return view.render();
      };

      Router.prototype.feedback = function() {
        var view;
        view = new SAT.feedbackView;
        return view.render();
      };

      Router.prototype.herramientas = function() {
        var view;
        view = new SAT.herramientasView;
        return view.render();
      };

      Router.prototype.herramientas_calculadoras = function() {
        var view;
        view = new SAT.herramientasCalculadorasView;
        return view.render();
      };

      Router.prototype.herramientas_calculadora_isr = function() {
        var view;
        view = new SAT.herramientasCalculadoraIsrView;
        return view.render();
      };

      Router.prototype.ayuda = function() {
        var view;
        view = new SAT.ayudaView;
        return view.render();
      };

      Router.prototype.fourohfour = function() {
        var view;
        view = new SAT.missingView;
        return view.render();
      };

      return Router;

    })(Backbone.Router);
    SAT.history = new SAT.historyModel;
    header = new SAT.headerView({
      history: SAT.history
    });
    header.render();
    pagos = new SAT.pagosCollection;
    pagos.add([
      {
        id: 50713885,
        status: 'pagado',
        fecha: '15 de Marzo 2013',
        importe: '$1,438.00'
      }, {
        id: 52686212,
        status: 'pagado',
        fecha: '17 de Abril 2013',
        importe: '$11,348.00'
      }, {
        id: 54599274,
        status: 'pendiente',
        fecha: '17 de Mayo 2013',
        importe: '$30,022.00'
      }, {
        id: 26228503,
        status: 'error',
        fecha: '12 de Junio 2013',
        importe: '$100,123.00'
      }
    ]);
    router = new SAT.Router;
    Backbone.history.start();
    return $(document).on('change', ' input.full-select', function(e) {
      $(this).closest('ul').find('li').addClass('was-full-selected').removeClass('full-selected');
      return $(this).closest('li').removeClass('was-full-selected').addClass('full-selected');
    });
  });

}).call(this);
