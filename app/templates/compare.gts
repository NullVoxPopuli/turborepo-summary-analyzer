import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { pageTitle } from 'ember-page-title';
import { FileDropZone } from './components/file-drop-zone';
import {
  diffJSON,
  type DiffEntry,
  summarizeDiff,
} from 'turborepo-summary-analyzer/templates/components/compare/diff-json';
import JsonTreeView from './components/compare/json-tree-view';
import { getLeftFile, getRightFile } from '#file';

export default class JsonCompare extends Component {
  left = getLeftFile(this);
  right = getRightFile(this);

  get hasBoth() {
    return this.left.hasFile && this.right.hasFile;
  }

  @cached
  get _diffJson() {
    if (!this.hasBoth) return [];

    return diffJSON(this.left.current, this.right.current, {
      maxDepth: 10,
    });
  }

  get diff(): DiffEntry[] {
    if (!this.hasBoth) return [];

    return this._diffJson.filter((e) => e.kind !== 'same');
  }

  get summary() {
    return summarizeDiff(this._diffJson);
  }

  formatValue(v: unknown) {
    if (typeof v === 'string') return v;
    try {
      return JSON.stringify(v);
    } catch {
      return String(v);
    }
  }

  <template>
    {{pageTitle "Compare"}}
    <h2>Compare Summary Files</h2>
    <div class="compare-container">
      <div class="panes">

        <FileDropZone @file={{this.left}} />
        <FileDropZone @file={{this.right}} />
      </div>

      {{#if this.hasBoth}}
        <div class="diff-controls">
          <span class="summary">Δ Added:
            {{this.summary.added}}
            | Removed:
            {{this.summary.removed}}
            | Changed:
            {{this.summary.changed}}
            | Same:
            {{this.summary.same}}</span>
        </div>
        <JsonTreeView @diff={{this.diff}} />
      {{else}}
        <p class="hint">Drop two JSON files to see a diff.</p>
      {{/if}}
    </div>

    <style>
      .compare-container {
        display: flex;
        flex-direction: column;
        gap: 1rem;
      }
      .panes {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 1rem;
      }
      .diff-controls {
        display: flex;
        gap: 1rem;
        align-items: center;
      }
      .summary {
      }
      .hint {
        opacity: 0.8;
        font-style: italic;
      }
    </style>
  </template>
}
