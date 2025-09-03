import type { DiffEntry } from './diff-json.ts';

export interface TreeNode {
  path: string[];
  key: string;
  pathKey: string;
  entry?: DiffEntry;
  children: TreeNode[];
  hasChanges: boolean;
  depth: number;
}

export function formatDiffEntries(diff: DiffEntry[]) {
  const root: TreeNode = {
    path: [],
    pathKey: 'root',
    key: 'root',
    children: [],
    hasChanges: false,
    depth: 0,
  };

  // Build tree structure from diff entries
  for (const entry of diff) {
    addEntryToTree(root, entry);
  }

  // Mark nodes that have changes
  markNodesWithChanges(root);

  return root;
}

function addEntryToTree(root: TreeNode, entry: DiffEntry) {
  let currentNode = root;

  for (let i = 0; i < entry.path.length; i++) {
    const pathSegment = entry.path[i]!;
    const currentPath = entry.path.slice(0, i + 1);
    const pathKey = currentPath.join('.');

    let childNode = currentNode.children.find(
      (child) => child.key === pathSegment
    );

    if (!childNode) {
      childNode = {
        path: currentPath,
        key: pathSegment,
        pathKey,
        children: [],
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

function markNodesWithChanges(node: TreeNode): boolean {
  let hasChanges = false;

  // Check if this node itself has changes
  if (node.entry && node.entry.kind !== 'same') {
    hasChanges = true;
  }

  // Check children recursively
  for (const child of node.children) {
    if (markNodesWithChanges(child)) {
      hasChanges = true;
    }
  }

  node.hasChanges = hasChanges;
  return hasChanges;
}
