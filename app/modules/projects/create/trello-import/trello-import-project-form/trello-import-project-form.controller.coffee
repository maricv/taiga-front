###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class TrelloImportProjectFormController
    @.$inject = [
        "tgCurrentUserService"
    ]

    constructor: (@currentUserService) ->
        @.canCreatePublicProjects = @currentUserService.canCreatePublicProjects()
        @.canCreatePrivateProjects = @currentUserService.canCreatePrivateProjects()

        @.projectForm = @.project.toJS()

        @.platformName = "Trello"
        @.projectForm.is_private = false
        @.projectForm.keepExternalReference = false

        if !@.canCreatePublicProjects.valid && @.canCreatePrivateProjects.valid
            @.projectForm.is_private = true

    checkUsersLimit: () ->
        @.limitMembersPrivateProject = @currentUserService.canAddMembersPrivateProject(@.members.size)
        @.limitMembersPublicProject = @currentUserService.canAddMembersPublicProject(@.members.size)

    saveForm: () ->
        @.onSaveProjectDetails({project: Immutable.fromJS(@.projectForm)})

    canCreateProject: () ->
        if @.projectForm.is_private
            return @.canCreatePrivateProjects.valid
        else
            return @.canCreatePublicProjects.valid

    isDisabled: () ->
        return !@.canCreateProject()

angular.module('taigaProjects').controller('TrelloImportProjectFormCtrl', TrelloImportProjectFormController)
