import Component from '@glimmer/component';
import { service } from '@ember/service';

import type RouterService from '@ember/routing/router-service';

import { FileDropZone } from './components/file-drop-zone';
import { getSummaryFile } from '#file';

export default class Import extends Component {
  @service declare router: RouterService;

  file = getSummaryFile(this);

  handleSuccess = () => {
    this.router.transitionTo('view');
  };

  <template>
    <FileDropZone @file={{this.file}} @onSuccess={{this.handleSuccess}} />

    {{#if this.file.hasFile}}
      <br />
      <a href="/view">View this file</a>
    {{/if}}
  </template>
}
