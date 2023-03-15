/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright (c) 2021-present Kaleidos Ventures SL
 */

var utils = require('../../../utils');

var adminIntegrationsHelper = require('../../../helpers').adminIntegrations;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('admin - webhooks', function() {
    before(async function(){
        browser.get(browser.params.glob.host + 'project/project-3/admin/third-parties/webhooks');

        await utils.common.waitLoader();

        utils.common.takeScreenshot('integrations', 'webhooks');
    });

    it('error - empty', async function() {
        await adminIntegrationsHelper.saveWebHook('', '', '');

        utils.common.takeScreenshot('integrations', 'webhooks-errors');

        let errorsCount = await adminIntegrationsHelper.getErrors().count();

        expect(errorsCount).to.be.equal(3);
    });

    it('error - invalid url', async function() {
        await adminIntegrationsHelper.saveWebHook('ooo', 'iii', 'uuuu');

        utils.common.takeScreenshot('integrations', 'webhooks-invalid-url');

        let errorsCount = await adminIntegrationsHelper.getErrors().count();

        expect(errorsCount).to.be.equal(1);
    });

    it('valid', async function() {
        await adminIntegrationsHelper.saveWebHook('ooo', 'http://web.fake', 'uuuu');

        utils.common.takeScreenshot('integrations', 'webhooks-invalid-url');

        let webHookIsPresent = await adminIntegrationsHelper.currentWebHookIsPresent();

        expect(webHookIsPresent).to.be.true;
    });

    it('edit', async function() {
        adminIntegrationsHelper.openEditModeWebHook();

        await adminIntegrationsHelper.saveWebHook('111', 'http://web2.fake', '333');

        let webHookMode = await adminIntegrationsHelper.getWebHookMode();

        expect(webHookMode).to.be.equal('read');
    });

    it('delete', async function() {
        await adminIntegrationsHelper.deleteWebhook();

        let webHookIsPresent = await adminIntegrationsHelper.currentWebHookIsPresent();

        expect(webHookIsPresent).to.be.false;
    });
});
