import Service from '@ember/service';
import type { SummaryFile } from 'turborepo-summary-analyzer/types';
import { readFileToJSON } from 'turborepo-summary-analyzer/utils';

import { cell } from 'ember-resources';
import { openDB, type IDBPDatabase } from 'idb';
import { assert } from '@ember/debug';

const DATA_KEY = `file-data`;
const NAME_KEY = `file-name`;

const STORE_NAME = 'last-file';

export default class FileService extends Service {
  #current = cell<SummaryFile | undefined>();
  get current() {
    return this.#current.current;
  }

  #fileName = cell<string | undefined>();
  get fileName() {
    return this.#fileName.current;
  }

  #db: IDBPDatabase | undefined;

  async handleDroppedFile(file: FileList[0]) {
    const result = await readFileToJSON(file);

    this.#current.set(result.json);
    this.#fileName.set(result.name.replaceAll(/["']/g, ''));

    await this.#ensureStore();

    await this.#storage.put(STORE_NAME, JSON.stringify(result.json), DATA_KEY);
    await this.#storage.put(STORE_NAME, this.fileName, NAME_KEY);

    console.debug(
      `Dropped file, ${this.fileName ?? `< filename missing >`}, stored in indexeddb so it doesn't need to be manually loaded every time the page loads. (There is no backend storage. All storage is local)`
    );
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

    this.#fileName.set(existing);
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

      this.#current.set(parsed);
    } catch (e) {
      console.error(`Could not load previously loaded data`);
      console.error(e);

      return;
    }
  }
}
