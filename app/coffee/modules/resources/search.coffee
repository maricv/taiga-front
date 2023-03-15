###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga

resourceProvider = ($repo, $urls, $http, $q) ->
    service = {}

    service.do = (projectId, term) ->
        deferredAbort = $q.defer()

        url = $urls.resolve("search")
        params = {
            url: url,
            method: "GET",
            timeout: deferredAbort.promise,
            cancelable: true,
            params: {
                project: projectId
                text: term,
                get_all: false,
            }
        }

        request = $http.request(params).then (data) ->
            return data.data

        request.abort = () ->
            deferredAbort.resolve()

        request.finally = () ->
            request.abort = angular.noop
            deferredAbort = request = null

        return request

    return (instance) ->
        instance.search = service

module = angular.module("taigaResources")
module.factory("$tgSearchResourcesProvider", ["$tgRepo", "$tgUrls", "$tgHttp", "$q", resourceProvider])
