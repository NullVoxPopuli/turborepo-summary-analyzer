import Component from '@glimmer/component';

interface TreeEntry {
  path: string;
  left: unknown;
  right: unknown;
  kind: string;
  children?: TreeEntry[];
}
// eslint-disable-next-line ember/no-empty-glimmer-component-classes
export default class JsonTreeNode extends Component<{
  entry: TreeEntry;
}> {

  <template>
    <li class="tree-node {{@entry.kind}}">
      <div class="tree-node-content">
        <span class="path">{{@entry.path}}</span>
        <span class="left">{{@entry.left}}</span>
        <span class="right">{{@entry.right}}</span>
        <span class="status">{{@entry.kind}}</span>
      </div>
      {{#if @entry.children}}
        <ul>
          {{#each @entry.children as |child|}}
            <JsonTreeNode @entry={{child}} />
          {{/each}}
        </ul>
      {{/if}}
    </li>

    <style>
      .tree-node { margin-left: 1rem; }
      .tree-node-content { display: flex; gap: 1rem; align-items: center; }
      .path { font-family: monospace; }
      .status { text-transform: uppercase; font-size: .7rem; }
      .left, .right { font-size: .9rem; }
      .added { background: #123d12; }
      .removed { background: #3d1212; }
      .changed { background: #2d2d12; }
      .same { opacity: .6; }
    </style>
  </template>

  }
