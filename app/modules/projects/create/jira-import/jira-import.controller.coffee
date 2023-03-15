###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class JiraImportController
    @.$inject = [
        'tgJiraImportService',
        '$tgConfirm',
        '$translate',
        'tgImportProjectService',
    ]

    constructor: (@jiraImportService, @confirm, @translate, @importProjectService) ->
        @.step = 'autorization-jira'
        @.project = null
        taiga.defineImmutableProperty @, 'projects', () => return @jiraImportService.projects
        taiga.defineImmutableProperty @, 'members', () => return @jiraImportService.projectUsers

    startProjectSelector: () ->
        @.step = 'project-select-jira'
        @jiraImportService.fetchProjects()

    onSelectProject: (project) ->
        @.step = 'project-form-jira'
        @.project = project
        @.fetchingUsers = true

        @jiraImportService.fetchUsers(@.project.get('id')).then () => @.fetchingUsers = false

    onSaveProjectDetails: (project) ->
        @.project = project
        @.step = 'project-members-jira'

    onCancelMemberSelection: () ->
        @.step = 'project-form-jira'        

    startImport: (users) ->
        loader = @confirm.loader(@translate.instant('PROJECT.IMPORT.IN_PROGRESS.TITLE'), @translate.instant('PROJECT.IMPORT.IN_PROGRESS.DESCRIPTION'), true)

        loader.start()

        projectType = @.project.get('project_type')
        if projectType == "issues" and @.project.get('create_subissues')
            projectType = "issues-with-subissues"

        promise = @jiraImportService.importProject(
            @.project.get('name'),
            @.project.get('description'),
            @.project.get('id'),
            users,
            @.project.get('keepExternalReference'),
            @.project.get('is_private'),
            projectType,
            @.project.get('importer_type'),
        )

        @importProjectService.importPromise(promise).then () => loader.stop()

    submitUserSelection: (users) ->
        @.startImport(users)
        return null

angular.module('taigaProjects').controller('JiraImportCtrl', JiraImportController)
