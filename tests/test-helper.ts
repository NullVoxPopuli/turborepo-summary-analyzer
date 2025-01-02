import Application from 'turborepo-summary-analyzer/app';
import config from 'turborepo-summary-analyzer/config/environment';
import * as QUnit from 'qunit';
import { setApplication } from '@ember/test-helpers';
import { setup } from 'qunit-dom';
import { start as qunitStart } from 'ember-qunit';

export function start() {
  setApplication(Application.create(config.APP));

  setup(QUnit.assert);

  qunitStart({ loadTests: false });
}
