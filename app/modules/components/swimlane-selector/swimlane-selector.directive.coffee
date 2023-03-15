###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga
timeout = @.taiga.timeout
cancelTimeout = @.taiga.cancelTimeout

#############################################################################
## Swimlane Selector
#############################################################################

SwimlaneSelector = ($timeout, $translate) ->

    link = (scope, el, attrs) ->

        scope.displaySelector = false
        scope.selectedSwimlane = null
        timeout = null

        mount = () ->
            getCurrentSwimlane()

        getCurrentSwimlane = () ->
            if (scope.userStory.id)
                if (scope.userStory.swimlane)
                    filteredSwimlanes = scope.swimlanes.filter (swimlane) ->
                        return swimlane.id == scope.userStory.swimlane

                    scope.currentSwimlane = filteredSwimlanes.get(0)
                else
                    scope.currentSwimlane = null
            else
                filteredSwimlanes = scope.swimlanes.filter (swimlane) ->
                    return swimlane.id == scope.defaultSwimlaneId

                scope.currentSwimlane = filteredSwimlanes.get(0)
            getSelectedSwimlane()

        getSelectedSwimlane = () ->
            if (scope.userStory.id)
                if (scope.currentSwimlane)
                    scope.selectedSwimlane = scope.currentSwimlane.id
                else
                    scope.selectedSwimlane = null
            else
                scope.selectedSwimlane = scope.currentSwimlane.id

        scope.displayOptions = () ->
            if (timeout)
                $timeout.cancel(timeout)
                timeout = null
            scope.displaySelector = true

        scope.hideOptions = () ->
            timeout = $timeout (() ->
                scope.displaySelector = false
            ), 100

        scope.selectSwimlane = (swimlane) ->
            if (swimlane == 'noSwimlane')
                swimlane = {
                    id: null,
                    kanban_order: 1,
                    name: $translate.instant("KANBAN.UNCLASSIFIED_USER_STORIES")
                }
                scope.ngModel = swimlane.id
                scope.currentSwimlane = swimlane
                scope.hideOptions()
            else
                scope.ngModel = if swimlane.id != -1 then swimlane.id else null
                scope.currentSwimlane = swimlane
                scope.hideOptions()

            getSelectedSwimlane()

        scope.$watch 'userStory', (userStory) ->
            getCurrentSwimlane()

        mount()

    return {
        link: link,
        templateUrl: "components/swimlane-selector/swimlane-selector.html",
        scope: {
            swimlanes: '<',
            defaultSwimlaneId: '<',
            userStory: '<'
            hasUnclassifiedStories: '<'
            ngModel : '=',
        },
        require: "ngModel"
    }

angular.module('taigaComponents').directive("tgSwimlaneSelector", ['$timeout', "$translate", SwimlaneSelector])
