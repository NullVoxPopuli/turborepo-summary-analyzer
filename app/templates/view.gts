import Route from 'ember-route-template';
import { Viewer } from './components/viewer';
import { DocumentDrop } from './components/document-drop';

export default Route(
  <template>
    <Viewer />
    <DocumentDrop />
  </template>
);
