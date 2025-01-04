import Component from '@glimmer/component';
import { service } from '@ember/service';
import type FileService from 'turborepo-summary-analyzer/services/file';
import { assert } from '@ember/debug';
import { Timeline } from './timeline';
import { OverallSummary } from './overall-summary';
import { Table } from './table';

export class Viewer extends Component {
  @service declare file: FileService;

  get current() {
    assert(
      `[BUG] Viewer should only be used when the current file is loaded`,
      this.file.current
    );
    return this.file.current;
  }

  get execution() {
    return this.current.execution;
  }

  get tasks() {
    return this.current.tasks;
  }

  <template>
    <h2>{{this.file.fileName}}</h2>

    <OverallSummary @execution={{this.execution}} @tasks={{this.tasks}} />
    <Timeline @tasks={{this.tasks}} />
    <br />

    <Table class="centered" @tasks={{this.tasks}} />
  </template>
}
