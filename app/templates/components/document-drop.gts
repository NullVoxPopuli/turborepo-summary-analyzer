import type Owner from '@ember/owner';
import Component from '@glimmer/component';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { registerDestructor } from '@ember/destroyable';
import type FileService from 'turborepo-summary-analyzer/services/file';
import { handleDrop, preventDefaults } from './drop-utils';
import { assert } from '@ember/debug';

export class DocumentDrop extends Component {
  @service declare file: FileService;

  @tracked isDropping = false;

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  constructor(owner: Owner, args: any) {
    // eslint-disable-next-line @typescript-eslint/no-unsafe-argument
    super(owner, args);

    const html = document.querySelector('html');
    assert(`[BUG]: No HTML`, html);

    const start = (event: Event) => {
      preventDefaults(event);
      this.isDropping = true;
    };
    const cancel = (event: Event) => {
      if (event.target === html) {
        this.isDropping = false;
      }
    };

    html.addEventListener('dragover', start);
    html.addEventListener('dropenter', preventDefaults);
    html.addEventListener('dragleave', cancel);
    html.addEventListener('dragend', cancel);
    html.addEventListener('drop', this.handleDrop);

    registerDestructor(this, () => {
      html.removeEventListener('dropenter', preventDefaults);
      html.removeEventListener('dragover', start);
      html.removeEventListener('dragleave', cancel);
      html.removeEventListener('dragend', cancel);
      html.removeEventListener('drop', this.handleDrop);
    });
  }

  handleDrop = async (dropEvent: Event) => {
    preventDefaults(dropEvent);

    const fileData = handleDrop(
      {
        onError: (e) => {
          console.error(e);
        },
      },
      dropEvent
    );

    console.log({ fileData });

    this.isDropping = false;
    if (!fileData) return;

    await this.file.handleDroppedFile(fileData);
  };

  <template>
    {{#if this.isDropping}}
      <div class="drop-on-document">
        Drop files here to analyze
      </div>
    {{/if}}

    {{! prettier-ignore }}
    <style>
      .drop-on-document {
        user-select: none;
        position: fixed;
        z-index: 10000;
        inset: 0.5rem;
        border: 2px dashed;
        border-radius: 2rem;
        background: rgba(255, 255, 255, 0.9);
      }
    </style>
  </template>
}
