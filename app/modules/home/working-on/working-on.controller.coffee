###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class WorkingOnController
    @.$inject = [
        "tgHomeService"
    ]

    constructor: (@homeService) ->
        @.assignedTo = Immutable.Map()
        @.hiddenAssignedTo = []
        @.showHiddenAssignedTo = false

        @.watching = Immutable.Map()
        @.showHiddenWatching = false

    _setAssignedTo: (workInProgress) ->
        epics = workInProgress.get("assignedTo").get("epics")
        userStories = workInProgress.get("assignedTo").get("userStories")
        tasks = workInProgress.get("assignedTo").get("tasks")
        issues = workInProgress.get("assignedTo").get("issues")

        @.assignedTo = userStories.concat(tasks).concat(issues).concat(epics)
        if @.assignedTo.size > 0
            @.assignedTo = @.assignedTo.sortBy((elem) -> elem.get("modified_date")).reverse()

    _setWatching: (workInProgress) ->
        epics = workInProgress.get("watching").get("epics")
        userStories = workInProgress.get("watching").get("userStories")
        tasks = workInProgress.get("watching").get("tasks")
        issues = workInProgress.get("watching").get("issues")

        @.watching = userStories.concat(tasks).concat(issues).concat(epics)
        if @.watching.size > 0
            @.watching = @.watching.sortBy((elem) -> elem.get("modified_date")).reverse()

    getWorkInProgress: (userId) ->
        return @homeService.getWorkInProgress(userId).then (workInProgress) =>
            @._setAssignedTo(workInProgress)
            @._setWatching(workInProgress)

angular.module("taigaHome").controller("WorkingOn", WorkingOnController)
