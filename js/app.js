(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  $(function() {
    var header, router, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6;
    window.SAT = {};
    SAT.isLogged = false;
    SAT.goBack = false;
    SAT.currentView = 0;
    SAT.history = [];
    $('#app, #app2').bind('webkitAnimationEnd', function(e) {
      var $in, $out;
      if (~['slideout', 'slideout-back'].indexOf(e.originalEvent.animationName)) {
        $out = $(this);
        $in = $("#app, #app2").filter(":not(#" + ($(this).attr('id')) + ")");
        $out.empty();
        return $in.css({
          top: 0
        });
      }
    }).bind('webkitAnimationStart', function(e) {
      var $in;
      if (~['slidein', 'slidein-back'].indexOf(e.originalEvent.animationName)) {
        $in = $(this);
        return $in.css({
          top: window.scrollY
        });
      }
    });
    Backbone.history.bind('route', function() {
      var history;
      history = SAT.history.get('history');
      if (history.length > 1 && this.getFragment() === history.slice(-2)[0]) {
        SAT.history.pop();
        return SAT.goBack = true;
      } else {
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
    /* Collections*/

    /* Views*/

    SAT.headerView = (function(_super) {
      __extends(headerView, _super);

      function headerView() {
        _ref2 = headerView.__super__.constructor.apply(this, arguments);
        return _ref2;
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
          if (history.length > 2) {
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
        return e.preventDefault();
      };

      headerView.prototype.evt_help = function(e) {
        return e.preventDefault();
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
        _ref3 = loginView.__super__.constructor.apply(this, arguments);
        return _ref3;
      }

      loginView.prototype.el = '#app';

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
        _ref4 = indexView.__super__.constructor.apply(this, arguments);
        return _ref4;
      }

      indexView.prototype.el = '#app';

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
        _ref5 = citasView.__super__.constructor.apply(this, arguments);
        return _ref5;
      }

      citasView.prototype.el = '#app';

      citasView.prototype.template = _.template($('#tmpl-citas').html());

      citasView.prototype.render = function() {
        this.$el.html(this.template({
          url: window.location.hash
        }));
        return this;
      };

      return citasView;

    })(Backbone.AnimView);
    /* Router*/

    SAT.Router = (function(_super) {
      __extends(Router, _super);

      function Router() {
        _ref6 = Router.__super__.constructor.apply(this, arguments);
        return _ref6;
      }

      Router.prototype.routes = {
        '': 'index',
        'login': 'login',
        'citas': 'citas',
        'pagos': 'citas',
        'notificaciones': 'citas',
        'ayuda': 'citas'
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
        var loginview;
        loginview = new SAT.loginView;
        return loginview.render();
      };

      Router.prototype.citas = function() {
        var citasview;
        citasview = new SAT.citasView;
        return citasview.render();
      };

      return Router;

    })(Backbone.Router);
    SAT.history = new SAT.historyModel;
    header = new SAT.headerView({
      history: SAT.history
    });
    header.render();
    router = new SAT.Router;
    return Backbone.history.start();
  });

}).call(this);
