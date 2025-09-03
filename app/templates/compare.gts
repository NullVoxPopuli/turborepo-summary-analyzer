import Component from '@glimmer/component';
import { pageTitle } from 'ember-page-title';
import { tracked } from '@glimmer/tracking';
import { diffJSON, type DiffEntry, summarizeDiff } from './components/compare/diff.ts';
import JsonTreeView from './components/compare/json-tree-view.gts';
import JsonDropZone from './components/compare/json-drop-zone.gts';

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
        <JsonDropZone
          @title="Left JSON"
          @side="left"
          @onFileLoaded={{this.onFileLoaded}}
        />
        <JsonDropZone
          @title="Right JSON"
          @side="right"
          @onFileLoaded={{this.onFileLoaded}}
        />
      </div>

      {{#if this.hasBoth}}
        <div class="diff-controls">
          <span class="summary">Δ Added: {{this.summary.added}} | Removed: {{this.summary.removed}} | Changed: {{this.summary.changed}} | Same: {{this.summary.same}}</span>
        </div>
        <JsonTreeView @diff={{this.diff}} />
      {{else}}
        <p class="hint">Drop two JSON files to see a diff.</p>
      {{/if}}
    </div>

    <style>
      .compare-container { display: flex; flex-direction: column; gap: 1rem; }
      .panes { display: flex; gap: 1rem; }
      .pane { flex: 1; border: 1px solid var(--panel-border, #333); padding: .5rem; border-radius: .5rem; }
      .drop-zone { cursor: pointer; border: 2px dashed #555; border-radius: .5rem; padding: .5rem; text-align: center; min-height: 4rem; display:flex; align-items:center; justify-content:center; }
      .drop-zone.dropping { background: var(--drop-bg, #222); }
      .file-choose { text-decoration: underline; cursor: pointer; }
      .error { color: var(--error, #f55); font-weight: bold; }
      .filename { font-style: italic; }
      .diff-controls { display: flex; gap: 1rem; align-items: center; }
      .diff-table { width: 100%; border-collapse: collapse; font-size: .85rem; }
      .diff-table th, .diff-table td { border: 1px solid #444; padding: .25rem .5rem; vertical-align: top; }
      .diff-table tr.added { background: #123d12; }
      .diff-table tr.removed { background: #3d1212; }
      .diff-table tr.changed { background: #2d2d12; }
      .diff-table tr.same { opacity: .6; }
      .path { font-family: monospace; white-space: nowrap; }
      .status { text-transform: uppercase; font-size: .65rem; letter-spacing: 1px; }
      .hint { opacity: .8; font-style: italic; }
      button { background: #333; color: #fff; border: 1px solid #555; padding: .25rem .5rem; border-radius: .25rem; cursor: pointer; }
      button:hover { background: #444; }
    </style>
  </template>
}
