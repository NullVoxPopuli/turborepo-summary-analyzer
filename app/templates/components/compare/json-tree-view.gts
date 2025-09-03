import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import { cached } from '@glimmer/tracking';
import { fn } from '@ember/helper';
import { TrackedMap } from 'tracked-built-ins';
import { type DiffEntry, formatValue, formatPath } from './diff-json';
import { formatDiffEntries, type TreeNode } from './tree-utils.ts';
import './json-tree-view.css';
import type { TOC } from '@ember/component/template-only';

interface Args {
  diff: DiffEntry[];
}

function eq(a, b) {
  return a === b;
}

// taskId, package, inputs, hashOfExternalDependencies, directory, 'dependencies, dependents
const KEYS_TO_HIDE = new Set([
  'execution',
  'hash',
  'expandedOutputs',
  'cache',
  'logFile',
  'framework',
]);

function isHiddenKey(key: string) {
  return KEYS_TO_HIDE.has(key);
}

function isNotHiddenKey(key: string) {
  return !isHiddenKey(key);
}

export default class JsonTreeView extends Component<Args> {
  expandedPaths = new TrackedMap<string, boolean>();

  @cached
  get treeData(): TreeNode {
    const data = formatDiffEntries(this.args.diff);

    return data;
  }

  toggleExpanded = (node: TreeNode) => {
    const existing = this.isExpanded(node);
    this.expandedPaths.set(node.pathKey, !existing);
  };

  shouldShowNode(node: TreeNode): boolean {
    const hasChanges =
      node.hasChanges ||
      node.children.some((child) => this.shouldShowNode(child));

    return hasChanges;
  }

  isExpanded = (node: TreeNode): boolean => {
    const existing = this.expandedPaths.get(node.pathKey);

    if (existing === undefined) {
      return false;
    }
    return existing;
  };

  <template>
    <div class="json-tree-view">
      {{#if this.treeData.children.length}}
        {{#each this.treeData.children as |child|}}
          <TreeNode
            @node={{child}}
            @toggleExpanded={{this.toggleExpanded}}
            @isExpanded={{this.isExpanded}}
            @hasChanges={{this.shouldShowNode}}
          />
        {{/each}}
      {{else}}
        <div class="no-changes">No differences found</div>
      {{/if}}
    </div>
  </template>
}

const TreeNode: TOC<{
  Args: {
    node: TreeNode;
    toggleExpanded: (node: TreeNode) => void;
    isExpanded: (node: TreeNode) => boolean;
    hasChanges: (node: TreeNode) => boolean;
  };
}> = <template>
  {{#if (@hasChanges @node)}}
    {{#if (isNotHiddenKey @node.key)}}
      <details class="tree-node" open={{@isExpanded @node}}>
        <summary class="tree-line">
          <span>
            {{#if @node.children.length}}
              <button
                type="button"
                class="toggle expandable"
                {{on "click" (fn @toggleExpanded @node)}}
                aria-label={{if (@isExpanded @node) "Collapse" "Expand"}}
              >
                {{if (@isExpanded @node) "▼" "▶"}}
              </button>
            {{else}}
              <span class="toggle"></span>
            {{/if}}

            <span class="key">{{@node.key}}</span>

            {{#if @node.path.length}}
              <span class="path-indicator">{{formatPath @node.path}}</span>
            {{/if}}
          </span>

          {{#if @node.entry}}
            <div class="value value-{{@node.entry.kind}}">
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
                <del class="removed-wrapper">
                  <span class="side-label">Left</span>
                  <pre>{{formatValue @node.entry.leftValue}}</pre>
                </del>
              {{else if (eq @node.entry.kind "added")}}
                <ins class="added-wrapper">
                  <span class="side-label">Right</span>
                  <pre>{{formatValue @node.entry.rightValue}}</pre>
                </ins>
              {{else}}
                <pre>{{formatValue @node.entry.leftValue}}</pre>
              {{/if}}
            </div>
          {{/if}}

        </summary>

        {{#if (@isExpanded @node)}}
          {{#if @node.children}}
            <ul>
              {{#each @node.children as |child|}}
                <li>
                  <TreeNode
                    @node={{child}}
                    @toggleExpanded={{@toggleExpanded}}
                    @isExpanded={{@isExpanded}}
                    @hasChanges={{@hasChanges}}
                  />
                </li>
              {{/each}}
            </ul>
          {{/if}}
        {{/if}}
      </details>
    {{/if}}
  {{/if}}
</template>;
