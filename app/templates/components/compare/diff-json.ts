export interface DiffEntry {
  path: string[];
  kind: 'added' | 'removed' | 'changed' | 'same';
  leftValue?: unknown;
  rightValue?: unknown;
  depth: number;
}

export interface DiffOptions {
  maxDepth?: number;
  ignoreArrayOrder?: boolean;
}

export interface DiffSummary {
  added: number;
  removed: number;
  changed: number;
  same: number;
}

/**
 * Compare two JSON objects and generate a diff
 */
export function diffJSON(
  left: unknown,
  right: unknown,
  options: DiffOptions = {},
  path: string[] = [],
  depth = 0
): DiffEntry[] {
  const { maxDepth = Infinity } = options;
  const results: DiffEntry[] = [];

  if (depth > maxDepth) {
    return [];
  }

  // Handle null/undefined cases
  if (left === null && right === null) {
    results.push({
      path: [...path],
      kind: 'same',
      leftValue: left,
      rightValue: right,
      depth,
    });
    return results;
  }

  if (left === undefined && right === undefined) {
    results.push({
      path: [...path],
      kind: 'same',
      leftValue: left,
      rightValue: right,
      depth,
    });
    return results;
  }

  // Handle cases where one side is missing
  if (left === undefined || left === null) {
    results.push({
      path: [...path],
      kind: 'added',
      rightValue: right,
      depth,
    });
    return results;
  }

  if (right === undefined || right === null) {
    results.push({
      path: [...path],
      kind: 'removed',
      leftValue: left,
      depth,
    });
    return results;
  }

  // Handle primitive types
  if (typeof left !== 'object' || typeof right !== 'object') {
    const kind = left === right ? 'same' : 'changed';
    results.push({
      path: [...path],
      kind,
      leftValue: left,
      rightValue: right,
      depth,
    });
    return results;
  }

  // Handle arrays
  if (Array.isArray(left) && Array.isArray(right)) {
    const maxLength = Math.max(left.length, right.length);

    for (let i = 0; i < maxLength; i++) {
      const leftItem = i < left.length ? left[i] as unknown : undefined;
      const rightItem = i < right.length ? right[i] as unknown : undefined;

      results.push(
        ...diffJSON(leftItem, rightItem, options, [...path, i.toString()], depth + 1)
      );
    }

    return results;
  }

  // Handle case where types don't match
  if (Array.isArray(left) !== Array.isArray(right)) {
    results.push({
      path: [...path],
      kind: 'changed',
      leftValue: left,
      rightValue: right,
      depth,
    });
    return results;
  }

  // Handle objects
  const leftObj = left as Record<string, unknown>;
  const rightObj = right as Record<string, unknown>;

  const allKeys = new Set([
    ...Object.keys(leftObj),
    ...Object.keys(rightObj),
  ]);

  for (const key of allKeys) {
    const leftValue = leftObj[key];
    const rightValue = rightObj[key];

    results.push(
      ...diffJSON(leftValue, rightValue, options, [...path, key], depth + 1)
    );
  }

  return results;
}

/**
 * Summarize diff results into counts
 */
export function summarizeDiff(diffEntries: DiffEntry[]): DiffSummary {
  return diffEntries.reduce(
    (summary, entry) => {
      summary[entry.kind]++;
      return summary;
    },
    { added: 0, removed: 0, changed: 0, same: 0 }
  );
}

/**
 * Format a value for display in the diff viewer
 */
export function formatValue(value: unknown): string {
  if (value === null) return 'null';
  if (value === undefined) return 'undefined';
  if (typeof value === 'string') return `"${value}"`;
  if (typeof value === 'number' || typeof value === 'boolean') return String(value);

  try {
    return JSON.stringify(value, null, 2);
  } catch {
    if (typeof value === 'object' && value !== null) {
      return '[Complex Object]';
    }
    if (typeof value === 'function') {
      return '[Function]';
    }
    if (typeof value === 'symbol') {
      return '[Symbol]';
    }
    if (typeof value === 'bigint') {
      return String(value);
    }
    return '[Unknown]';
  }
}

/**
 * Get a human-readable path string
 */
export function formatPath(path: string[]): string {
  if (path.length === 0) return 'root';

  return path.reduce((result, segment, index) => {
    // Check if segment is a number (array index)
    if (/^\d+$/.test(segment)) {
      return `${result}[${segment}]`;
    }

    // Check if we need dot notation
    if (index === 0) {
      return segment;
    }

    // Check if the key needs brackets (contains special characters)
    if (/^[a-zA-Z_$][a-zA-Z0-9_$]*$/.test(segment)) {
      return `${result}.${segment}`;
    } else {
      return `${result}["${segment}"]`;
    }
  }, '');
}
