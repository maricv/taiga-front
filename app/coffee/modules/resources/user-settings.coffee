###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga
sizeFormat = @.taiga.sizeFormat


resourceProvider = ($config, $repo, $http, $urls, $q) ->
    service = {}

    service.changeAvatar = (file) ->
        maxFileSize = $config.get("maxUploadFileSize", null)
        if maxFileSize and file.size > maxFileSize
            response = {
                status: 413,
                data: _error_message: "'#{file.name}' (#{sizeFormat(file.size)}) is too heavy for our oompa
                                       loompas, try it with a smaller than (#{sizeFormat(maxFileSize)})"
            }
            defered = $q.defer()
            defered.reject(response)
            return defered.promise

        data = new FormData()
        data.append('avatar', file)
        options = {
            transformRequest: angular.identity,
            headers: {'Content-Type': undefined}
        }
        url = "#{$urls.resolve("users")}/change_avatar"
        return $http.post(url, data, {}, options)

    service.removeAvatar = () ->
        url = "#{$urls.resolve("users")}/remove_avatar"
        return $http.post(url)

    service.changePassword = (currentPassword, newPassword) ->
        url = "#{$urls.resolve("users")}/change_password"
        data = {
            current_password: currentPassword
            password: newPassword
        }
        return $http.post(url, data)

    return (instance) ->
        instance.userSettings = service


module = angular.module("taigaResources")
module.factory("$tgUserSettingsResourcesProvider", ["$tgConfig", "$tgRepo", "$tgHttp", "$tgUrls", "$q",
                                                    resourceProvider])
