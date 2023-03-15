###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

module = angular.module("taigaComponents")

issuesTableDirective = ($timeout) ->

    link = (scope, el, attrs, ctrl) ->
        scope.issueOptions = null

        scope.displayOptions = (id) ->
            if (timeout)
                $timeout.cancel(timeout)
                timeout = null
            scope.issueOptions = id

        scope.hideOptions = () ->
            timeout = $timeout (() ->
                scope.issueOptions = null
            ), 200

    return {
        controller: "IssuesTable",
        controllerAs: "ctrl",
        templateUrl: "components/issues-table/issues-table.html",
        bindToController: {
            issues: "<",
            showTags: "=",
            onLoadIssues: '&',
            onAddIssuesInBulk: '&',
            onAddNewIssue: '&',
            sprintIssues: '<',
            onDeleteIssue: '&',
            onEditIssue: '&',
            onDetachIssue: '&',
            onToggleTags: '&'
        },
        scope: true,
        link: link
    }

module.directive('tgIssuesTable', ['$timeout', issuesTableDirective])
