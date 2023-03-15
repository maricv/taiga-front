###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga

mixOf = @.taiga.mixOf
toString = @.taiga.toString
joinStr = @.taiga.joinStr
groupBy = @.taiga.groupBy
bindOnce = @.taiga.bindOnce
bindMethods = @.taiga.bindMethods

module = angular.module("taigaCommon")

class DetailController
    @.$inject = [
        '$routeParams',
        '$tgRepo',
        "tgProjectService",
        "$tgNavUrls",
        "$location"
    ]

    constructor: (@params, @repo, @projectService, @navurls, @location) ->
        @repo.resolve({
            pslug: @params.pslug,
            ref: @params.ref
        })
        .then (result) =>
            if result.issue
                url = @navurls.resolve('project-issues-detail', {
                    project: @projectService.project.get('slug'),
                    ref: @params.ref
                })
            else if result.task
                url = @navurls.resolve('project-tasks-detail', {
                    project: @projectService.project.get('slug'),
                    ref: @params.ref
                })
            else if result.us
                url = @navurls.resolve('project-userstories-detail', {
                    project: @projectService.project.get('slug'),
                    ref: @params.ref
                })
            else if result.epic
                url = @navurls.resolve('project-epics-detail', {
                    project: @projectService.project.get('slug'),
                    ref: @params.ref
                })
            else if result.wikipage
                url = @navurls.resolve('project-wiki-page', {
                    project: @projectService.project.get('slug'),
                    slug: @params.ref
                })

            @location.path(url)

module.controller("DetailController", DetailController)
