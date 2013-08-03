(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  $(function() {
    var router, _ref, _ref1, _ref2, _ref3;
    window.SAT = {};
    SAT.isLogged = false;
    SAT.currentView = true;
    Backbone.AView = (function(_super) {
      __extends(AView, _super);

      function AView() {
        _ref = AView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      AView.prototype.getAnimEl = function() {
        return Backbone.$((SAT.currentView = !SAT.currentView) ? '#app' : '#app2');
      };

      AView.prototype.setElement = function(element, delegate) {
        AView.__super__.setElement.apply(this, arguments);
        return this.$el = this.getAnimEl();
      };

      AView.prototype.render = function() {
        this.$el = this.getAnimEl();
        return AView.__super__.render.apply(this, arguments);
      };

      return AView;

    })(Backbone.View);
    /* Models*/

    /* Collections*/

    /* Views*/

    SAT.loginView = (function(_super) {
      __extends(loginView, _super);

      function loginView() {
        _ref1 = loginView.__super__.constructor.apply(this, arguments);
        return _ref1;
      }

      loginView.prototype.el = '#app';

      loginView.prototype.template = _.template($('#tmpl-login').html());

      loginView.prototype.events = {
        'submit form#login': 'evt_login'
      };

      loginView.prototype.evt_login = function(e) {
        e.preventDefault();
        SAT.isLogged = true;
        return router.navigate('', true);
      };

      loginView.prototype.render = function() {
        this.$el.html(this.template);
        return this;
      };

      return loginView;

    })(Backbone.AView);
    SAT.indexView = (function(_super) {
      __extends(indexView, _super);

      function indexView() {
        _ref2 = indexView.__super__.constructor.apply(this, arguments);
        return _ref2;
      }

      indexView.prototype.el = '#app';

      indexView.prototype.template = _.template($('#tmpl-index').html());

      indexView.prototype.render = function() {
        this.$el.html(this.template);
        return this;
      };

      return indexView;

    })(Backbone.AView);
    /* Router*/

    SAT.Router = (function(_super) {
      __extends(Router, _super);

      function Router() {
        _ref3 = Router.__super__.constructor.apply(this, arguments);
        return _ref3;
      }

      Router.prototype.routes = {
        '': 'index',
        'login': 'login'
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

      return Router;

    })(Backbone.Router);
    router = new SAT.Router;
    return Backbone.history.start();
  });

}).call(this);
