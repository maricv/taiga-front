###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga

# https://stackoverflow.com/questions/12371159/how-to-get-evaluated-attributes-inside-a-custom-directive
# https://stackoverflow.com/questions/18637803/how-can-i-parse-an-attribute-directive-which-has-multiple-values
# https://github.com/angular/angular.js/blob/master/src/ng/directive/ngClass.js#L146

module = angular.module("taigaBase")

LoadElementDirective = ($parse) ->
    link = ($scope, $el, $attrs) ->
        unwatch = $scope.$watch $parse($attrs.tgLoadElement), (val) ->
            if val
                legacyObj =  $parse($attrs.tgLoadElement)($scope)
                el = $el[0]

                el.component = legacyObj.component

                if legacyObj.params
                    el.params = legacyObj.params

                if legacyObj.events
                    el.events = legacyObj.events

        $scope.$on "$destroy", ->
            unwatch()

    return {
        link: link
    }

module.directive("tgLoadElement", ['$parse', LoadElementDirective])
