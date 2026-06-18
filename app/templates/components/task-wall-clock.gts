import type { TOC } from '@ember/component/template-only';
import type { SummaryTask } from 'turborepo-summary-analyzer/types';
import {
  summarizeByTaskName,
  formatMs,
} from 'turborepo-summary-analyzer/utils';

export const TaskWallClock = <template>
  <section class="task-wall-clock" ...attributes>
    <h3>Wall-clock time per task</h3>

    <table class="centered summary-table">
      <thead>
        <tr>
          <th>Task</th>
          <th class="num">Wall-clock</th>
          <th class="num">CPU time</th>
          <th class="num">Count</th>
        </tr>
      </thead>
      <tbody>
        {{#each (summarizeByTaskName @tasks) as |summary|}}
          <tr>
            <td class="mono">{{summary.task}}</td>
            <td class="num metric">{{formatMs summary.wallClockMs}}</td>
            <td class="num">{{formatMs summary.cpuMs}}</td>
            <td class="num">{{summary.count}}</td>
          </tr>
        {{/each}}
      </tbody>
    </table>
  </section>

  <style>
    .task-wall-clock {
      display: flex;
      flex-direction: column;
      gap: 1rem;
      align-items: center;
    }
  </style>
</template> satisfies TOC<{
  Element: HTMLElement;
  Args: {
    tasks: SummaryTask[];
  };
}>;
