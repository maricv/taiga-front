###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

Resource = (urlsService, http) ->
    service = {}

    service.listInAllProjects = (params, pagination=false) ->
        url = urlsService.resolve("userstories")

        if !pagination
            httpOptions = {
                headers: {
                    "x-disable-pagination": "1"
                }
            }

        return http.get(url, params, httpOptions)
            .then (result) ->
                return Immutable.fromJS(result.data)

    service.listAllInProject = (projectId) ->
        url = urlsService.resolve("userstories")

        httpOptions = {
            headers: {
                "x-disable-pagination": "1"
            }
        }

        params = {
            project: projectId
        }

        return http.get(url, params, httpOptions)
            .then (result) ->
                return Immutable.fromJS(result.data)

    service.listInEpic = (epicIid) ->
        url = urlsService.resolve("userstories")

        httpOptions = {
            headers: {
                "x-disable-pagination": "1"
            }
        }

        params = {
            epic: epicIid,
            order_by: 'epic_order',
            include_tasks: true
        }

        return http.get(url, params, httpOptions)
            .then (result) ->
                return Immutable.fromJS(result.data)

    return () ->
        return {"userstories": service}

Resource.$inject = ["$tgUrls", "$tgHttp"]

module = angular.module("taigaResources2")
module.factory("tgUserstoriesResource", Resource)
