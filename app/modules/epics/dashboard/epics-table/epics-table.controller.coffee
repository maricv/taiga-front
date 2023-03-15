###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga
generateHash = @.taiga.generateHash

class EpicsTableController
    @.$inject = [
        "$tgConfirm",
        "tgEpicsService",
        "$timeout",
        "$tgStorage",
        "tgProjectService"
    ]

    constructor: (@confirm, @epicsService, @timeout, @storage, @projectService) ->
        @.hash = generateHash([@projectService.project.get('id'), 'epics'])
        @.displayOptions = false
        @.displayVotes = true
        @.options = @storage.get(@.hash, {
            votes: true,
            name: true,
            project: true,
            sprint: true,
            assigned: true,
            status: true,
            progress: true,
            closed: true,
            closed_us: true,
        })

        taiga.defineImmutableProperty @, 'epics', () => return @epicsService.epics
        taiga.defineImmutableProperty @, 'disabledEpicsPagination', () => return @epicsService._disablePagination
        taiga.defineImmutableProperty @, 'loadingEpics', () => return @epicsService._loadingEpics

    toggleEpicTableOptions: () ->
        @.displayOptions = !@.displayOptions

    reorderEpic: (epic, newIndex) ->
        if epic.get('epics_order') == newIndex
            return null

        @epicsService.reorderEpic(epic, newIndex)
            .then null, () => # on error
                @confirm.notify("error")

    nextPage: () ->
        @epicsService.nextPage()

    hoverEpicTableOption: () ->
        if @.timer
            @timeout.cancel(@.timer)

    hideEpicTableOption: () ->
        return @.timer = @timeout (=> @.displayOptions = false), 400

    updateViewOptions: () ->
        @storage.set(@.hash, @.options)

angular.module("taigaEpics").controller("EpicsTableCtrl", EpicsTableController)
