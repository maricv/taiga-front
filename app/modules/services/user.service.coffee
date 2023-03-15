###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga
bindMethods = taiga.bindMethods


class UserService extends taiga.Service
    @.$inject = ["tgResources"]

    constructor: (@rs) ->
        bindMethods(@)

    getUserByUserName: (username) ->
        return @rs.users.getUserByUsername(username)

    getContacts: (userId, excludeProjectId) ->
        return @rs.users.getContacts(userId, excludeProjectId)

    getLiked: (userId, pageNumber, objectType, textQuery) ->
        return @rs.users.getLiked(userId, pageNumber, objectType, textQuery)

    getVoted: (userId, pageNumber, objectType, textQuery) ->
        return @rs.users.getVoted(userId, pageNumber, objectType, textQuery)

    getWatched: (userId, pageNumber, objectType, textQuery) ->
        return @rs.users.getWatched(userId, pageNumber, objectType, textQuery)

    getStats: (userId) ->
        return @rs.users.getStats(userId)

    attachUserContactsToProjects: (userId, projects) ->
        return @.getContacts(userId)
            .then (contacts) ->
                projects = projects.map (project) ->
                    contactsFiltered = contacts.filter (contact) ->
                        contactId = contact.get("id")
                        return project.get('members').indexOf(contactId) != -1

                    project = project.set("contacts", contactsFiltered)

                    return project

                return projects

angular.module("taigaCommon").service("tgUserService", UserService)
