import Component from '@glimmer/component';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { modifier } from 'ember-modifier';
import type FileService from 'turborepo-summary-analyzer/services/file';
import type RouterService from '@ember/routing/router-service';
import { assert } from '@ember/debug';

function preventDefaults(e: Event) {
  e.preventDefault();
  e.stopPropagation();
}

const dropArea = modifier((element, [handleDrop]: [(event: Event) => void]) => {
  element.addEventListener('dragover', preventDefaults);
  element.addEventListener('dropenter', preventDefaults);
  element.addEventListener('dragleave', preventDefaults);

  element.addEventListener('drop', handleDrop);
});

export class FileDropZone extends Component {
  @service declare file: FileService;
  @service declare router: RouterService;

  @tracked error: string | undefined;

  handleDrop = async (dropEvent: Event) => {
    dropEvent.preventDefault();

    assert(`Expected event to be a DragEvent`, dropEvent instanceof DragEvent);

    if (!dropEvent.dataTransfer) {
      this.error = `Expected a dataTransfer object on the drag-drop Event`;
      return;
    }

    if (dropEvent.dataTransfer.files.length > 1) {
      const count = String(dropEvent.dataTransfer.files.length);

      this.error = `Please only dorp one file. Received: ${count} files.`;

      return;
    }

    if (!dropEvent.dataTransfer.files[0]) {
      this.error = `Please place a file in the drop zone.`;
      return;
    }

    if (!dropEvent.dataTransfer.files[0].name.endsWith('.json')) {
      const ext =
        dropEvent.dataTransfer.files[0].name.split('.').at(-1) ??
        '< no extension >';
      this.error = `file extension must be .json, received: ${ext}`;
      return;
    }

    if (dropEvent.dataTransfer.files[0].type !== 'application/json') {
      this.error = `Unexpected mimetype! Expected application/json, but received ${dropEvent.dataTransfer.files[0].type}`;
      return;
    }

    const fileData = dropEvent.dataTransfer.files[0];

    await this.file.handleDroppedFile(fileData);

    this.router.transitionTo('view');
  };

  <template>
    <div class="drop-container">
      {{#if this.error}}
        <p class="error">{{this.error}}</p>
      {{/if}}
      {{!<input name="dropped-file" type="file" hidden />}}
      <div class="drop-zone" {{dropArea this.handleDrop}}>
        Drop the Summary JSON file here

        <p>
          These files are usually located in
          <code>[your repo]/.turbo/runs/xyz.json</code>
        </p>

      </div>

    </div>
    {{! prettier-ignore }}
    <style>
      .drop-container {
        border: 2px dashed;
        border-radius: 1rem;

        .drop-zone {
          padding: 3rem;

          &.drag-over {
            background: #eee;
          }
        }

      }

    </style>
  </template>
}
