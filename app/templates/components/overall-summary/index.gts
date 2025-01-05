import type { TOC } from '@ember/component/template-only';
import type {
  SummaryFile,
  SummaryTask,
} from 'turborepo-summary-analyzer/types';
import { Prompt } from './prompt';
import {
  overallDuration,
  formatDuration,
  msToDuration,
} from 'turborepo-summary-analyzer/utils';

function totalDurations(tasks: SummaryTask[]) {
  let ms = 0;
  const durations = tasks.map(
    (task) => task.execution.endTime - task.execution.startTime
  );

  durations.forEach((d) => (ms += d));
  return ms;
}

function totalCPU(tasks: SummaryTask[]) {
  const ms = totalDurations(tasks);

  return formatDuration(msToDuration(ms));
}

function timeSaved(overall: SummaryFile['execution'], tasks: SummaryTask[]) {
  const cpu = totalDurations(tasks);
  const perceived = overall.endTime - overall.startTime;

  const diff = cpu - perceived;
  // eslint-disable-next-line @typescript-eslint/no-unsafe-return, @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access
  return durationFormatter.format(msToDuration(diff));
}

export const OverallSummary = <template>
  <div class="overall-summary">
    <Prompt @command={{@execution.command}} />

    <div class="details">
      <span class="duration">{{overallDuration @execution}}</span>
      <dl>
        <dt>CPU Time</dt>
        <dd>{{totalCPU @tasks}}</dd>
      </dl>
      <dl>
        <dt>Time Saved</dt>
        <dd>{{timeSaved @execution @tasks}}</dd>
      </dl>
      <dl>
        <dt>Total Tasks</dt>
        <dd>{{@execution.attempted}}</dd>
      </dl>
      <dl>
        <dt>Cached Tasks</dt>
        <dd>{{@execution.cached}}</dd>
      </dl>
    </div>
  </div>
  <style>
    .overall-summary {
      display: flex;
      flex-direction: column;
      gap: 0.5rem;

      .details {
        margin-left: 4rem;
        display: flex;
        gap: 1rem;
        .duration {
          font-style: italic;
          font-size: 1.75rem;
        }
        dl {
          margin: 0;
        }
        dt {
          text-transform: uppercase;
          font-size: 0.75rem;
          font-weight: bold;
        }
        dd {
          margin: 0;
        }
      }
    }
  </style>
</template> satisfies TOC<{
  Args: {
    execution: SummaryFile['execution'];
    tasks: SummaryFile['tasks'];
  };
}>;
