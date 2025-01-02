import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';
import type { SummaryFile } from 'turborepo-summary-analyzer/types';
import { readFileToJSON } from 'turborepo-summary-analyzer/utils';

export default class FileService extends Service {
  @tracked current: SummaryFile | undefined;
  @tracked fileName: string | undefined;

  async handleDroppedFile(file: FileList[0]) {
    let result = await readFileToJSON(file);

    this.current = result.json;
    this.fileName = result.name;
  }
}
