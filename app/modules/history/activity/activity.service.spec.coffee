###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

describe "tgActivityService", ->
    $provide = null
    activityService = null
    mocks = {}

    _mockTgResources = () ->
        mocks.tgResources = {
            history: {
                getHistory: sinon.stub()
            }
        }
        $provide.value("tgResources", mocks.tgResources)

    _mockXhrErrorService = () ->
        mocks.xhrErrorService = {
            response: sinon.stub()
        }

        $provide.value "tgXhrErrorService", mocks.xhrErrorService

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockTgResources()
            _mockXhrErrorService()

            return null

    _inject = ->
        inject (_tgActivityService_) ->
            activityService = _tgActivityService_

    _setup = ->
        _mocks()
        _inject()

    beforeEach ->
        module "taigaHistory"

        _setup()

    fixtures = {
        contentType: 'foo',
        objId: 43,
        page: 1,
        response: {
            headers: sinon.stub()
            list: Immutable.List([
                {id: 1, name: 'history entry 1'},
                {id: 2, name: 'history entry 2'},
                {id: 3, name: 'history entry 3'},
            ])
        }
    }

    it "populate history entries", (done) ->
        f = fixtures
        mocks.tgResources.history.getHistory.withArgs('activity', f.contentType, f.objId, f.page)
            .promise().resolve(f.response)

        activityService.init(f.contentType, f.objId)
        expect(activityService._objectId).to.be.equal(f.objId)

        expect(activityService.entries.size).to.be.equal(0)
        activityService.fetchEntries().then () ->
            expect(activityService.entries.size).to.be.equal(3)
            done()

    it "reset history entries if objectId change", () ->
        f = fixtures
        activityService.entries = f.response.list
        expect(activityService.entries.size).to.be.equal(3)

        activityService.init(f.contentType, f.objId + 1)
        expect(activityService.entries.size).to.be.equal(0)
