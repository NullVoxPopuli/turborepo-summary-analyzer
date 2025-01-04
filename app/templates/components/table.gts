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
  <table ...attributes>
    <thead>
      <tr>
        <th>Duration</th>
        <th>Cache</th>
        <th>Package</th>
        <th>Task</th>
        <th>Command</th>
      </tr>
    </thead>
    <tbody>
      {{#each (byDuration @tasks) as |task|}}
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
</template> satisfies TOC<{
  Element: HTMLTableElement;
  Args: {
    tasks: SummaryTask[];
  };
}>;
