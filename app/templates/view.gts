import Route from 'ember-route-template';
import { Viewer } from './components/viewer';
import { LinkTo } from '@ember/routing';
import { DocumentDrop } from './components/document-drop';

export default Route(
  <template>
    <LinkTo @route="import">Load Summary File</LinkTo>
    <Viewer />
    <DocumentDrop />
  </template>
);
