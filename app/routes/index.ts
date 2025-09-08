import Route from '@ember/routing/route';
import type RouterService from '@ember/routing/router-service';
import { service } from '@ember/service';
import { getSummaryFile } from '#file';

export default class IndexRoute extends Route {
  @service declare router: RouterService;

  file = getSummaryFile(this);

  /**
   * Application route tries to load the file, because we _always_ need to do so
   */
  beforeModel() {
    if (this.file.hasFile) {
      this.router.replaceWith(`view`);
      return;
    }

    this.router.replaceWith('import');
  }
}
