import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import {
  type DiffEntry,
  formatValue,
  formatPath,
} from 'turborepo-summary-analyzer/templates/components/compare/diff-json';

interface Args {
  diff: DiffEntry[];
}

interface TreeNode {
  path: string[];
  key: string;
  entry?: DiffEntry;
  children: TreeNode[];
  isExpanded: boolean;
  hasChanges: boolean;
  depth: number;
}

function eq(a, b) {
  return a === b;
}

function and(a, b) {
  return a && b;
}

export default class JsonTreeView extends Component<Args> {
  @tracked expandedPaths = new Set<string>();

  get treeData(): TreeNode {
    const root: TreeNode = {
      path: [],
      key: 'root',
      children: [],
      isExpanded: true,
      hasChanges: false,
      depth: 0,
    };

    // Build tree structure from diff entries
    for (const entry of this.args.diff) {
      this.addEntryToTree(root, entry);
    }

    // Mark nodes that have changes
    this.markNodesWithChanges(root);

    return root;
  }

  private addEntryToTree(root: TreeNode, entry: DiffEntry) {
    let currentNode = root;

    for (let i = 0; i < entry.path.length; i++) {
      const pathSegment = entry.path[i];
      const currentPath = entry.path.slice(0, i + 1);
      const pathKey = currentPath.join('.');

      let childNode = currentNode.children.find(child => child.key === pathSegment);

      if (!childNode) {
        childNode = {
          path: currentPath,
          key: pathSegment,
          children: [],
          isExpanded: this.expandedPaths.has(pathKey) || currentPath.length <= 2,
          hasChanges: false,
          depth: i + 1,
        };
        currentNode.children.push(childNode);
      }

      currentNode = childNode;
    }

    // Set the entry for the leaf node
    currentNode.entry = entry;
  }

  private markNodesWithChanges(node: TreeNode): boolean {
    let hasChanges = false;

    // Check if this node itself has changes
    if (node.entry && node.entry.kind !== 'same') {
      hasChanges = true;
    }

    // Check children recursively
    for (const child of node.children) {
      if (this.markNodesWithChanges(child)) {
        hasChanges = true;
      }
    }

    node.hasChanges = hasChanges;
    return hasChanges;
  }

  toggleExpanded = (node: TreeNode) => {
    const pathKey = node.path.join('.');

    if (node.isExpanded) {
      this.expandedPaths.delete(pathKey);
    } else {
      this.expandedPaths.add(pathKey);
    }

    node.isExpanded = !node.isExpanded;
  };

  getIndentStyle(depth: number) {
    return `margin-left: ${depth * 20}px;`;
  }

  getValueClass(kind: DiffEntry['kind']) {
    return `value-${kind}`;
  }

  shouldShowNode(node: TreeNode): boolean {
    // Always show nodes with changes or their ancestors
    return node.hasChanges || node.children.some(child => this.shouldShowNode(child));
  }

