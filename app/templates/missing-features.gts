import { ExternalLink } from '@universal-ember/preem';
import Route from 'ember-route-template';

import { missingFeatures } from 'turborepo-summary-analyzer/feature-check';

function canIUse(feature: string) {
  return `https://caniuse.com/?search=${feature}`;
}

export default Route(
  <template>
    <h1>oh no!</h1>

    Looks like your web browser is missing some importing features! Check
    support here:

    <ul>
      {{#each missingFeatures as |feature|}}
        <li>
          <ExternalLink href={{canIUse feature}}>{{feature}}</ExternalLink>
        </li>
      {{/each}}
    </ul>
  </template>
);
