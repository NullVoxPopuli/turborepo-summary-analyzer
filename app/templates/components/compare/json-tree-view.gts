import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import { cached } from '@glimmer/tracking';
import { fn } from '@ember/helper';
import { trackedMap, trackedSet } from '@ember/reactive/collections';
import { type DiffEntry, formatValue, formatPath } from './diff-json';
import { formatDiffEntries, type TreeNode } from './tree-utils.ts';
import './json-tree-view.css';
import type { TOC } from '@ember/component/template-only';

interface Args {
  diff: DiffEntry[];
}

function eq(a: unknown, b: unknown) {
  return a === b;
}

// taskId, package, inputs, hashOfExternalDependencies, directory, 'dependencies, dependents
const KEYS_TO_HIDE = trackedSet([
  'execution',
  'hash',
  'expandedOutputs',
  'cache',
  'logFile',
  'framework',
]);

const HIDEABLE_KEYS = [
  'execution',
  'hash',
  'expandedOutputs',
  'cache',
  'logFile',
  'framework',
  'taskId',
  'package',
  'inputs',
  'hashOfExternalDependencies',
  'directory',
  'dependencies',
  'dependents',
];

function isHiddenKey(key: string) {
  return KEYS_TO_HIDE.has(key);
}

function isNotHiddenKey(key: string) {
  return !isHiddenKey(key);
}

function toggleHide(key: string) {
  if (isHiddenKey(key)) {
    KEYS_TO_HIDE.delete(key);
    return;
  }
  KEYS_TO_HIDE.add(key);
}

export default class JsonTreeView extends Component<Args> {
  expandedPaths = trackedMap<string, boolean>();

  @cached
  get treeData(): TreeNode {
    const data = formatDiffEntries(this.args.diff);

    return data;
  }

  toggleExpanded = (node: TreeNode) => {
    const existing = this.isExpanded(node);
    this.expandedPaths.set(node.pathKey, !existing);
  };

  shouldShowNode = (node?: TreeNode | TreeNode[]): boolean => {
    if (!node) return false;

    if (Array.isArray(node)) {
      const collectionHasChanges = node.some((child) =>
        this.shouldShowNode(child)
      );

      return collectionHasChanges;
    }

    const hasVisibleFields =
      node.children.length > 0
        ? node.children.some((child) => !KEYS_TO_HIDE.has(child.key))
        : true;

    if (!hasVisibleFields) {
      return false;
    }

    const visibleChildren = node.children.filter((child) =>
      this.shouldShowNode(child)
    );

    if (node.children.length > 0 && visibleChildren.length === 0) {
      return false;
    }

    const hasChanges = node.hasChanges || visibleChildren.length > 0;

    return hasChanges;
  };

  isExpanded = (node: TreeNode): boolean => {
    const existing = this.expandedPaths.get(node.pathKey);

    if (existing === undefined) {
      return false;
    }
    return existing;
  };

  <template>
    <fieldset><legend>Keys to hide</legend>
      {{#each HIDEABLE_KEYS as |key|}}
        <label>
          <input
            type="checkbox"
            checked={{isHiddenKey key}}
            {{on "change" (fn toggleHide key)}}
          />
          {{key}}
        </label>
      {{/each}}
    </fieldset>
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
    hasChanges: (node?: TreeNode | TreeNode[]) => boolean;
  };
}> = <template>
  {{#if (@hasChanges @node)}}
    {{#if (isNotHiddenKey @node.key)}}
      <details class="tree-node" open={{@isExpanded @node}}>
        <summary class="tree-line">
          <span>
            {{#if @node.children.length}}
              {{! template-lint-disable no-nested-interactive }}
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
          {{#if (@hasChanges @node.children)}}
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
