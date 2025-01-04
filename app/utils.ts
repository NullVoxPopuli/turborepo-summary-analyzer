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

// See: https://github.com/microsoft/TypeScript/issues/60608
//
// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-expect-error
// eslint-disable-next-line @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-call
export const durationFormatter = new Intl.DurationFormat('en', {
  style: 'narrow',
});

export function taskDuration(task: SummaryTask) {
  const durationMs = durationOfTask(task);

  const duration = msToDuration(durationMs);

  // eslint-disable-next-line @typescript-eslint/no-unsafe-return, @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access
  return durationFormatter.format(duration);
}

export function overallDuration(execution: {
  startTime: number;
  endTime: number;
}) {
  const durationMs = execution.endTime - execution.startTime;
  const duration = msToDuration(durationMs);

  // eslint-disable-next-line @typescript-eslint/no-unsafe-return, @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access
  return durationFormatter.format(duration);
}

function durationOfTask(task: SummaryTask) {
  return duration(task.execution.startTime, task.execution.endTime);
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
