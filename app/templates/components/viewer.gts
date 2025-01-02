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

    {{#each this.tasksByDuration as |task|}}
      {{taskDuration task}}
      -
      {{task.command}}
      <br />
    {{/each}}
  </template>
}

function taskDuration(task: SummaryTask) {
  return duration(task.execution.startTime, task.execution.endTime);
}

function duration(startTime: number, endTime: number) {
  return endTime - startTime;
}
