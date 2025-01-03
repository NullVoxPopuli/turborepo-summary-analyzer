import EmberRouter from '@ember/routing/router';
import config from 'turborepo-summary-analyzer/config/environment';

export default class Router extends EmberRouter {
  location = config.locationType;
  rootURL = config.rootURL;
}

Router.map(function () {
  this.route('import');
  this.route('view');
});
