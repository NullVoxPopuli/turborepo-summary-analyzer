import Component from '@glimmer/component';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { modifier } from 'ember-modifier';
import type FileService from 'turborepo-summary-analyzer/services/file';
import type RouterService from '@ember/routing/router-service';
import { handleDrop, preventDefaults } from './drop-utils';

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
    const fileData = handleDrop(
      { onError: (e) => (this.error = e) },
      dropEvent
    );

    if (!fileData) return;

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
