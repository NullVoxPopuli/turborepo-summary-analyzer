import Route from '@ember/routing/route';
import type RouterService from '@ember/routing/router-service';
import { service } from '@ember/service';
import type FileService from 'turborepo-summary-analyzer/services/file';

export default class ViewRoute extends Route {
  @service declare file: FileService;
  @service declare router: RouterService;

  beforeModel() {
    if (!this.file.hasFile) {
      this.router.replaceWith(`import`);
      return;
    }
  }
}
