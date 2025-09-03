// Lightweight JSON diff tailored for SummaryFile structures.
// Produces a flat list of path-based differences for ease of rendering.
// This avoids pulling in a large dependency and keeps output predictable.

export type DiffKind = 'added' | 'removed' | 'changed' | 'same';

export interface DiffEntry {
  path: string; // dot/bracket notation path
  left: unknown;
  right: unknown;
  kind: DiffKind;
  children?: DiffEntry[];
}

interface DiffOptions {
  maxDepth?: number; // safeguard against super deep / cyclical data
}

const isObject = (v: unknown): v is Record<string, unknown> =>
  typeof v === 'object' && v !== null && !Array.isArray(v);

export function diffJSON(
  left: unknown,
  right: unknown,
  { maxDepth = 8 }: DiffOptions = {}
): DiffEntry[] {
  function walk(l: unknown, r: unknown, path: string, depth: number): DiffEntry {
    if (depth > maxDepth) {
      return {
        path,
        left: l,
        right: r,
        kind: l === r ? 'same' : 'changed',
      };
    }

    if (l === undefined && r !== undefined) {
      return { path, left: undefined, right: r, kind: 'added' };
    }
    if (l !== undefined && r === undefined) {
      return { path, left: l, right: undefined, kind: 'removed' };
    }

    // primitives
    if (
      typeof l !== 'object' || l === null ||
      typeof r !== 'object' || r === null
    ) {
      return { path, left: l, right: r, kind: l === r ? 'same' : 'changed' };
    }

    // arrays
    if (Array.isArray(l) && Array.isArray(r)) {
      const max = Math.max(l.length, r.length);
      const children: DiffEntry[] = [];
      for (let i = 0; i < max; i++) {
        children.push(walk(l[i], r[i], `${path}[${i}]`, depth + 1));
      }
      return {
        path,
        left: l,
        right: r,
        kind: 'same', // parent node, children will show diffs
        children,
      };
    }
    if (Array.isArray(l) && !Array.isArray(r)) {
      return { path, left: l, right: r, kind: 'changed' };
    }
    if (!Array.isArray(l) && Array.isArray(r)) {
      return { path, left: l, right: r, kind: 'changed' };
    }

    // objects
    if (isObject(l) && isObject(r)) {
      const keys = new Set([...Object.keys(l), ...Object.keys(r)]);
      const children: DiffEntry[] = [];
      for (const key of keys) {
        // Indexing with key yields unknown; acceptable for recursive diff.
        // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-explicit-any
        const lVal: unknown = (l as any)[key];
        // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-explicit-any
        const rVal: unknown = (r as any)[key];
        children.push(walk(lVal, rVal, path ? `${path}.${key}` : key, depth + 1));
      }
      return {
        path,
        left: l,
        right: r,
        kind: 'same', // parent node, children will show diffs
        children,
      };
    }

    // fallback
    return { path, left: l, right: r, kind: l === r ? 'same' : 'changed' };
  }

  // Recursively flatten all diff entries for summary and rendering
  function flatten(entry: DiffEntry): DiffEntry[] {
    if (!entry.children || entry.children.length === 0) {
      return [entry];
    }
    // Include parent node only if it's not 'same' or if it has no children
    const childEntries = entry.children.flatMap(flatten);
    if (entry.kind !== 'same') {
      return [entry, ...childEntries];
    }
    return childEntries;
  }
  const root = walk(left, right, '', 0);
  return flatten(root);
}

export function summarizeDiff(entries: DiffEntry[]) {
  // Summarize all entries, including children
  const summary = { added: 0, removed: 0, changed: 0, same: 0 };
  for (const e of entries) {
    summary[e.kind]++;
  }
  return summary;
}
