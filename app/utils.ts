import { assert } from '@ember/debug';
import { waitForPromise } from '@ember/test-waiters';
import type { SummaryFile } from 'turborepo-summary-analyzer/types';

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
