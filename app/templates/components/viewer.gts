import Component from '@glimmer/component';
import { getSummaryFile } from '#file';
import { assert } from '@ember/debug';
import { service } from '@ember/service';
import type RouterService from '@ember/routing/router-service';
import type { TimelineSort } from 'turborepo-summary-analyzer/types';
import { Timeline } from './timeline';
import { OverallSummary } from './overall-summary';
import { Table } from './table';
import { TaskWallClock } from './task-wall-clock';

export class Viewer extends Component {
  @service declare router: RouterService;

  file = getSummaryFile(this);

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

  get sort(): TimelineSort {
    const sort = this.router.currentRoute?.queryParams?.['sort'];

    return sort === 'name' || sort === 'duration' ? sort : 'started';
  }

  updateSort = (sort: TimelineSort) => {
    const queryParams = new URLSearchParams(window.location.search);

    queryParams.set('sort', sort);

    void this.router.replaceWith(
      `${window.location.pathname}?${queryParams.toString()}`
    );
  };

  <template>
    <h2>{{this.file.fileName}}</h2>

    <OverallSummary
      @execution={{this.execution}}
      @tasks={{this.tasks}}
      @sort={{this.sort}}
      @onSortChange={{this.updateSort}}
    />
    <Timeline @tasks={{this.tasks}} @sort={{this.sort}} />
    <br />

    <TaskWallClock @tasks={{this.tasks}} />
    <br />

    <Table class="centered" @tasks={{this.tasks}} />
  </template>
}
