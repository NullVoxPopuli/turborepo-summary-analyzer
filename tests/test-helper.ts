import Application from 'turborepo-summary-analyzer/app';
import config, { enterTestMode } from '../app/config.ts';
import * as QUnit from 'qunit';
import { setApplication } from '@ember/test-helpers';
import { setup } from 'qunit-dom';
import { start as qunitStart } from 'ember-qunit';

export function start() {
  enterTestMode();
  setApplication(Application.create(config.APP));

  setup(QUnit.assert);

  qunitStart({ loadTests: false });
}