  <template>
    <div class="json-tree-view">
      {{#if this.treeData.children.length}}
        {{#each this.treeData.children as |child|}}
          <TreeNode
            @node={{child}}
            @toggleExpanded={{this.toggleExpanded}}
            @getIndentStyle={{this.getIndentStyle}}
            @getValueClass={{this.getValueClass}}
            @shouldShow={{this.shouldShowNode}}
          />
        {{/each}}
      {{else}}
        <div class="no-changes">No differences found</div>
      {{/if}}
    </div>

    <style>
      .json-tree-view {
        font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
        font-size: 14px;
        line-height: 1.4;
        background: #1e1e1e;
        border-radius: 4px;
        padding: 1rem;
        max-height: 600px;
        overflow-y: auto;
      }

      .no-changes {
        color: #888;
        font-style: italic;
        text-align: center;
        padding: 2rem;
      }

      .tree-node {
        margin: 2px 0;
      }

      .tree-line {
        display: flex;
        align-items: flex-start;
        padding: 2px 0;
        border-radius: 2px;
      }

      .tree-line:hover {
        background: rgba(255, 255, 255, 0.05);
      }

      .toggle {
        width: 16px;
        height: 16px;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        color: #666;
        user-select: none;
        flex-shrink: 0;
        background: none;
        border: none;
        padding: 0;
        font: inherit;
      }

      .toggle:hover {
        color: #aaa;
      }

      .toggle.expandable {
        color: #888;
      }

      .key {
        color: #9cdcfe;
        margin-right: 8px;
        font-weight: 500;
      }

      .colon {
        color: #d4d4d4;
        margin-right: 8px;
      }

      .value {
        flex: 1;
        min-width: 0;
      }

      .value-same {
        color: #d4d4d4;
      }

      .value-added {
        color: #4ec9b0;
        background: rgba(78, 201, 176, 0.1);
        border-left: 3px solid #4ec9b0;
        padding-left: 6px;
      }

      .value-removed {
        color: #f48771;
        background: rgba(244, 135, 113, 0.1);
        border-left: 3px solid #f48771;
        padding-left: 6px;
        text-decoration: line-through;
      }

      .added-wrapper {
        color: #4ec9b0;
        background: rgba(78, 201, 176, 0.1);
        border-left: 3px solid #4ec9b0;
        padding-left: 6px;
        position: relative;
      }

      .removed-wrapper {
        color: #f48771;
        background: rgba(244, 135, 113, 0.1);
        border-left: 3px solid #f48771;
        padding-left: 6px;
        text-decoration: line-through;
        position: relative;
      }

      .value-changed {
        display: flex;
        flex-direction: column;
        gap: 2px;
      }

      .value-changed .old-value {
        color: #f48771;
        background: rgba(244, 135, 113, 0.1);
        border-left: 3px solid #f48771;
        padding-left: 6px;
        text-decoration: line-through;
        position: relative;
      }

      .value-changed .new-value {
        color: #4ec9b0;
        background: rgba(78, 201, 176, 0.1);
        border-left: 3px solid #4ec9b0;
        padding-left: 6px;
        position: relative;
      }

      .side-label {
        position: absolute;
        right: 8px;
        top: 4px;
        font-size: 10px;
        font-weight: bold;
        opacity: 0.8;
        background: rgba(0, 0, 0, 0.3);
        padding: 2px 6px;
        border-radius: 3px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
      }

      .path-indicator {
        color: #6a9955;
        font-size: 12px;
        opacity: 0.7;
        margin-left: 8px;
      }

      pre {
        margin: 0;
        white-space: pre-wrap;
        word-break: break-word;
      }
    </style>
  </template>
}

const TreeNode = <template>
  {{#if (@shouldShow @node)}}
    <div class="tree-node" style={{@getIndentStyle @node.depth}}>
      <div class="tree-line">
        {{#if @node.children.length}}
          <button
            type="button"
            class="toggle expandable"
            {{on "click" (fn @toggleExpanded @node)}}
            aria-label={{if @node.isExpanded "Collapse" "Expand"}}
          >
            {{if @node.isExpanded "▼" "▶"}}
          </button>
        {{else}}
          <span class="toggle"></span>
        {{/if}}

        <span class="key">{{@node.key}}</span>

        {{#if @node.entry}}
          <span class="colon">:</span>
          <div class="value {{@getValueClass @node.entry.kind}}">
            {{#if (eq @node.entry.kind "changed")}}
              <div class="old-value">
                <span class="side-label">Left</span>
                <pre>{{formatValue @node.entry.leftValue}}</pre>
              </div>
              <div class="new-value">
                <span class="side-label">Right</span>
                <pre>{{formatValue @node.entry.rightValue}}</pre>
              </div>
            {{else if (eq @node.entry.kind "removed")}}
              <div class="removed-wrapper">
                <span class="side-label">Left</span>
                <pre>{{formatValue @node.entry.leftValue}}</pre>
              </div>
            {{else if (eq @node.entry.kind "added")}}
              <div class="added-wrapper">
                <span class="side-label">Right</span>
                <pre>{{formatValue @node.entry.rightValue}}</pre>
              </div>
            {{else}}
              <pre>{{formatValue @node.entry.leftValue}}</pre>
            {{/if}}
          </div>
        {{/if}}

        {{#if @node.path.length}}
          <span class="path-indicator">{{formatPath @node.path}}</span>
        {{/if}}
      </div>

      {{#if @node.isExpanded}}
        {{#if @node.children.length}}
          {{#each @node.children as |child|}}
            <TreeNode
              @node={{child}}
              @toggleExpanded={{@toggleExpanded}}
              @getIndentStyle={{@getIndentStyle}}
              @getValueClass={{@getValueClass}}
              @shouldShow={{@shouldShow}}
            />
          {{/each}}
        {{/if}}
      {{/if}}
    </div>
  {{/if}}
</template>
