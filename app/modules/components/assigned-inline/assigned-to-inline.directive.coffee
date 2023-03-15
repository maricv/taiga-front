###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

AssignedToInlineDirective = ($rootscope, $confirm, $repo, $loading, $modelTransform, $template
$translate, $compile, $currentUserService, avatarService, $userListService) ->
    link = ($scope, $el, $attr, $model) ->
        isEditable = ->
            return $scope.project?.my_permissions?.indexOf($attr.requiredPerm) != -1

        renderUserList = (text) ->
            selectedId = $model.$modelValue.assigned_to
            users = $userListService.searchUsers(text)
            users = _.reject(users, {"id": selectedId}) if selectedId

            visibleUsers = _.slice(users, 0, 5)
            visibleUsers = _.map visibleUsers, (user) -> user.avatar = avatarService.getAvatar(user)

            $scope.users = _.slice(users, 0, 5)
            $scope.showMore = users.length > 5

        renderUser = (assignedObject) ->
            if assignedObject?.assigned_to
                $scope.selected = assignedObject.assigned_to
                assigned_to_extra_info = $scope.usersById[$scope.selected]
                $scope.fullName = assigned_to_extra_info?.full_name_display
                $scope.isUnassigned = false
                $scope.avatar = avatarService.getAvatar(assigned_to_extra_info)
                $scope.bg = $scope.avatar.bg
                $scope.isIocaine = assignedObject?.is_iocaine
            else
                $scope.fullName = $translate.instant("COMMON.ASSIGNED_TO.ASSIGN")
                $scope.isUnassigned = true
                $scope.avatar = avatarService.getAvatar(null)
                $scope.bg = null
                $scope.isIocaine = false

            $scope.fullNameVisible = !($scope.isUnassigned && !$currentUserService.isAuthenticated())
            $scope.isEditable = isEditable()

        $el.on "click", ".users-search", (event) ->
            event.stopPropagation()

        $el.on "click", ".users-dropdown", (event) ->
            event.preventDefault()
            event.stopPropagation()
            $scope.usersSearch = ""
            renderUserList()
            $scope.$apply()
            $el.find(".pop-users").popover().open()

        $scope.selfAssign = () ->
            $model.$modelValue.assigned_to = $currentUserService.getUser().get('id')
            renderUser($model.$modelValue)

        $scope.unassign = () ->
            $model.$modelValue.assigned_to  = null
            renderUser()

        $scope.$watch "usersSearch", (searchingText) ->
            if searchingText?
                renderUserList(searchingText)
                $el.find('input').focus()

        $el.on "click", ".user-list-single", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            $model.$modelValue.assigned_to = target.data("user-id")
            renderUser($model.$modelValue)
            $scope.$apply()

        $scope.$watch $attr.ngModel, (instance) ->
            renderUser(instance)

        $scope.$on "isiocaine:changed", (ctx, instance) ->
            renderUser(instance)

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link:link,
        templateUrl: "components/assigned-inline/assigned-to-inline.html"
        require:"ngModel"
    }

angular.module('taigaComponents').directive("tgAssignedToInline", ["$rootScope", "$tgConfirm",
"$tgRepo", "$tgLoading", "$tgQueueModelTransformation", "$tgTemplate", "$translate", "$compile",
"tgCurrentUserService", "tgAvatarService", "tgUserListService", AssignedToInlineDirective])
