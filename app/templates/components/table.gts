import type { TOC } from '@ember/component/template-only';
import type { SummaryTask } from 'turborepo-summary-analyzer/types';
import { taskDuration, durationOfTask } from 'turborepo-summary-analyzer/utils';

function byDuration(tasks: SummaryTask[]) {
  return tasks.toSorted((a, b) => {
    return durationOfTask(a) - durationOfTask(b);
  });
}

function cacheStatus(task: SummaryTask) {
  if (task.cache.status === 'MISS') return 'MISS';

  if (task.cache.local) return 'Local';
  if (task.cache.remote) return 'Remote';

  return task.cache.status;
}

export const Table = <template>
  <table class="summary-table" ...attributes>
    <caption>All tasks by duration</caption>
    <thead>
      <tr>
        <th class="num">Duration</th>
        <th>Cache</th>
        <th>Package</th>
        <th>Task</th>
        <th>Command</th>
      </tr>
    </thead>
    <tbody>
      {{#each (byDuration @tasks) as |task|}}
        <tr>
          <td class="num metric">{{taskDuration task}}</td>
          <td>{{cacheStatus task}}</td>
          <td class="mono">{{task.package}}</td>
          <td class="mono">{{task.task}}</td>
          <td class="mono">{{task.command}}</td>
        </tr>
      {{/each}}
    </tbody>
  </table>
</template> satisfies TOC<{
  Element: HTMLTableElement;
  Args: {
    tasks: SummaryTask[];
  };
}>;
