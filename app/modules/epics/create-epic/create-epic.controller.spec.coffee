###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

describe "EpicRow", ->
    createEpicCtrl =  null
    provide = null
    controller = null
    mocks = {}

    _mockTgConfirm = () ->
        mocks.tgConfirm = {
            notify: sinon.stub()
        }
        provide.value "$tgConfirm", mocks.tgConfirm

    _mockTgProjectService = () ->
        mocks.tgProjectService = {
            project: {
                toJS: sinon.stub()
            }
        }
        provide.value "tgProjectService", mocks.tgProjectService

    _mockTgEpicsService = () ->
        mocks.tgEpicsService = {
            createEpic: sinon.stub()
        }
        provide.value "tgEpicsService", mocks.tgEpicsService

    _mockTgAnalytics = ->
        mocks.tgAnalytics = {
            trackEvent: sinon.stub()
        }

        provide.value("$tgAnalytics", mocks.tgAnalytics)

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgConfirm()
            _mockTgProjectService()
            _mockTgEpicsService()
            _mockTgAnalytics()
            return null

    beforeEach ->
        module "taigaEpics"

        _mocks()

        inject ($controller) ->
            controller = $controller

    it "create Epic with invalid form", () ->
        mocks.tgProjectService.project.toJS.withArgs().returns(
            {id: 1, default_epic_status: 1}
        )

        data = {
            validateForm: sinon.stub()
            setFormErrors: sinon.stub()
            onCreateEpic: sinon.stub()
        }
        createEpicCtrl = controller "CreateEpicCtrl", null, data
        createEpicCtrl.attachments = Immutable.List([{file: "file1"}, {file: "file2"}])

        data.validateForm.withArgs().returns(false)

        createEpicCtrl.createEpic()

        expect(data.validateForm).have.been.called
        expect(mocks.tgEpicsService.createEpic).not.have.been.called

    it "create Epic successfully", (done) ->
        mocks.tgProjectService.project.toJS.withArgs().returns(
            {id: 1, default_epic_status: 1}
        )

        data = {
            validateForm: sinon.stub()
            setFormErrors: sinon.stub()
            onCreateEpic: sinon.stub()
        }
        createEpicCtrl = controller "CreateEpicCtrl", null, data
        createEpicCtrl.attachments = Immutable.List([{file: "file1"}, {file: "file2"}])

        data.validateForm.withArgs().returns(true)
        mocks.tgEpicsService.createEpic
            .withArgs(
                createEpicCtrl.newEpic,
                createEpicCtrl.attachments)
            .promise()
            .resolve(
                {data: {id: 1, project: 1}}
            )

        createEpicCtrl.createEpic().then () ->
            expect(data.validateForm).have.been.called
            expect(createEpicCtrl.onCreateEpic).have.been.called
            done()
