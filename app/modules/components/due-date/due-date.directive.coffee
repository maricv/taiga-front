###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

module = angular.module("taigaComponents")

dueDateDirective = ($translate, datePickerConfigService) ->
    templateUrl = (el, attrs) ->
        if attrs.format
            return "components/due-date/due-date-" + attrs.format + ".html"
        return "components/due-date/due-date-icon.html"

    return {
        link: (scope, el, attrs, ctrl) ->
            renderDatePicker = () ->
                prettyDate = $translate.instant("COMMON.PICKERDATE.FORMAT")
                if ctrl.dueDate
                    ctrl.dueDate = moment(ctrl.dueDate, prettyDate)

                el.on "click", ".date-picker-popover-trigger", (event) ->
                    if ctrl.disabled()
                        return
                    event.preventDefault()
                    event.stopPropagation()
                    el.find(".date-picker-popover").popover().open()

                el.on "click", ".date-picker-clean", (event) ->
                    event.preventDefault()
                    event.stopPropagation()
                    ctrl.dueDate = null
                    scope.$apply()
                    el.find(".date-picker-popover").popover().close()

                datePickerConfig = datePickerConfigService.get()
                _.merge(datePickerConfig, {
                    field: el.find('input.due-date')[0]
                    container: el.find('.date-picker-container')[0]
                    bound: false
                    onSelect: () ->
                        ctrl.dueDate = this.getMoment().format('YYYY-MM-DD')
                        el.find(".date-picker-popover").popover().close()
                        scope.$apply()
                })

                el.picker = new Pikaday(datePickerConfig)

            if attrs.format == 'button-popover'
                renderDatePicker()

        controller: "DueDateCtrl",
        controllerAs: "vm",
        bindToController: true,
        templateUrl: templateUrl,
        scope: {
            dueDate: '=',
            isClosed: '=',
            item: '=',
            objType: '@',
            format: '@',
            notAutoSave: '='
        }
    }

module.directive('tgDueDate', ['$translate', 'tgDatePickerConfigService', dueDateDirective])
