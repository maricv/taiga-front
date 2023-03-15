###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga

class HttpService extends taiga.Service
    @.$inject = ["$http", "$q", "tgLoader", "$tgStorage", "$rootScope", "$cacheFactory", "$translate"]

    constructor: (@http, @q, @tgLoader, @storage, @rootScope, @cacheFactory, @translate) ->
        super()
        @.cache = @cacheFactory("httpget")
    headers: ->
        headers = {}

        # Authorization
        token = @storage.get('token')
        if token
            headers["Authorization"] = "Bearer #{token}"

        # Accept-Language
        lang = @translate.preferredLanguage()
        if lang
            headers["Accept-Language"] = lang

        return headers

    request: (options) ->
        options.headers = _.assign({}, options.headers or {}, @.headers())

        return @http(options)

    get: (url, params, options) ->
        options = _.assign({method: "GET", url: url}, options)
        options.params = params if params

        # prevent duplicated http request
        options.cache = @.cache

        return @.request(options).finally (data) =>
            @.cache.removeAll()

    post: (url, data, params, options) ->
        options = _.assign({method: "POST", url: url}, options)

        options.data = data if data
        options.params = params if params
        options.responseType = 'text'

        return @.request(options)

    put: (url, data, params, options) ->
        options = _.assign({method: "PUT", url: url}, options)
        options.data = data if data
        options.params = params if params
        return @.request(options)

    patch: (url, data, params, options) ->
        options = _.assign({method: "PATCH", url: url}, options)
        options.data = data if data
        options.params = params if params
        return @.request(options)

    delete: (url, data, params, options) ->
        options = _.assign({method: "DELETE", url: url}, options)
        options.data = data if data
        options.params = params if params
        return @.request(options)


module = angular.module("taigaBase")
module.service("$tgHttp", HttpService)
