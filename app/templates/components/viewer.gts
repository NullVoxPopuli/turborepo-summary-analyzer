import Component from '@glimmer/component';
import { service } from '@ember/service';
import type FileService from 'turborepo-summary-analyzer/services/file';
import { assert } from '@ember/debug';
import { cached } from '@glimmer/tracking';
import type { SummaryTask } from 'turborepo-summary-analyzer/types';

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

  @cached
  get slowestFive() {
    let length = this.tasksByDuration.length;

    return this.tasksByDuration.slice(length - 5, length).reverse();
  }

  get numTasks() {
    console.log(this.file.current);

    return 0;
  }

  <template>
    <h2>{{this.file.fileName}}</h2>

    <pre>
      {{this.execution.command}}
      {{duration this.execution.startTime this.execution.endTime}}
      Tasks:
      {{this.execution.attempted}}
      Cached:
      {{this.execution.cached}}
    </pre>

    <table><thead><tr>
          <th>Duration</th>
          <th>Cache</th>
          <th>Package</th>
          <th>Command</th>
        </tr></thead>
      <tbody>

        {{#each this.slowestFive as |task|}}
          <tr>
            <td>{{formattedDuration task}}</td>

            <td>{{cacheStatus task}}</td>
            <td>{{task.package}}</td>
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

function taskDuration(task: SummaryTask) {
  return duration(task.execution.startTime, task.execution.endTime);
}

function duration(startTime: number, endTime: number) {
  return endTime - startTime;
}

const durationFormatter = new Intl.DurationFormat('en', { style: 'narrow' });

function formattedDuration(task: SummaryTask) {
  let durationMs = taskDuration(task);

  let duration = msToDuration(durationMs);

  return durationFormatter.format(duration);
}

const msInSecond = 1000;
const msInMinute = msInSecond * 60;
const msInHour = msInMinute * 60;

function msToDuration(ms: number) {
  const hours = Math.floor(ms / msInHour);
  ms %= msInHour;

  const minutes = Math.floor(ms / msInMinute);
  ms %= msInMinute;

  const seconds = Math.floor(ms / msInSecond);
  ms %= msInSecond;

  const milliseconds = ms;

  return { hours, minutes, seconds, milliseconds };
}
