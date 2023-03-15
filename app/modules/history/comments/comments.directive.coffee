###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

module = angular.module('taigaHistory')

CommentsDirective = () ->
    link = (scope, el, attrs, ctrl) ->
        ctrl.initializePermissions()

    return {
        scope: {
            type: "<",
            name: "@",
            object: "@",
            comments: "<",
            onEditMode: "&",
            onDeleteComment: "&",
            onRestoreDeletedComment: "&",
            onAddComment: "&",
            onEditComment: "&",
            editMode: "<",
            loading: "<",
            deleting: "<",
            editing: "<",
            project: "=",
            reverse: "="
        },
        templateUrl:"history/comments/comments.html",
        bindToController: true,
        controller: 'CommentsCtrl',
        controllerAs: "vm"
        link: link
    }

module.directive("tgComments", CommentsDirective)
