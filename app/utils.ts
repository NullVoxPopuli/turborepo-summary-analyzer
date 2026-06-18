import { assert } from '@ember/debug';
import { waitForPromise } from '@ember/test-waiters';
import type {
  SummaryFile,
  SummaryTask,
} from 'turborepo-summary-analyzer/types';

export async function readFileToJSON(
  file: FileList[0]
): Promise<{ json: SummaryFile; name: string }> {
  const promise = new Promise<SummaryFile>((resolve) => {
    const reader = new FileReader();
    reader.readAsText(file);

    reader.onloadend = (e: ProgressEvent<FileReader>) => {
      assert(`File reading did not correctly finish`, e.target?.result);

      const data = e.target.result;

      assert(`Expected file to be read as string`, typeof data === 'string');

      // SAFETY: this could be dangerous in the future, or lead to runtime errors
      // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
      const parsed: SummaryFile = JSON.parse(data);

      resolve(parsed);
    };
  });

  const json = await waitForPromise(promise);

  return {
    json,
    name: file.name,
  };
}

export function formatDuration(
  duration: ReturnType<typeof msToDuration>
): string {
  // See: https://github.com/microsoft/TypeScript/issues/60608
  //
  // This has to be a run-time accessed API because not all browsers support it
  //
  // eslint-disable-next-line @typescript-eslint/ban-ts-comment
  // @ts-expect-error
  // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-call
  const durationFormatter = new Intl.DurationFormat('en', {
    style: 'narrow',
  });

  // eslint-disable-next-line @typescript-eslint/no-unsafe-return, @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access
  return durationFormatter.format(duration);
}

export function taskDuration(task: SummaryTask): string {
  const durationMs = durationOfTask(task);

  const duration = msToDuration(durationMs);

  return formatDuration(duration);
}

export function overallDuration(execution: {
  startTime: number;
  endTime: number;
}) {
  const durationMs = execution.endTime - execution.startTime;
  const duration = msToDuration(durationMs);

  return formatDuration(duration);
}

export function durationOfTask(task: SummaryTask) {
  return duration(task.execution.startTime, task.execution.endTime);
}

/**
 * Wall-clock time (in ms) spanned by a set of tasks: from the earliest task
 * start to the latest task end. Because tasks run in parallel, this is the
 * real elapsed time, not the sum of each task's duration (that's CPU time).
 */
export function wallClockMs(tasks: SummaryTask[]): number {
  if (tasks.length === 0) return 0;

  let start = Infinity;
  let end = -Infinity;

  for (const task of tasks) {
    start = Math.min(start, task.execution.startTime);
    end = Math.max(end, task.execution.endTime);
  }

  return end - start;
}

/**
 * Sum of every task's individual duration (in ms) -- the total CPU time spent
 * across all tasks, ignoring parallelism.
 */
export function cpuMs(tasks: SummaryTask[]): number {
  return tasks.reduce((total, task) => total + durationOfTask(task), 0);
}

/** Format an arbitrary millisecond duration the same way task durations are shown. */
export function formatMs(ms: number): string {
  return formatDuration(msToDuration(ms));
}

export interface TaskNameSummary {
  task: string;
  count: number;
  wallClockMs: number;
  cpuMs: number;
  tasks: SummaryTask[];
}

/**
 * Group tasks by their task name (e.g. "lint:types", "build") and compute the
 * wall-clock + CPU time for each group. Sorted by wall-clock time, descending.
 */
export function summarizeByTaskName(tasks: SummaryTask[]): TaskNameSummary[] {
  const groups = new Map<string, SummaryTask[]>();

  for (const task of tasks) {
    const existing = groups.get(task.task);

    if (existing) {
      existing.push(task);
    } else {
      groups.set(task.task, [task]);
    }
  }

  const summaries: TaskNameSummary[] = [];

  for (const [task, grouped] of groups) {
    summaries.push({
      task,
      count: grouped.length,
      wallClockMs: wallClockMs(grouped),
      cpuMs: cpuMs(grouped),
      tasks: grouped,
    });
  }

  return summaries.sort((a, b) => b.wallClockMs - a.wallClockMs);
}

function duration(startTime: number, endTime: number) {
  return endTime - startTime;
}

const msInSecond = 1000;
const msInMinute = msInSecond * 60;
const msInHour = msInMinute * 60;

export function msToDuration(ms: number) {
  const hours = Math.floor(ms / msInHour);
  ms %= msInHour;

  const minutes = Math.floor(ms / msInMinute);
  ms %= msInMinute;

  const seconds = Math.floor(ms / msInSecond);
  ms %= msInSecond;

  const milliseconds = ms;

  return { hours, minutes, seconds, milliseconds };
}
