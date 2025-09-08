import Application from 'ember-strict-application-resolver';
import { isTesting, macroCondition } from '@embroider/macros';
import { sync } from 'ember-primitives/color-scheme';
import Router from './router.ts';
import PageTitle from 'ember-page-title/services/page-title';

export default class App extends Application {
  modules = {
    './router': Router,
    './services/page-title': PageTitle,
    ...import.meta.glob('./routes/*.ts', { eager: true }),
    ...import.meta.glob('./templates/*.gts', { eager: true }),
  };
}

if (macroCondition(isTesting())) {
  // No themes in testing... yet?
  // (QUnit doesn't have good dark mode CSS)
} else {
  sync();
}
