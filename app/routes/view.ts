import Route from '@ember/routing/route';
import type RouterService from '@ember/routing/router-service';
import { service } from '@ember/service';
import { getSummaryFile } from '#file';

export default class ViewRoute extends Route {
  @service declare router: RouterService;

  queryParams = {
    sort: {
      refreshModel: false,
      replace: true,
    },
  };

  file = getSummaryFile(this);

  beforeModel() {
    if (!this.file.hasFile) {
      this.router.replaceWith(`import`);
      return;
    }
  }
}
