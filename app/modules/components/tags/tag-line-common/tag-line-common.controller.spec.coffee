###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

describe "TagLineCommon", ->
    provide = null
    controller = null
    TagLineCommonCtrl = null
    mocks = {}

    _mockTgTagLineService = () ->
        mocks.tgTagLineService = {
            checkPermissions: sinon.stub()
            createColorsArray: sinon.stub()
            renderTags: sinon.stub()
        }

        provide.value "tgTagLineService", mocks.tgTagLineService


    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgTagLineService()
            return null

    beforeEach ->
        module "taigaCommon"

        _mocks()

        inject ($controller) ->
            controller = $controller

        TagLineCommonCtrl = controller "TagLineCommonCtrl"
        TagLineCommonCtrl.tags = []
        TagLineCommonCtrl.colorArray = []
        TagLineCommonCtrl.addTag = false

    it "check permissions", () ->
        TagLineCommonCtrl.project = {
        }
        TagLineCommonCtrl.project.my_permissions = [
            'permission1',
            'permission2'
        ]
        TagLineCommonCtrl.permissions = 'permissions1'

        TagLineCommonCtrl.checkPermissions()
        expect(mocks.tgTagLineService.checkPermissions).have.been.calledWith(TagLineCommonCtrl.project.my_permissions, TagLineCommonCtrl.permissions)

    it "create Colors Array", () ->
        projectTagColors = 'string'
        mocks.tgTagLineService.createColorsArray.withArgs(projectTagColors).returns(true)
        TagLineCommonCtrl._createColorsArray(projectTagColors)
        expect(TagLineCommonCtrl.colorArray).to.be.equal(true)

    it "display tag input", () ->
        TagLineCommonCtrl.addTag = false
        TagLineCommonCtrl.displayTagInput()
        expect(TagLineCommonCtrl.addTag).to.be.true

    it "on add tag", () ->
        TagLineCommonCtrl.loadingAddTag = true
        tag = 'tag1'
        tags = ['tag1', 'tag2']
        color = "CC0000"

        TagLineCommonCtrl.project = {
            tags: ['tag1', 'tag2'],
            tags_colors: ["#CC0000", "CCBB00"]
        }

        TagLineCommonCtrl.onAddTag = sinon.spy()
        TagLineCommonCtrl.newTag = {name: "11", color: "22"}

        TagLineCommonCtrl.addNewTag(tag, color)

        expect(TagLineCommonCtrl.onAddTag).have.been.calledWith({name: tag, color: color})
        expect(TagLineCommonCtrl.newTag.name).to.be.eql("")
        expect(TagLineCommonCtrl.newTag.color).to.be.null
