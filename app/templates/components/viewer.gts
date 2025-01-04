import Component from '@glimmer/component';
import { service } from '@ember/service';
import type FileService from 'turborepo-summary-analyzer/services/file';
import { assert } from '@ember/debug';
import { cached } from '@glimmer/tracking';
import type { SummaryTask } from 'turborepo-summary-analyzer/types';
import { Timeline } from './timeline';
import { OverallSummary } from './overall-summary';
import { taskDuration } from 'turborepo-summary-analyzer/utils';

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

  @cached
  get tasksByDuration() {
    return this.tasks.toSorted((a, b) => {
      return taskDuration(a) - taskDuration(b);
    });
  }

  <template>
    <h2>{{this.file.fileName}}</h2>

    <OverallSummary @execution={{this.execution}} @tasks={{this.tasks}} />

    <Timeline @tasks={{this.tasks}} />

    <table><thead><tr>
          <th>Duration</th>
          <th>Cache</th>
          <th>Package</th>
          <th>Task</th>
          <th>Command</th>
        </tr></thead>
      <tbody>

        {{#each this.tasksByDuration as |task|}}
          <tr>
            <td>{{taskDuration task}}</td>
            <td>{{cacheStatus task}}</td>
            <td>{{task.package}}</td>
            <td>{{task.task}}</td>
            <td>{{task.command}}</td>
          </tr>
        {{/each}}
      </tbody>
    </table>
  </template>
}

function cacheStatus(task: SummaryTask) {
  if (task.cache.status === 'MISS') return 'MISS';

  if (task.cache.local) return 'Local';
  if (task.cache.remote) return 'Remote';

  return task.cache.status;
}
