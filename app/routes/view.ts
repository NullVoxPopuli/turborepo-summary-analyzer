import Route from '@ember/routing/route';
import type RouterService from '@ember/routing/router-service';
import { service } from '@ember/service';
import { getSummaryFile } from 'turborepo-summary-analyzer/services/file';

export default class ViewRoute extends Route {
  @service declare router: RouterService;

  file = getSummaryFile(this);

  beforeModel() {
    if (!this.file.hasFile) {
      this.router.replaceWith(`import`);
      return;
    }
  }
}
