import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import { action } from '@ember/object';
import { readFileToJSON } from 'turborepo-summary-analyzer/utils';
import { handleDrop, preventDefaults, handleFileChoose } from './drop-utils';
import { diffJSON, type DiffEntry, summarizeDiff } from 'turborepo-summary-analyzer/utils/diff';

interface FileState<T> {
  name?: string;
  data?: T;
  error?: string;
  dropping: boolean;
}

export class JsonCompare extends Component {
  @tracked left: FileState<unknown> = { dropping: false };
  @tracked right: FileState<unknown> = { dropping: false };
  @tracked showUnchanged = false;

  get hasBoth() {
    return this.left.data && this.right.data;
  }

  get diff(): DiffEntry[] {
    if (!this.hasBoth) return [];
    const entries = diffJSON(this.left.data, this.right.data, { maxDepth: 6 });
    if (this.showUnchanged) return entries;
    return entries.filter((e) => e.kind !== 'same');
  }

  get summary() {
    return summarizeDiff(diffJSON(this.left.data, this.right.data));
  }

  @action toggleUnchanged() {
    this.showUnchanged = !this.showUnchanged;
  }

  async readFile(side: 'left' | 'right', file: FileList[0]) {
    try {
      const result = await readFileToJSON(file);
      this[side] = { ...this[side], name: result.name, data: result.json, error: undefined, dropping: false };
    } catch (e) {
      this[side] = { ...this[side], error: 'Failed to parse JSON', dropping: false };
      console.error(e);
    }
  }

  @action onDragover(side: 'left' | 'right', e: DragEvent) {
    preventDefaults(e);
    this[side] = { ...this[side], dropping: true };
  }

  @action onDragleave(side: 'left' | 'right', e: DragEvent) {
    preventDefaults(e);
    this[side] = { ...this[side], dropping: false };
  }

  @action async onDrop(side: 'left' | 'right', e: DragEvent) {
    preventDefaults(e);
    const file = handleDrop(
      { onError: (msg) => (this[side] = { ...this[side], error: msg }) },
      e
    );
    if (file) await this.readFile(side, file);
  }

  @action async onFileChange(side: 'left' | 'right', e: Event) {
    const file = handleFileChoose(
      { onError: (msg) => (this[side] = { ...this[side], error: msg }) },
      e
    );
    if (file) await this.readFile(side, file);
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
    <div class="compare-container">
      <div class="panes">
        <div class="pane" ...attributes>
          <h3>Left JSON</h3>
          {{#if this.left.name}}
            <p class="filename">{{this.left.name}}</p>
          {{/if}}
          {{#if this.left.error}}<p class="error">{{this.left.error}}</p>{{/if}}
          <div class="drop-zone {{if this.left.dropping 'dropping'}}" {{on 'dragover' (fn this.onDragover 'left')}} {{on 'dragleave' (fn this.onDragleave 'left')}} {{on 'drop' (fn this.onDrop 'left')}}>
            <p>Drop JSON here or <label class="file-choose">choose<input type="file" accept="application/json" hidden {{on 'change' (fn this.onFileChange 'left')}} /></label></p>
          </div>
        </div>
        <div class="pane">
          <h3>Right JSON</h3>
          {{#if this.right.name}}
            <p class="filename">{{this.right.name}}</p>
          {{/if}}
            {{#if this.right.error}}<p class="error">{{this.right.error}}</p>{{/if}}
          <div class="drop-zone {{if this.right.dropping 'dropping'}}" {{on 'dragover' (fn this.onDragover 'right')}} {{on 'dragleave' (fn this.onDragleave 'right')}} {{on 'drop' (fn this.onDrop 'right')}}>
            <p>Drop JSON here or <label class="file-choose">choose<input type="file" accept="application/json" hidden {{on 'change' (fn this.onFileChange 'right')}} /></label></p>
          </div>
        </div>
      </div>

      {{#if this.hasBoth}}
        <div class="diff-controls">
          <button type="button" {{on 'click' this.toggleUnchanged}}>
            {{if this.showUnchanged 'Hide' 'Show'}} Unchanged
          </button>
          <span class="summary">Δ Added: {{this.summary.added}} | Removed: {{this.summary.removed}} | Changed: {{this.summary.changed}} | Same: {{this.summary.same}}</span>
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
                <td class="path">{{if entry.path entry.path '(root)'}} </td>
                <td>{{this.formatValue entry.left}}</td>
                <td>{{this.formatValue entry.right}}</td>
                <td class="status">{{entry.kind}}</td>
              </tr>
            {{/each}}
          </tbody>
        </table>
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
