###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

describe "MostLiked", ->
    $provide = null
    $controller = null
    mocks = {}

    _mockDiscoverProjectsService = ->
        mocks.discoverProjectsService = {
            fetchMostLiked: sinon.stub()
        }

        $provide.value("tgDiscoverProjectsService", mocks.discoverProjectsService)

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockDiscoverProjectsService()

            return null

    _inject = ->
        inject (_$controller_) ->
            $controller = _$controller_

    _setup = ->
        _mocks()
        _inject()

    beforeEach ->
        module "taigaDiscover"

        _setup()

    it "fetch", (done) ->
        ctrl = $controller("MostLiked")

        ctrl.getOrderBy = sinon.stub().returns('week')

        mockPromise = mocks.discoverProjectsService.fetchMostLiked.withArgs(sinon.match({order_by: 'week'})).promise()

        promise = ctrl.fetch()

        expect(ctrl.loading).to.be.true

        mockPromise.resolve()

        promise.finally () ->
            expect(ctrl.loading).to.be.false
            done()


    it "order by", () ->
        ctrl = $controller("MostLiked")

        ctrl.fetch = sinon.spy()

        ctrl.orderBy('month')

        expect(ctrl.fetch).to.have.been.called
        expect(ctrl.currentOrderBy).to.be.equal('month')
