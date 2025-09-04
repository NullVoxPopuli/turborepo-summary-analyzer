import Route from '@ember/routing/route';

import { checkFeatures } from 'turborepo-summary-analyzer/feature-check';
import {
  getSummaryFile,
  getLeftFile,
  getRightFile,
} from 'turborepo-summary-analyzer/services/file';

export default class ApplicationRoute extends Route {
  file = getSummaryFile(this);
  left = getLeftFile(this);
  right = getRightFile(this);

  async beforeModel() {
    if (checkFeatures(this)) return;
    await Promise.all([
      // this.file.tryLoadFromStorage(),
      this.left.tryLoadFromStorage(),
      // this.right.tryLoadFromStorage(),
    ]);
  }
}
