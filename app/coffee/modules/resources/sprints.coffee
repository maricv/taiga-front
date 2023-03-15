###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga

generateHash = taiga.generateHash

resourceProvider = ($repo, $model, $storage, $http, $urls) ->
    service = {}

    service.get = (projectId, sprintId) ->
        return $repo.queryOne("milestones", sprintId).then (sprint) ->
            uses = sprint.user_stories
            uses = _.map(uses, (u) -> $model.make_model("userstories", u))
            sprint._attrs.user_stories = uses
            return sprint

    service.stats = (projectId, sprintId) ->
        return $repo.queryOneRaw("milestones", "#{sprintId}/stats")

    service.list = (projectId, filters) ->
        params = {"project": projectId}
        params = _.extend({}, params, filters or {})
        return $repo.queryMany("milestones", params, {}, true).then (result) =>
            milestones = result[0]
            headers = result[1]

            for m in milestones
                uses = m.user_stories
                uses = _.map(uses, (u) => $model.make_model("userstories", u))
                m._attrs.user_stories = uses

            return {
                milestones: milestones,
                closed: parseInt(headers("Taiga-Info-Total-Closed-Milestones"), 10),
                open: parseInt(headers("Taiga-Info-Total-Opened-Milestones"), 10)
            }

    service.moveUserStoriesMilestone = (currentMilestoneId, projectId, milestoneId, data) ->
        url = $urls.resolve("move-userstories-to-milestone", currentMilestoneId)
        params = {project_id: projectId, milestone_id: milestoneId, bulk_stories: data}
        return $http.post(url, params)

    service.moveTasksMilestone = (currentMilestoneId, projectId, milestoneId, data) ->
        url = $urls.resolve("move-tasks-to-milestone", currentMilestoneId)
        params = {project_id: projectId, milestone_id: milestoneId, bulk_tasks: data}
        return $http.post(url, params)

    service.moveIssuesMilestone = (currentMilestoneId, projectId, milestoneId, data) ->
        url = $urls.resolve("move-issues-to-milestone", currentMilestoneId)
        params = {project_id: projectId, milestone_id: milestoneId, bulk_issues: data}
        return $http.post(url, params)

    return (instance) ->
        instance.sprints = service

module = angular.module("taigaResources")
module.factory("$tgSprintsResourcesProvider",
["$tgRepo", "$tgModel", "$tgStorage", "$tgHttp", "$tgUrls", resourceProvider])
