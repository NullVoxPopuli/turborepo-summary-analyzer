import EmberRouter from '@ember/routing/router';
import config from './config.ts';
import { properLinks } from 'ember-primitives/proper-links';

@properLinks
export default class Router extends EmberRouter {
  location = config.locationType;
  rootURL = config.rootURL;
}

Router.map(function () {
  this.route('import');
  this.route('view');
  this.route('missing-features');
});
