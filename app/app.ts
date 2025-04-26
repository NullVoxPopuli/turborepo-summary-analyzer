import Application from '@ember/application';
import compatModules from '@embroider/virtual/compat-modules';
import Resolver from 'ember-resolver';
import config from './config.ts';
import { isTesting, macroCondition } from '@embroider/macros';
import { sync } from 'ember-primitives/color-scheme';

export default class App extends Application {
  modulePrefix = config.modulePrefix;
  Resolver = Resolver.withModules(compatModules);
}

if (macroCondition(isTesting())) {
  // No themes in testing... yet?
  // (QUnit doesn't have good dark mode CSS)
} else {
  sync();
}
