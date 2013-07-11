'use strict';

# Declare app level module which depends on filters, and services
xzbAdminApp = angular.module 'xzbAdminApp', ['xzbAdminApp.services', 'xzbAdminApp.controllers', 'ui.bootstrap']

xzbAdminApp.config ['$locationProvider', ($locationProvider) ->
	$locationProvider.html5Mode(true).hashPrefix("!")
]

xzbAdminApp.config ['$routeProvider', ($routeProvider) ->
	$routeProvider.when "/all",
		templateUrl: 'app/partials/all.html'
		controller: 'recentArticlesCtrl'
	$routeProvider.when '/:user',
		templateUrl: 'app/partials/user.html'
		controller: 'userArticlesCtrl'
	$routeProvider.otherwise redirectTo: '/all'
]