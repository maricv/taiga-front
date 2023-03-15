###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

module = angular.module('taigaEpics')

BelongToEpicsDirective = ($translate, $confirm, $rs, $rs2, lightboxService) ->

    link = (scope, el, attrs) ->
        scope.$watch 'epics', (epics) ->
            updateEpics(epics)

        scope.$on "related-epics:changed", (ctx, userStory)->
            $rs.userstories.getByRef(userStory.project, userStory.ref, {}).then (us) ->
                scope.item.epics = us.epics
                updateEpics(us.epics)

        scope.removeEpicRelationship = (epic) ->
            title = $translate.instant("LIGHTBOX.REMOVE_RELATIONSHIP_WITH_EPIC.TITLE")
            message = $translate.instant(
                "LIGHTBOX.REMOVE_RELATIONSHIP_WITH_EPIC.MESSAGE",
                { epicSubject:  epic.get('subject') }
            )

            $confirm.ask(title, null, message).then (askResponse) ->
                onSuccess = ->
                    askResponse.finish()
                    scope.$broadcast("related-epics:changed", scope.item)

                onError = ->
                    askResponse.finish(false)
                    $confirm.notify("error")

                epicId = epic.get('id')
                usId = scope.item.id
                $rs2.epics.deleteRelatedUserstory(epicId, usId).then(onSuccess, onError)

        updateEpics = (epics) ->
            scope.epicsLength = 0
            scope.immutable_epics = []
            if epics && !epics.isIterable
                scope.epicsLength = epics.length
                scope.immutable_epics = Immutable.fromJS(epics)

    templateUrl = (el, attrs) ->
        if attrs.format
            return "components/belong-to-epics/belong-to-epics-" + attrs.format + ".html"
        return "components/belong-to-epics/belong-to-epics-pill.html"

    return {
        link: link,
        scope: {
            epics: '=',
            item: "="
        },
        templateUrl: templateUrl
    }


module.directive("tgBelongToEpics", [
    "$translate", "$tgConfirm", "$tgResources", "tgResources", "lightboxService",
    BelongToEpicsDirective])
