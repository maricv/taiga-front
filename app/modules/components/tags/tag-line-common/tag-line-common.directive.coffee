###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

module = angular.module('taigaCommon')

TagLineCommonDirective = () ->
    link = (scope, el, attr, ctrl) ->
        if !_.isUndefined(attr.disableColorSelection)
            ctrl.disableColorSelection = true

        unwatch = scope.$watch "vm.project", (project) ->
            return if !project || !Object.keys(project).length

            unwatch()

            if not ctrl.disableColorSelection
                ctrl.colorArray = ctrl._createColorsArray(ctrl.project.tags_colors)

        el.on "keydown", ".tag-input", (event) ->
            if event.keyCode == 27
                ctrl.addTag = false

                ctrl.newTag.name = ""
                ctrl.newTag.color = ""

                event.stopPropagation()
            else if event.keyCode == 13
                event.preventDefault()

                if el.find('.tags-dropdown .selected').length
                    tagName = $('.tags-dropdown .selected .tags-dropdown-name').text()
                    ctrl.addNewTag(tagName, null)
                else
                    ctrl.addNewTag(ctrl.newTag.name, ctrl.newTag.color)

            scope.$apply()

    return {
        link: link,
        scope: {
            permissions: "@",
            loadingAddTag: "=",
            loadingRemoveTag: "=",
            tags: "=",
            project: "=",
            onAddTag: "&",
            onDeleteTag: "&"
        },
        templateUrl:"components/tags/tag-line-common/tag-line-common.html",
        controller: "TagLineCommonCtrl",
        controllerAs: "vm",
        bindToController: true
    }

module.directive("tgTagLineCommon", TagLineCommonDirective)
