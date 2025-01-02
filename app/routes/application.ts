import Route from '@ember/routing/route';
import { service } from '@ember/service';
import type FileService from 'turborepo-summary-analyzer/services/file';

export default class ApplicationRoute extends Route {
  @service declare file: FileService;

  async beforeModel() {
    await this.file.tryLoadFromStorage();
  }
}
