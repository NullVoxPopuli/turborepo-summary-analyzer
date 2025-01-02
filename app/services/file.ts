import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';
import type { SummaryFile } from 'turborepo-summary-analyzer/types';
import { readFileToJSON } from 'turborepo-summary-analyzer/utils';

import { openDB, deleteDB, wrap, unwrap, type IDBPDatabase } from 'idb';

export const STORAGE_KEY_DATA = `last-turbo-file-data`;
export const STORAGE_KEY_NAME = `last-turbo-file-name`;

export default class FileService extends Service {
  @tracked current: SummaryFile | undefined;
  @tracked fileName: string | undefined;

  #db: IDBPDatabase | undefined;

  async handleDroppedFile(file: FileList[0]) {
    const result = await readFileToJSON(file);

    this.current = result.json;
    this.fileName = result.name.replaceAll('"', '');

    localStorage.setItem(STORAGE_KEY_DATA, JSON.stringify(result.json));
    localStorage.setItem(STORAGE_KEY_NAME, JSON.stringify(result.name));
  }

  get hasFile() {
    return Boolean(this.current);
  }

  async tryLoadFromStorage() {
    await this.#tryLoadData();
    await this.#tryLoadName();
  }

  async #openDatabase() {
    if (this.#db) return;

    const db = await openDB(`summary-file-db`, 1, {
      upgrade() {},
      blocked() {},
      blocking() {},
      terminated() {},
    });

    this.#db = db;
  }

  async #tryLoadName() {
    const existing = localStorage.getItem(STORAGE_KEY_NAME);

    if (!existing) return;

    this.fileName = existing;
  }

  async #tryLoadData() {
    const existing = localStorage.getItem(STORAGE_KEY_DATA);

    if (!existing) return;

    try {
      const parsed = JSON.parse(existing);

      this.current = parsed;
    } catch (e) {
      console.error(`Could not load previously loaded data`);
      console.error(e);

      return;
    }
  }
}
