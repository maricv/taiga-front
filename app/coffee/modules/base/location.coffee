###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

locationFactory = ($location, $route, $rootscope) ->
    $location.noreload =  (scope) ->
        lastRoute = $route.current
        un = scope.$on "$locationChangeSuccess", ->
            $route.current = lastRoute
            un()

        return $location

    $location.isInCurrentRouteParams = (name, value) ->
        params = $location.search() || {}

        return params[name] == value

    return $location


module = angular.module("taigaBase")
module.factory("$tgLocation", ["$location", "$route", "$rootScope", locationFactory])
