###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

module = angular.module("taigaBase")


class ContribController extends taiga.Controller
    @.$inject = [
        "$rootScope",
        "$scope",
        "$routeParams",
        "$tgRepo",
        "$tgResources",
        "$tgConfirm",
        "tgProjectService",
        "tgErrorHandlingService"
    ]

    constructor: (@rootScope, @scope, @params, @repo, @rs, @confirm, @projectService, @errorHandlingService) ->
        @scope.currentPlugin = _.head(_.filter(@rootScope.adminPlugins, {"slug": @params.plugin}))
        @scope.projectSlug = @params.pslug

        @.loadInitialData()

    loadProject: ->
        project = @projectService.project.toJS()

        if not project.i_am_admin
            @errorHandlingService.permissionDenied()

        @scope.projectId = project.id
        @scope.project = project
        @scope.$emit('project:loaded', project)
        @scope.$broadcast('project:loaded', project)
        return project

    loadInitialData: ->
        return @.loadProject()

module.controller("ContribController", ContribController)


class ContribUserSettingsController extends taiga.Controller
    @.$inject = [
        "$rootScope",
        "$scope",
        "$routeParams"
    ]

    constructor: (@rootScope, @scope, @params) ->
        @scope.currentPlugin = _.head(_.filter(@rootScope.userSettingsPlugins, {"slug": @params.plugin}))

module.controller("ContribUserSettingsController", ContribUserSettingsController)
