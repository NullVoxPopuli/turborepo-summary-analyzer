import Component from '@glimmer/component';

interface TreeEntry {
  path: string;
  left: unknown;
  right: unknown;
  kind: string;
  children?: TreeEntry[];
}

function eq(a, b) {
  return a === b;
}

export default class JsonTreeNode extends Component<{
  entry: TreeEntry;
}> {
  get isLeaf() {
    return !this.args.entry.children || this.args.entry.children.length === 0;
  }

  get formattedLeft() {
    const v = this.args.entry.left;
    if (typeof v === 'string') return v;
    try {
      return JSON.stringify(v, null, 2);
    } catch {
      return String(v);
    }
  }
  get formattedRight() {
    const v = this.args.entry.right;
    if (typeof v === 'string') return v;
    try {
      return JSON.stringify(v, null, 2);
    } catch {
      return String(v);
    }
  }

  <template>
    <li class="tree-node {{@entry.kind}}">
      <div class="tree-node-content">
        <span class="diff-icon">
          {{#if (eq @entry.kind "added")}}➕{{/if}}
          {{#if (eq @entry.kind "removed")}}➖{{/if}}
          {{#if (eq @entry.kind "changed")}}✏️{{/if}}
          {{#if (eq @entry.kind "same")}}✔️{{/if}}
        </span>
        <span class="path">{{@entry.path}}</span>
        <span class="status">{{@entry.kind}}</span>
        {{#if this.isLeaf}}
          <span class="value-pair">
            <span class="value-label left-label">Left:</span>
            <span class="left value">{{this.formattedLeft}}</span>
            <span class="value-label right-label">Right:</span>
            <span class="right value">{{this.formattedRight}}</span>
          </span>
        {{/if}}
      </div>
      {{#if @entry.children}}
        <ul class="tree-children">
          {{#each @entry.children as |child|}}
            <JsonTreeNode @entry={{child}} />
          {{/each}}
        </ul>
      {{/if}}
    </li>

    <style>
      .tree-node {
        margin-left: 1rem;
        border-radius: 6px;
        box-shadow: 0 1px 4px rgba(0,0,0,0.07);
        padding: 0.25rem 0.5rem;
        margin-bottom: 0.25rem;
        transition: background 0.2s;
      }
      .tree-node-content {
        display: flex;
        gap: 1rem;
        align-items: center;
        padding: 0.15rem 0;
      }
      .diff-icon {
        font-size: 1.1rem;
        width: 1.5rem;
        text-align: center;
      }
      .path {
        font-family: monospace;
        font-weight: 500;
        color: #2a2a2a;
        background: #f6f6f6;
        border-radius: 3px;
        padding: 0.1rem 0.3rem;
      }
      .status {
        text-transform: uppercase;
        font-size: .75rem;
        font-weight: bold;
        letter-spacing: 0.05em;
        color: #888;
      }
      .value-pair {
        display: flex;
        gap: 0.5rem;
        align-items: center;
        background: #f9f9f9;
        border-radius: 4px;
        padding: 0.1rem 0.4rem;
        font-size: 0.92rem;
      }
      .value-label {
        font-size: 0.8rem;
        color: #666;
        font-weight: 500;
        margin-right: 0.2rem;
      }
      .left.value {
        color: #1a4d1a;
        font-weight: 500;
        background: #eafbe7;
        border-radius: 2px;
        padding: 0.05rem 0.2rem;
      }
      .right.value {
        color: #4d1a1a;
        font-weight: 500;
        background: #fbe7e7;
        border-radius: 2px;
        padding: 0.05rem 0.2rem;
      }
      .added {
        background: linear-gradient(90deg, #eafbe7 0%, #d4f7c5 100%);
      }
      .removed {
        background: linear-gradient(90deg, #fbe7e7 0%, #f7c5c5 100%);
      }
      .changed {
        background: linear-gradient(90deg, #fffbe7 0%, #f7f3c5 100%);
      }
      .same {
        opacity: .6;
        background: #f6f6f6;
      }
      .tree-children {
        list-style: none;
        margin-left: 1.5rem;
        padding-left: 0;
      }
    </style>
  </template>

  }
