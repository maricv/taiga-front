###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

describe "ProjectsListingController", ->
    pageCtrl =  null
    provide = null
    controller = null
    mocks = {}

    projects = Immutable.fromJS({
        all: [
            {id: 1},
            {id: 2},
            {id: 3}
        ]
    })

    _mockCurrentUserService = () ->
        stub = sinon.stub()

        mocks.currentUserService = {
            projects: projects
        }

        provide.value "tgCurrentUserService", mocks.currentUserService

    _mockProjectsService = () ->
        stub = sinon.stub()

        provide.value "tgProjectsService", mocks.projectsService

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockCurrentUserService()

            return null

    beforeEach ->
        module "taigaProjects"

        _mocks()

        inject ($controller) ->
            controller = $controller

    it "define projects", () ->
        pageCtrl = controller "ProjectsListing",
            $scope: {}

        expect(pageCtrl.projects).to.be.equal(projects.get('all'))
