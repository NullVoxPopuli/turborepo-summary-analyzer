import Route from 'ember-route-template';
import { Viewer } from './components/viewer';
import { LinkTo } from '@ember/routing';

export default Route(
  <template>
    <LinkTo @route="import">Load Summary File</LinkTo>
    <Viewer />
  </template>
);
