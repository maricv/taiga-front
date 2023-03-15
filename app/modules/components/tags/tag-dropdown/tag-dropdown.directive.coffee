###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

module = angular.module('taigaCommon')

TagOptionDirective = () ->
    select = (selected) ->
        selected.addClass('selected')

        selectedPosition = selected.position().top + selected.outerHeight()
        containerHeight = selected.parent().outerHeight()

        if selectedPosition > containerHeight
            diff = selectedPosition - containerHeight
            selected.parent().scrollTop(selected.parent().scrollTop() + diff)
        else if selected.position().top < 0
            selected.parent().scrollTop(selected.parent().scrollTop() + selected.position().top)

    dispatch = (el, code, scope) ->
        activeElement = el.find(".selected")

        # Key: down
        if code == 40
            if not activeElement.length
                select(el.find('li:first'))
            else
                next = activeElement.next('li')
                if next.length
                    activeElement.removeClass('selected')
                    select(next)
        # Key: up
        else if code == 38
            if not activeElement.length
                select(el.find('li:last'))
            else
                prev = activeElement.prev('li')

                if prev.length
                    activeElement.removeClass('selected')
                    select(prev)

    stop = ->
        $(document).off(".tags-keyboard-navigation")

    link = (scope, el) ->
        stop()

        $(el).parent().on "keydown.tags-keyboard-navigation", (event) =>
            code = if event.keyCode then event.keyCode else event.which

            if code == 40 || code == 38
                event.preventDefault()

                dispatch(el, code, scope)

        scope.$on("$destroy", stop)

    return {
        link: link,
        templateUrl:"components/tags/tag-dropdown/tag-dropdown.html",
        scope: {
            onSelectTag: "&",
            colorArray: "=",
            tag: "="
        }
    }

module.directive("tgTagsDropdown", TagOptionDirective)
