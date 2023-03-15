###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga

groupBy = @.taiga.groupBy
bindOnce = @.taiga.bindOnce
mixOf = @.taiga.mixOf
debounce = @.taiga.debounce
trim = @.taiga.trim

module = angular.module("taigaFeedback", [])

FeedbackDirective = ($lightboxService, $repo, $confirm, $loading, feedbackService)->
    link = ($scope, $el, $attrs) ->
        form = $el.find("form").checksley()

        submit = debounce 2000, (event) =>
            event.preventDefault()

            if not form.validate()
                return

            currentLoading = $loading()
                .target(submitButton)
                .start()

            promise = $repo.create("feedback", $scope.feedback)

            promise.then (data) ->
                currentLoading.finish()
                $lightboxService.close($el)
                $confirm.notify("success", "\\o/ we'll be happy to read your")

            promise.then null, ->
                currentLoading.finish()
                $confirm.notify("error")

        submitButton = $el.find(".submit-button")

        $el.on "submit", "form", submit

        openLightbox = ->
            $scope.feedback = {}
            $lightboxService.open($el)
            $el.find("textarea").focus()

        $scope.$on "$destroy", ->
            $el.off()

        openLightbox()

    directive = {
        link: link,
        templateUrl: "common/lightbox-feedback.html"
        scope: {}
    }

    return directive

module.directive("tgLbFeedback", ["lightboxService", "$tgRepo", "$tgConfirm",
    "$tgLoading", "tgFeedbackService", FeedbackDirective])
