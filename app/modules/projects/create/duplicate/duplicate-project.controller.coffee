###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class DuplicateProjectController
    @.$inject = [
        "tgCurrentUserService",
        "tgProjectsService",
        "$tgLocation",
        "$tgNavUrls"
    ]

    constructor: (@currentUserService, @projectsService, @location, @navUrls) ->
        @.user = @currentUserService.getUser()
        @.members = Immutable.List()

        @.canCreatePublicProjects = @currentUserService.canCreatePublicProjects()
        @.canCreatePrivateProjects = @currentUserService.canCreatePrivateProjects()

        taiga.defineImmutableProperty @, 'projects', () => @currentUserService.projects.get("all")

        @.projectForm = {
            is_private: false
        }

        if !@.canCreatePublicProjects.valid && @.canCreatePrivateProjects.valid
            @.projectForm.is_private = true

    refreshReferenceProject: (slug) ->
        @projectsService.getProjectBySlug(slug).then (project) =>
            @.referenceProject = project
            @.members = project.get('members').filter (it) => return it.get('id') != @.user.get('id')
            @.invitedMembers = @.members.map (it) -> return it.get('id')
            @.checkUsersLimit()

    toggleInvitedMember: (member) ->
        if @.invitedMembers.includes(member)
            @.invitedMembers = @.invitedMembers.filter (it) -> it != member
        else
            @.invitedMembers = @.invitedMembers.push(member)

        @.checkUsersLimit()

    checkUsersLimit: () ->
        @.limitMembersPrivateProject = @currentUserService.canAddMembersPrivateProject(@.invitedMembers.size + 1)
        @.limitMembersPublicProject = @currentUserService.canAddMembersPublicProject(@.invitedMembers.size + 1)

    submit: () ->
        projectId = @.referenceProject.get('id')
        data = @.projectForm
        data.users = @.invitedMembers

        @.formSubmitLoading = true
        @projectsService.duplicate(projectId, data).then (newProject) =>
            @.formSubmitLoading = false
            @location.path(@navUrls.resolve("project", {project: newProject.data.slug}))
            @currentUserService.loadProjects()

    canCreateProject: () ->
        if @.projectForm.is_private
            return @.canCreatePrivateProjects.valid && @.limitMembersPrivateProject.valid
        else
            return @.canCreatePublicProjects.valid && @.limitMembersPublicProject.valid

    isDisabled: () ->
        return @.formSubmitLoading || !@.canCreateProject()

    onCancelForm: () ->
        @location.path(@navUrls.resolve("create-project"))

angular.module("taigaProjects").controller("DuplicateProjectCtrl", DuplicateProjectController)
