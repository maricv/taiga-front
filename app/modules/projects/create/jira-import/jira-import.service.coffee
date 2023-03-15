###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class JiraImportService extends taiga.Service
    @.$inject = [
        'tgResources',
        '$location',
        '$q'
    ]

    constructor: (@resources, @location, @q) ->
        @.projects = Immutable.List()
        @.projectUsers = Immutable.List()

    setToken: (token, url) ->
        @.token = token
        @.url = url

    fetchProjects: () ->
        @resources.jiraImporter.listProjects(@.url, @.token).then (projects) => @.projects = projects

    fetchUsers: (projectId) ->
        @resources.jiraImporter.listUsers(@.url, @.token, projectId).then (users) => @.projectUsers = users

    importProject: (name, description, projectId, userBindings, keepExternalReference, isPrivate, projectType, importerType) ->
            @resources.jiraImporter.importProject(@.url, @.token, name, description, projectId, userBindings, keepExternalReference, isPrivate, projectType, importerType)

    getAuthUrl: (url) ->
        return @q (resolve, reject) =>
            @resources.jiraImporter.getAuthUrl(url).then (response) =>
                @.authUrl = response.data.url
                resolve(@.authUrl)
            , (err) =>
                reject(err.data._error_message)

    authorize: (oauth_verifier) ->
        return @q (resolve, reject) =>
            @resources.jiraImporter.authorize(oauth_verifier).then ((response) =>
                @.token = response.data.token
                @.url = response.data.url
                resolve(response.data)
            ), (error) ->
                reject(new Error(error.status))

angular.module("taigaProjects").service("tgJiraImportService", JiraImportService)
