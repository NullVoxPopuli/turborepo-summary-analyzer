import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';
import type { SummaryFile } from 'turborepo-summary-analyzer/types';
import { readFileToJSON } from 'turborepo-summary-analyzer/utils';

import { openDB, type IDBPDatabase } from 'idb';
import { assert } from '@ember/debug';

const DATA_KEY = `file-data`;
const NAME_KEY = `file-name`;

const STORE_NAME = 'last-file';

export default class FileService extends Service {
  @tracked current: SummaryFile | undefined;
  @tracked fileName: string | undefined;

  #db: IDBPDatabase | undefined;

  async handleDroppedFile(file: FileList[0]) {
    const result = await readFileToJSON(file);

    this.current = result.json;
    this.fileName = result.name.replaceAll(/["']/g, '');

    await this.#ensureStore();

    await this.#storage.put(STORE_NAME, JSON.stringify(result.json), DATA_KEY);
    await this.#storage.put(STORE_NAME, JSON.stringify(result.name), NAME_KEY);
  }

  get hasFile() {
    return Boolean(this.current);
  }

  async tryLoadFromStorage() {
    await this.#ensureStore();
    await this.#tryLoadData();
    await this.#tryLoadName();
  }

  get #storage() {
    assert('#ensureStore must be called, db is not initialized', this.#db);

    return this.#db;
  }

  async #ensureStore() {
    if (this.#db) return;

    const db = await openDB(`turborepo-summary-analyzer`, 1, {
      upgrade(db) {
        db.createObjectStore(STORE_NAME);
      },
      blocked() {},
      blocking() {},
      terminated() {},
    });

    this.#db = db;
  }

  async #tryLoadName() {
    // SAFETY: this could lead to problems in the future.
    // TODO: fix
    // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
    const existing: string = await this.#storage.get(STORE_NAME, NAME_KEY);

    if (!existing) return;

    this.fileName = existing;
  }

  async #tryLoadData() {
    // SAFETY: this could lead to problems in the future.
    // TODO: fix
    // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
    const existing: string = await this.#storage.get(STORE_NAME, DATA_KEY);

    if (!existing) return;

    try {
      // SAFETY: this could lead to problems in the future.
      // TODO: fix
      // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
      const parsed: SummaryFile = JSON.parse(existing);

      this.current = parsed;
    } catch (e) {
      console.error(`Could not load previously loaded data`);
      console.error(e);

      return;
    }
  }
}
