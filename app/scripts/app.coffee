'use strict'

angular
  .module('fgMapComponentApp', [
    'ipCookie',
    'ngResource',
    'ngSanitize',
    'ngRoute',
    'mapModule',
    'restangular',
    'config',
    'fgAuthenticate'
  ])

  .config ($httpProvider, RestangularProvider, $routeProvider) ->
    # Defaults to be used on every request.
    $httpProvider.defaults.useXDomain = true
    RestangularProvider.setDefaultHeaders({ "Content-Type": "application/json" })
    RestangularProvider.setBaseUrl "https://apidev.hcafi.com/"

    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .otherwise
        redirectTo: '/'



  .run ( $injector, Restangular, $rootScope, fgAuthService)->

    $rootScope.devMode = true
    window.rootScope = $rootScope

    if $rootScope.devMode
      $rootScope.facGuid = 'a6873adc' # AVENTURA HOSPITAL AND MED CTR
    else
      $rootScope.facGuid = window.facGuid # brought to you by the nice people at mindtouch




    # TODO BELOW IS CRAP, WE NEED TO FIGURE OUT THE LOADING FLOW
    # ==========================================================

    # Authenticate and then broadcast
    fgAuthService.authenticate_consumer().then (success)->
      console.log "Authenticated with API"
      $rootScope.api_authenticated = true
    , (error)->
      console.log error


    # = END CRAP ================================================




  .factory 'utils', ()-> {
    ###*
    * A helpful service to handle some helpful things inject
    * 'utils' in your countroller and use responsibly!!
    *###

    ###*
    * Helper method to $scope.$apply safely. Will prevent the dreaded
    * "digest already in progress" error when trying to apply
    *
    * @param {object} Current scope
    * @param {function} The function to apply
    ###
    safeApply: ($scope, fn)->
      phase = $scope.$$phase;
      if phase == '$apply' || phase == '$digest'
        if fn && (typeof(fn) is 'function')
          fn()
      else
        $scope.$apply fn

    ###*
    * This function is used to log things to the web console in
    * development and staging mode. It will not run the console.log
    * function in other modes and will not run the function if
    * it doesn't exist - good for older browsers such as IE8
    * Coloring/message severity not compatible with object inspection
    *
    * @param {any} The content that is logged to the console
    * @param {string} String used to color the message
    * @param {boolean} Used to push an alert...but not in production
    ###
    log: (what, severity = null, force = false)->
      if force
        alert what # ha
        return
      else
        try
        # Check if the type exists and check if console is
        # a member property of window
          if typeof console == 'object'
            if severity
              # Pick a style, bro
              style = switch
                when severity == 'primary' then 'background: transparent; color:#357ebd;'
                when severity == 'error' then 'background: #d9534f; color:#fff;'
                when severity == 'success' then 'background: #47a447; color:#fff;'
                when severity == 'warning' then 'background: #f0ad4e; color:#5F4500;'
                when severity == 'info' then 'background: #5bc0de; color:#004B61;'
                else
                  'background: transparent; color:#343434;'

              console.log '%c ' + what, style + 'padding: 0.1rem 0.3rem;'
            else
              console.log what
        finally
          return

    }
