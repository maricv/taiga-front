###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

describe "RelatedUserStories", ->
    RelatedUserStoriesCtrl =  null
    provide = null
    controller = null
    mocks = {}

    _mockTgEpicsService = () ->
        mocks.tgEpicsService = {
            listRelatedUserStories: sinon.stub()
            reorderRelatedUserstory: sinon.stub()
        }

        provide.value "tgEpicsService", mocks.tgEpicsService

    _mockTgProjectService = () ->
        mocks.tgProjectService = {
            hasPermission: sinon.stub()
        }
        provide.value "tgProjectService", mocks.tgProjectService

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgEpicsService()
            _mockTgProjectService()
            return null

    beforeEach ->
        module "taigaEpics"

        _mocks()

        inject ($controller) ->
            controller = $controller

    it "load related userstories", (done) ->
        ctrl = controller "RelatedUserStoriesCtrl"
        userstories = Immutable.fromJS([
            {
                id: 1
            }
        ])

        ctrl.epic = Immutable.fromJS({
            id: 66
        })

        promise = mocks.tgEpicsService.listRelatedUserStories
            .withArgs(ctrl.epic)
            .promise()
            .resolve(userstories)

        ctrl.loadRelatedUserstories().then () ->
            expect(ctrl.userstories).is.equal(userstories)
            done()

    it "reorderRelatedUserstory", (done) ->
        ctrl = controller "RelatedUserStoriesCtrl"
        userstories = Immutable.fromJS([
            {
                id: 1
            },
            {
                id: 2
            }
        ])

        reorderedUserstories = Immutable.fromJS([
            {
                id: 2
            },
            {
                id: 1
            }
        ])

        ctrl.epic = Immutable.fromJS({
            id: 66
        })

        promise = mocks.tgEpicsService.reorderRelatedUserstory
            .withArgs(ctrl.epic, ctrl.userstories, userstories.get(1), 0)
            .promise()
            .resolve(reorderedUserstories)

        ctrl.reorderRelatedUserstory(userstories.get(1), 0).then () ->
            expect(ctrl.userstories).is.equal(reorderedUserstories)
            done()
