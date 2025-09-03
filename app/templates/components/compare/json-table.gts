import { on } from '@ember/modifier';
import Component from '@glimmer/component';

export class Table extends Component {
  showUnchanged = () => {};

  <template>
    <div class="diff-controls">
      <button type="button" {{on "click" this.toggleUnchanged}}>
        {{if this.showUnchanged "Hide" "Show"}}
        Unchanged
      </button>
      <span class="summary">Δ Added:
        {{this.summary.added}}
        | Removed:
        {{this.summary.removed}}
        | Changed:
        {{this.summary.changed}}
        | Same:
        {{this.summary.same}}</span>
    </div>
    <table class="diff-table">
      <thead>
        <tr>
          <th>Path</th>
          <th>Left</th>
          <th>Right</th>
          <th>Status</th>
        </tr>
      </thead>
      <tbody>
        {{#each this.diff as |entry|}}
          <tr class={{entry.kind}}>
            <td class="path">{{if entry.path entry.path "(root)"}} </td>
            <td>{{this.formatValue entry.leftValue}}</td>
            <td>{{this.formatValue entry.rightValue}}</td>
            <td class="status">{{entry.kind}}</td>
          </tr>
        {{/each}}
      </tbody>
    </table>
  </template>
}
