import Component from '@glimmer/component';
import { service } from '@ember/service';

import type RouterService from '@ember/routing/router-service';

import { FileDropZone } from './components/file-drop-zone';

export default class Import extends Component {
  @service declare router: RouterService;

  handleSuccess = () => {
    this.router.transitionTo('view');
  };

  <template>
    <FileDropZone @file={{this.file}} @onSuccess={{this.handleSuccess}} />
  </template>
}
