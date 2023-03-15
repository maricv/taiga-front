###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga
bindOnce = @.taiga.bindOnce
debounce = @.taiga.debounce

module = angular.module("taigaUserSettings")


#############################################################################
## Delete User Lightbox Directive
#############################################################################

DeleteUserDirective = ($repo, $rootscope, $auth, $location, $navUrls, lightboxService, $loading) ->
    link = ($scope, $el, $attrs) ->
        $scope.$on "deletelightbox:new", (ctx, user)->
            lightboxService.open($el)

        $scope.$on "$destroy", ->
            $el.off()

        submit = ->
            currentLoading = $loading()
                .target(submitButton)
                .start()

            promise = $repo.remove($scope.user)

            promise.then (data) ->
                currentLoading.finish()
                lightboxService.close($el)
                $auth.logout()
                $location.path($navUrls.resolve("login"))

            # FIXME: error handling?
            promise.then null, ->
                currentLoading.finish()
                console.log "FAIL"

        $el.on "click", ".js-cancel", (event) ->
            event.preventDefault()
            lightboxService.close($el)

        $el.on "click", ".js-confirm", debounce 2000, (event) ->
            event.preventDefault()
            submit()

        submitButton = $el.find(".js-confirm")

    return {
        link: link,
        templateUrl: "user/lightbox/lightbox-delete-account.html"
    }

module.directive("tgLbDeleteUser", ["$tgRepo", "$rootScope", "$tgAuth", "$tgLocation", "$tgNavUrls",
                                    "lightboxService", "$tgLoading", DeleteUserDirective])
