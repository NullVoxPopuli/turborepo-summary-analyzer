import Component from '@glimmer/component';
import { pageTitle } from 'ember-page-title';
import { tracked } from '@glimmer/tracking';
import { fn } from '@ember/helper';
import {
  diffJSON,
  type DiffEntry,
  summarizeDiff,
} from 'turborepo-summary-analyzer/templates/components/compare/diff-json';
import JsonTreeView from 'turborepo-summary-analyzer/templates/components/compare/json-tree-view';
import JsonDropZone from 'turborepo-summary-analyzer/templates/components/compare/json-drop-zone';

interface FileState<T> {
  name?: string;
  data?: T;
  error?: string;
  dropping: boolean;
}

export default class JsonCompare extends Component {
  @tracked left: FileState<unknown> = { dropping: false };
  @tracked right: FileState<unknown> = { dropping: false };

  get hasBoth() {
    return this.left.data && this.right.data;
  }

  get diff(): DiffEntry[] {
    if (!this.hasBoth) return [];
    const entries = diffJSON(this.left.data, this.right.data, { maxDepth: 6 });
    return entries.filter((e) => e.kind !== 'same');
  }

  get summary() {
    return summarizeDiff(diffJSON(this.left.data, this.right.data));
  }

  onFileLoaded = (side: 'left' | 'right', fileState: FileState<unknown>) => {
    this[side] = fileState;
  };

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
        <JsonDropZone @onFileLoaded={{fn this.onFileLoaded "left"}} />
        <JsonDropZone @onFileLoaded={{fn this.onFileLoaded "right"}} />
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
