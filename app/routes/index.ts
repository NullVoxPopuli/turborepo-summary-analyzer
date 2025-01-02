import Route from '@ember/routing/route';
import type RouterService from '@ember/routing/router-service';
import { service } from '@ember/service';
import type FileService from 'turborepo-summary-analyzer/services/file';

export default class IndexRoute extends Route {
  @service declare file: FileService;
  @service declare router: RouterService;

  /**
   * Application route tries to load the file, because we _always_ need to do so
   */
  async beforeModel() {
    if (this.file.hasFile) {
      this.router.replaceWith(`view`);
      return;
    }

    this.router.replaceWith('import');
  }
}
