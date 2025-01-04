import Application from '@ember/application';
import compatModules from '@embroider/virtual/compat-modules';
import Resolver from 'ember-resolver';
import loadInitializers from 'ember-load-initializers';
import config from './config/environment';
import { isTesting, macroCondition } from '@embroider/macros';
import { sync } from 'ember-primitives/color-scheme';

import './styles.css';

export default class App extends Application {
  modulePrefix = config.modulePrefix;
  podModulePrefix = config.podModulePrefix;
  Resolver = Resolver.withModules(compatModules);
}

loadInitializers(App, config.modulePrefix, compatModules);

if (macroCondition(isTesting())) {
  // No themes in testing... yet?
  // (QUnit doesn't have good dark mode CSS)
} else {
  sync();
}
