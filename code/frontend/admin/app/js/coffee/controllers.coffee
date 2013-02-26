# Controllers

xzbAdminAppControllers = angular.module 'xzbAdminApp.controllers', []
xzbAdminAppControllers.controller 'userListCtrl', ($scope, $http, $location) ->
	$http.get('json/users.json').success (data) ->
		$scope.users = data

	# Nav
	$scope.navClass = (page) ->
		# console.log "navClass: #{page}"
		last: @$last
		active: page and $scope.currentPage is page

	# Get path
	userPathWatch = ->
		$location.path()

	userPathWatchAction = (path) ->
		$scope.currentPage = path.split('/')[2]

	$scope.$watch userPathWatch, userPathWatchAction

	return true

xzbAdminAppControllers.controller 'recentArticlesCtrl', ($scope, $http, $dialog) ->

	$http.get('app/json/recent-articles.json').success (data) ->
		$scope.recent = data

	# Popup
	$scope.opts =
		backdrop: true
		keyboard: true
		backdropFade: true
		backdropClick: true
		templateUrl: 'app/partials/article-list.html'
		# template: t
		controller: 'articleListCtrl'

	$scope.openDialog = (category) ->
		angular.extend $scope.opts, resolve:
			category: category

		d = $dialog.dialog $scope.opts
		d.open().then (result) ->
			alert "close with result: #{result}" if result

	return true

xzbAdminAppControllers.controller 'articleListCtrl', ($scope, $http, dialog, category) ->

	$http.get("app/json/category-#{category}.json").success (data) ->
		$scope.articles = data

	$scope.articleList =
		category: category
		select: (id, index) ->
			@articleId = id
			$scope.currentSelected = index
		change: () ->
			console.log @articleId # Todo: Add post method to update "deliver" table in db
			dialog.close @articleId
		close: ->
			dialog.close()

	return true

xzbAdminAppControllers.controller 'userArticlesCtrl', ($scope, $http, $routeParams) ->

	$scope.userName = userName = $routeParams.user
	$http.get("app/json/#{userName}.json").success (data) ->
		$scope.delivers = data
