###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

@taiga = taiga = {}
taiga.emojis = window.emojis
@.taigaContribPlugins = @.taigaContribPlugins or window.taigaContribPlugins or []

# Generic function for generate hash from a arbitrary length
# collection of parameters.
taiga.generateHash = (components=[]) ->
    components = _.map(components, (x) -> JSON.stringify(x))
    return hex_sha1(components.join(":"))


taiga.generateUniqueSessionIdentifier = ->
    date = (new Date()).getTime()
    randomNumber = Math.floor(Math.random() * 0x9000000)
    return taiga.generateHash([date, randomNumber])


taiga.sessionId = taiga.generateUniqueSessionIdentifier()

oldWindowOpen = window.open

window.open = (url, name, config) =>
    if url.startsWith('/')
        url = document.baseURI + url

    oldWindowOpen(url)

configure = ($routeProvider, $locationProvider, $httpProvider, $provide, $tgEventsProvider, $compileProvider,
             $translateProvider, $translatePartialLoaderProvider, $animateProvider, $logProvider) ->

    $animateProvider.classNameFilter(/^(?:(?!ng-animate-disabled).)*$/)

    # wait until the translation is ready to resolve the page
    originalWhen = $routeProvider.when

    $routeProvider.when = (path, route) ->
        route.resolve || (route.resolve = {})
        angular.extend(route.resolve, {
            languageLoad: ["$q", "$translate", ($q, $translate) ->
                deferred = $q.defer()

                $translate("COMMON.YES").then () -> deferred.resolve()

                return deferred.promise
            ],
            projectLoaded: ["$q", "tgProjectService", "$route", ($q, projectService, $route) ->
                deferred = $q.defer()

                projectService.setSection($route.current.$$route?.section)

                if $route.current.params.pslug
                    projectService.setProjectBySlug($route.current.params.pslug).then(deferred.resolve)
                else
                    projectService.cleanProject()
                    deferred.resolve()

                return deferred.promise
            ]
        })

        return originalWhen.call($routeProvider, path, route)

    # Home
    $routeProvider.when("/",
        {
            templateUrl: "home/home.html",
            controller: "Home",
            controllerAs: "vm"
            loader: true,
            title: "HOME.PAGE_TITLE",
            loader: true,
            description: "HOME.PAGE_DESCRIPTION",
            joyride: "dashboard"
        }
    )

    # Discover
    $routeProvider.when("/discover",
        {
            templateUrl: "discover/discover-home/discover-home.html",
            controller: "DiscoverHome",
            controllerAs: "vm",
            title: "PROJECT.NAVIGATION.DISCOVER",
            loader: true
        }
    )

    $routeProvider.when("/discover/search",
        {
            templateUrl: "discover/discover-search/discover-search.html",
            title: "PROJECT.NAVIGATION.DISCOVER",
            loader: true,
            controller: "DiscoverSearch",
            controllerAs: "vm",
            reloadOnSearch: false
        }
    )

    # My Projects
    $routeProvider.when("/projects/",
        {
            templateUrl: "projects/listing/projects-listing.html",
            access: {
                requiresLogin: true
            },
            title: "PROJECTS.PAGE_TITLE",
            description: "PROJECTS.PAGE_DESCRIPTION",
            loader: true,
            controller: "ProjectsListing",
            controllerAs: "vm"
        }
    )

    # Project
    $routeProvider.when("/project/new",
        {
            title: "PROJECT.CREATE.TITLE",
            templateUrl: "projects/create/create-project.html",
            loader: true,
            controller: "CreateProjectCtrl",
            controllerAs: "vm"
        }
    )

    # Project - scrum
    $routeProvider.when("/project/new/scrum",
        {
            title: "PROJECT.CREATE.TITLE",
            template: "<tg-create-project-form type=\"scrum\"></tg-create-project-form>",
            loader: true
        }
    )

    # Project - kanban
    $routeProvider.when("/project/new/kanban",
        {
            title: "PROJECT.CREATE.TITLE",
            template: "<tg-create-project-form type=\"kanban\"></tg-create-project-form>",
            loader: true
        }
    )

    # Project - duplicate
    $routeProvider.when("/project/new/duplicate",
        {
            title: "PROJECT.CREATE.TITLE",
            template: "<tg-duplicate-project></tg-duplicate-project>",
            loader: true
        }
    )

    # Project - import
    $routeProvider.when("/project/new/import/:platform?",
        {
            title: "PROJECT.CREATE.TITLE",
            template: "<tg-import-project></tg-import-project>",
            loader: true
        }
    )

    # Project
    $routeProvider.when("/project/:pslug/",
        {
            template: "",
            loader: true,
            controller: "ProjectRouter"
        }
    )

    # Project
    $routeProvider.when("/project/:pslug/timeline",
        {
            templateUrl: "projects/project/project.html",
            loader: true,
            controller: "Project",
            controllerAs: "vm"
            section: "project-timeline"
        }
    )

    # Project ref detail
    $routeProvider.when("/project/:pslug/t/:ref",
        {
            loader: true,
            controller: "DetailController",
            template: ""
        }
    )

    $routeProvider.when("/project/:pslug/search",
        {
            templateUrl: "search/search.html",
            reloadOnSearch: false,
            section: "search",
            loader: true
        }
    )

    # Epics
    $routeProvider.when("/project/:pslug/epics",
        {
            section: "epics",
            templateUrl: "epics/dashboard/epics-dashboard.html",
            loader: true,
            controller: "EpicsDashboardCtrl",
            controllerAs: "vm"
        }
    )

    $routeProvider.when("/project/:pslug/epic/:epicref",
        {
            templateUrl: "epic/epic-detail.html",
            loader: true,
            section: "epics"
        }
    )

    $routeProvider.when("/project/:pslug/backlog",
        {
            templateUrl: "backlog/backlog.html",
            loader: true,
            section: "backlog",
            joyride: "backlog"
        }
    )

    $routeProvider.when("/project/:pslug/kanban",
        {
            templateUrl: "kanban/kanban.html",
            loader: true,
            section: "kanban",
            joyride: "kanban"
        }
    )

    # Milestone
    $routeProvider.when("/project/:pslug/taskboard/:sslug",
        {
            templateUrl: "taskboard/taskboard.html",
            loader: true,
            section: "backlog"
        }
    )

    # User stories
    $routeProvider.when("/project/:pslug/us/:usref",
        {
            templateUrl: "us/us-detail.html",
            loader: true,
            section: "backlog-kanban"
        }
    )

    # Tasks
    $routeProvider.when("/project/:pslug/task/:taskref",
        {
            templateUrl: "task/task-detail.html",
            loader: true,
            section: "backlog-kanban"
        }
    )

    # Wiki
    $routeProvider.when("/project/:pslug/wiki",
        {redirectTo: (params) -> "/project/#{params.pslug}/wiki/home"}, )
    $routeProvider.when("/project/:pslug/wiki-list",
        {
            templateUrl: "wiki/wiki-list.html",
            loader: true,
            section: "wiki"
        }
    )
    $routeProvider.when("/project/:pslug/wiki/:slug",
        {
            templateUrl: "wiki/wiki.html",
            loader: true,
            section: "wiki"
        }
    )

    # Team
    $routeProvider.when("/project/:pslug/team",
        {
            templateUrl: "team/team.html",
            loader: true,
            section: "team"
        }
    )

    # Issues
    $routeProvider.when("/project/:pslug/issues",
        {
            templateUrl: "issue/issues.html",
            loader: true,
            section: "issues"
        }
    )
    $routeProvider.when("/project/:pslug/issue/:issueref",
        {
            templateUrl: "issue/issues-detail.html",
            loader: true,
            section: "issues"
        }
    )

    # Admin - Project Profile
    $routeProvider.when("/project/:pslug/admin/project-profile/details",
        {
            templateUrl: "admin/admin-project-profile.html",
            section: "admin"
        }
    )
    $routeProvider.when("/project/:pslug/admin/project-profile/default-values",
        {
            templateUrl: "admin/admin-project-default-values.html",
            section: "admin"
        }
    )
    $routeProvider.when("/project/:pslug/admin/project-profile/modules",
        {
            templateUrl: "admin/admin-project-modules.html",
            section: "admin"
        }
    )
    $routeProvider.when("/project/:pslug/admin/project-profile/export",
        {
            templateUrl: "admin/admin-project-export.html",
            section: "admin"
        }
    )
    $routeProvider.when("/project/:pslug/admin/project-profile/reports",
        {
            templateUrl: "admin/admin-project-reports.html",
            section: "admin"
        }
    )

    $routeProvider.when("/project/:pslug/admin/project-values/status",
        {
            templateUrl: "admin/admin-project-values-status.html",
            section: "admin"
        }
    )
    $routeProvider.when("/project/:pslug/admin/project-values/points",
        {
            templateUrl: "admin/admin-project-values-points.html",
            section: "admin"
        }
    )
    $routeProvider.when("/project/:pslug/admin/project-values/priorities",
        {
            templateUrl: "admin/admin-project-values-priorities.html",
            section: "admin"
        }
    )
    $routeProvider.when("/project/:pslug/admin/project-values/severities",
        {
            templateUrl: "admin/admin-project-values-severities.html",
            section: "admin"
        }
    )
    $routeProvider.when("/project/:pslug/admin/project-values/types",
        {
            templateUrl: "admin/admin-project-values-types.html",
            section: "admin"
        }
    )
    $routeProvider.when("/project/:pslug/admin/project-values/custom-fields",
        {
            templateUrl: "admin/admin-project-values-custom-fields.html",
            section: "admin"
        }
    )
    $routeProvider.when("/project/:pslug/admin/project-values/tags",
        {
            templateUrl: "admin/admin-project-values-tags.html",
            section: "admin"
        }
    )
    $routeProvider.when("/project/:pslug/admin/project-values/due-dates",
        {
            templateUrl: "admin/admin-project-values-due-dates.html",
            section: "admin"
        }
    )
    $routeProvider.when("/project/:pslug/admin/project-values/kanban-power-ups",
        {
            templateUrl: "admin/admin-project-values-kanban-power-ups.html",
            section: "admin"
        }
    )
    $routeProvider.when("/project/:pslug/admin/memberships",
        {
            templateUrl: "admin/admin-memberships.html",
            section: "admin"
        }
    )
    # Admin - Roles
    $routeProvider.when("/project/:pslug/admin/roles",
        {
            templateUrl: "admin/admin-roles.html",
            section: "admin"
        }
    )

    # Admin - Third Parties
    $routeProvider.when("/project/:pslug/admin/third-parties/webhooks",
        {
            templateUrl: "admin/admin-third-parties-webhooks.html",
            section: "admin"
        }
    )
    $routeProvider.when("/project/:pslug/admin/third-parties/github",
        {
            templateUrl: "admin/admin-third-parties-github.html",
            section: "admin"
        }
    )
    $routeProvider.when("/project/:pslug/admin/third-parties/gitlab",
        {
            templateUrl: "admin/admin-third-parties-gitlab.html",
            section: "admin"
        }
    )
    $routeProvider.when("/project/:pslug/admin/third-parties/bitbucket",
        {
            templateUrl: "admin/admin-third-parties-bitbucket.html",
            section: "admin"
        }
    )
    $routeProvider.when("/project/:pslug/admin/third-parties/gogs",
        {
            templateUrl: "admin/admin-third-parties-gogs.html",
            section: "admin"
        }
    )
    # Admin - Contrib Plugins
    $routeProvider.when("/project/:pslug/admin/contrib/:plugin",
        {templateUrl: "contrib/main.html"})

    # Transfer project
    $routeProvider.when("/project/:pslug/transfer/:token",
        {
            templateUrl: "projects/transfer/transfer-page.html",
            loader: true,
            controller: "Project",
            controllerAs: "vm"
        }
    )

    # User settings
    $routeProvider.when("/user-settings/user-profile",
        {templateUrl: "user/user-profile.html"})
    $routeProvider.when("/user-settings/user-change-password",
        {templateUrl: "user/user-change-password.html"})
    $routeProvider.when("/user-settings/user-project-settings",
        {templateUrl: "user/user-project-settings.html"})
    $routeProvider.when("/user-settings/mail-notifications",
        {templateUrl: "user/mail-notifications.html"})
    $routeProvider.when("/user-settings/live-notifications",
        {templateUrl: "user/live-notifications.html"})
    $routeProvider.when("/user-settings/web-notifications",
        {templateUrl: "user/web-notifications.html"})
    $routeProvider.when("/change-email/:email_token",
        {templateUrl: "user/change-email.html"})
    $routeProvider.when("/verify-email/:email_token",
        {templateUrl: "user/verify-email.html"})
    $routeProvider.when("/cancel-account/:cancel_token",
        {templateUrl: "user/cancel-account.html"})

    # UserSettings - Contrib Plugins
    $routeProvider.when("/user-settings/contrib/:plugin",
        {templateUrl: "contrib/user-settings.html"})

    # User profile
    $routeProvider.when("/profile",
        {
            templateUrl: "profile/profile.html",
            loader: true,
            access: {
                requiresLogin: true
            },
            controller: "Profile",
            controllerAs: "vm"
        }
    )

    # Notifications
    $routeProvider.when("/notifications",
        {
            templateUrl: "notifications/notifications.html",
            loader: true,
            access: {
                requiresLogin: true
            },
            controller: "Notifications",
            controllerAs: "vm"
        }
    )

    $routeProvider.when("/profile/:slug",
        {
            templateUrl: "profile/profile.html",
            loader: true,
            controller: "Profile",
            controllerAs: "vm"
        }
    )

    # Auth
    $routeProvider.when("/login",
        {
            templateUrl: "auth/login.html",
            title: "LOGIN.PAGE_TITLE",
            description: "LOGIN.PAGE_DESCRIPTION",
            disableHeader: true,
            controller: "LoginPage",
        }
    )
    if window.taigaConfig.publicRegisterEnabled
        $routeProvider.when("/register",
            {
                templateUrl: "auth/register.html",
                title: "REGISTER.PAGE_TITLE",
                description: "REGISTER.PAGE_DESCRIPTION",
                disableHeader: true
            }
        )
    $routeProvider.when("/forgot-password",
        {
            templateUrl: "auth/forgot-password.html",
            title: "FORGOT_PASSWORD.PAGE_TITLE",
            description: "FORGOT_PASSWORD.PAGE_DESCRIPTION",
            disableHeader: true
        }
    )
    $routeProvider.when("/change-password/:token",
        {
            templateUrl: "auth/change-password-from-recovery.html",
            title: "CHANGE_PASSWORD.PAGE_TITLE",
            description: "CHANGE_PASSWORD.PAGE_TITLE",
            disableHeader: true
        }
    )
    $routeProvider.when("/invitation/:token",
        {
            templateUrl: "auth/invitation.html",
            title: "INVITATION.PAGE_TITLE",
            description: "INVITATION.PAGE_DESCRIP