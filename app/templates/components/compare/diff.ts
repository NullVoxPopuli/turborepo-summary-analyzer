// Lightweight JSON diff tailored for SummaryFile structures.
// Produces a flat list of path-based differences for ease of rendering.
// This avoids pulling in a large dependency and keeps output predictable.

export type DiffKind = 'added' | 'removed' | 'changed' | 'same';

export interface DiffEntry {
  path: string; // dot/bracket notation path
  left: unknown;
  right: unknown;
  kind: DiffKind;
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
  const results: DiffEntry[] = [];

  function walk(l: unknown, r: unknown, path: string, depth: number) {
    if (depth > maxDepth) {
      // treat as changed when exceeding depth to avoid large output
      if (l !== r) {
        results.push({ path, left: l, right: r, kind: 'changed' });
      } else {
        results.push({ path, left: l, right: r, kind: 'same' });
      }
      return;
    }

    if (l === undefined && r !== undefined) {
      results.push({ path, left: undefined, right: r, kind: 'added' });
      return;
    }
    if (l !== undefined && r === undefined) {
      results.push({ path, left: l, right: undefined, kind: 'removed' });
      return;
    }

    // primitives
    if (
      typeof l !== 'object' || l === null ||
      typeof r !== 'object' || r === null
    ) {
      results.push({ path, left: l, right: r, kind: l === r ? 'same' : 'changed' });
      return;
    }

    // arrays
    if (Array.isArray(l) && Array.isArray(r)) {
      const max = Math.max(l.length, r.length);
      for (let i = 0; i < max; i++) {
        walk(l[i], r[i], `${path}[${i}]`, depth + 1);
      }
      return;
    }
    if (Array.isArray(l) && !Array.isArray(r)) {
      results.push({ path, left: l, right: r, kind: 'changed' });
      return;
    }
    if (!Array.isArray(l) && Array.isArray(r)) {
      results.push({ path, left: l, right: r, kind: 'changed' });
      return;
    }

    // objects
    if (isObject(l) && isObject(r)) {
      const keys = new Set([...Object.keys(l), ...Object.keys(r)]);
      for (const key of keys) {
        // Indexing with key yields unknown; acceptable for recursive diff.
        // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-explicit-any
        const lVal: unknown = (l as any)[key];
        // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-explicit-any
        const rVal: unknown = (r as any)[key];
        walk(lVal, rVal, path ? `${path}.${key}` : key, depth + 1);
      }
      return;
    }

    // fallback
    results.push({ path, left: l, right: r, kind: l === r ? 'same' : 'changed' });
  }

  walk(left, right, '', 0);

  return results;
}

export function summarizeDiff(entries: DiffEntry[]) {
  return entries.reduce(
    (acc, e) => {
      acc[e.kind]++;
      return acc;
    },
    { added: 0, removed: 0, changed: 0, same: 0 }
  );
}
