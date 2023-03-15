###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga
normalizeString = @.taiga.normalizeString

class UserListService
    @.$inject = [
        "tgCurrentUserService"
        "tgProjectService"
    ]

    constructor: (@currentUserService, @projectService) ->

    filterUsers: (text, user) ->
        username = user.full_name_display.toUpperCase()
        username = normalizeString(username)
        text = text.toUpperCase()
        text = normalizeString(text)
        return _.includes(username, text)

    searchUsers: (text, excludedUser) ->
        @.currentUser = @currentUserService.getUser()
        users = _.clone(@projectService.activeMembers.toJS(), true)
        users = _.reject(users, {"id": excludedUser.id}) if excludedUser
        users = _.sortBy(users, (o) => if o.id is @.currentUser?.get('id') then 0 else o.id)
        users = _.filter(users, _.partial(@.filterUsers, text)) if text?
        return users

angular.module("taigaCommon").service("tgUserListService", UserListService)
