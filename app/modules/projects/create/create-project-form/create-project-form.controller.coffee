###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class CreatetProjectFormController
    @.$inject = [
        "tgCurrentUserService",
        "tgProjectsService",
        "$projectUrl",
        "$location",
        "$tgNavUrls",
        "$tgAnalytics"
   ]

    constructor: (@currentUserService, @projectsService, @projectUrl, @location, @navUrls, @analytics) ->
        @.errorList = []
        @.projectForm = {
            is_private: false
        }

        @.canCreatePublicProjects = @currentUserService.canCreatePublicProjects()
        @.canCreatePrivateProjects = @currentUserService.canCreatePrivateProjects()

        if !@.canCreatePublicProjects.valid && @.canCreatePrivateProjects.valid
            @.projectForm.is_private = true

        if @.type == 'scrum'
            @.projectForm.creation_template = 1
        else
            @.projectForm.creation_template = 2

    submit: () ->
        @.errorList = []
        if !@.projectForm.name then @.errorList.push('name')
        if !@.projectForm.description then @.errorList.push ('description')
        if(@.errorList.length == 0)
            @.formSubmitLoading = true
            @projectsService.create(@.projectForm).then (project) =>
                @analytics.trackEvent("project", "create", "project creation", {slug: project.get('slug'), id: project.get('id')})
                @location.url(@projectUrl.get(project))
                @currentUserService.loadProjects()

    onCancelForm: () ->
        @location.path(@navUrls.resolve("create-project"))

    canCreateProject: () ->
        if @.projectForm.is_private
            return @.canCreatePrivateProjects.valid
        else
            return @.canCreatePublicProjects.valid

    isDisabled: () ->
        return @.formSubmitLoading || !@.canCreateProject()

angular.module('taigaProjects').controller('CreateProjectFormCtrl', CreatetProjectFormController)
