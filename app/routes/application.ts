import Route from '@ember/routing/route';
import { service } from '@ember/service';
import type FileService from 'turborepo-summary-analyzer/services/file';

import { checkFeatures } from 'turborepo-summary-analyzer/feature-check';

export default class ApplicationRoute extends Route {
  @service declare file: FileService;

  async beforeModel() {
    if (checkFeatures(this)) return;
    await this.file.tryLoadFromStorage();
  }
}
