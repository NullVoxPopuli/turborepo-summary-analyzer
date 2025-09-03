import JsonTreeNode from './json-tree-node.gts';


<template>
  <ul class="json-tree-view">
    {{#each @diff as |entry|}}
      <JsonTreeNode @entry={{entry}} />
    {{/each}}
  </ul>

  <style>
    .json-tree-view {
      list-style: none;
      padding-left: 0;
      font-size: .95rem;
    }
  </style>
</template>
