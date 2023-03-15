###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga

generateHash = taiga.generateHash

resourceProvider = ($repo, $http, $urls) ->
    service = {}

    service.list = (projectId) ->
        params = {project: projectId}
        return $repo.queryMany("swimlanes", params)

    service.create = (projectId, name, order) ->
        url = $urls.resolve("swimlanes")
        params = {
            project: projectId,
            name: name,
        }
        if (order)
            params.order = order

        return $http.post(url, params)

    service.edit = (swimlaneId, name) ->
        url = $urls.resolve("swimlanes")
        url = "#{url}/#{swimlaneId}"
        params = {
            name
        }
        return $http.patch(url, params)

    service.bulkUpdateOrder = (project, swimlanesOrder) ->
        url = $urls.resolve("swimlanes")
        url = "#{url}/bulk_update_order"
        params = {
            project,
            bulk_swimlanes: swimlanesOrder
        }
        return $http.post(url, params)

    service.wipLimitUpdate = (swimlaneId, wip_limit) ->
        url = $urls.resolve("swimlane-userstory-statuses")
        url = "#{url}/#{swimlaneId}"
        params = {
            wip_limit
        }
        return $http.patch(url, params)

    service.delete = (swimlaneId, moveTo) ->
        url = $urls.resolve("swimlanes")
        if (moveTo)
            url = "#{url}/#{swimlaneId}?moveTo=#{moveTo}"
        else
            url = "#{url}/#{swimlaneId}"
        return $http.delete(url)

    return (instance) ->
        instance.swimlanes = service


module = angular.module("taigaResources")
module.factory("$tgSwimlanesResourcesProvider", ["$tgRepo", "$tgHttp", "$tgUrls", resourceProvider])
