###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class TicketWatchersController
    @.$inject = [
        "tgCurrentUserService"
        "$rootScope"
        "tgLightboxFactory"
        "$translate",
        "$tgQueueModelTransformation",
    ]

    constructor: (@currentUserService, @rootScope, @lightboxFactory, @translate, @modelTransform) ->
        @.user = @currentUserService.getUser()
        @.loading = false

    openWatchers: ->
        onClose = (watchersIds) => @.save(watchersIds)

        @lightboxFactory.create(
            'tg-lb-select-user',
            {
                "class": "lightbox lightbox-select-user",
            },
            {
                "currentUsers": @.item.watchers,
                "activeUsers": @.activeUsers,
                "onClose": onClose,
                "lbTitle": @translate.instant("COMMON.WATCHERS.ADD"),
            }
        )

    getPerms: ->
        return "" if !@.item

        name = @.item._name

        perms = {
            userstories: 'modify_us',
            issues: 'modify_issue',
            tasks: 'modify_task',
            epics: 'modify_epic'
        }

        return perms[name]

    watch: ->
        @.loading = true
        promise = @._watch()
        promise.finally () => @.loading = false
        return promise

    unwatch: ->
        @.loading = true
        promise = @._unwatch()
        promise.finally () => @.loading = false
        return promise

    deleteWatcher: (watcherId) ->
        watchersIds = _.filter(@.item.watchers, (x) => x != watcherId)
        @.save(watchersIds)

    save: (watchersIds) ->
        @.loading = true
        transform = @modelTransform.save (item) ->
            item.watchers = watchersIds
            return item
        transform.then =>
            @rootScope.$broadcast("object:updated")
        transform.finally () => @.loading = false

    _watch: ->
        @.onWatch()

    _unwatch: ->
        @.onUnwatch()

angular.module("taigaComponents").controller("TicketWatchersController", TicketWatchersController)
