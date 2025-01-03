import { assert } from '@ember/debug';

export function preventDefaults(e: Event) {
  e.preventDefault();
  e.stopPropagation();
}

export function handleDrop(
  events: { onError: (msg: string) => void },
  dropEvent: Event
) {
  dropEvent.preventDefault();

  assert(`Expected event to be a DragEvent`, dropEvent instanceof DragEvent);

  if (!dropEvent.dataTransfer) {
    events.onError(`Expected a dataTransfer object on the drag-drop Event`);
    return;
  }

  if (dropEvent.dataTransfer.files.length > 1) {
    const count = String(dropEvent.dataTransfer.files.length);

    events.onError(`Please only dorp one file. Received: ${count} files.`);

    return;
  }

  if (!dropEvent.dataTransfer.files[0]) {
    events.onError(`Please place a file in the drop zone.`);
    return;
  }

  if (!dropEvent.dataTransfer.files[0].name.endsWith('.json')) {
    const ext =
      dropEvent.dataTransfer.files[0].name.split('.').at(-1) ??
      '< no extension >';
    events.onError(`file extension must be .json, received: ${ext}`);
    return;
  }

  if (dropEvent.dataTransfer.files[0].type !== 'application/json') {
    events.onError(
      `Unexpected mimetype! Expected application/json, but received ${dropEvent.dataTransfer.files[0].type}`
    );
    return;
  }

  const fileData = dropEvent.dataTransfer.files[0];

  return fileData;
}
