export interface SummaryFile {
  id: string;
  version: '1'; // so far
  turboVersoin: string;
  monorepo: boolean;
  globalCacheInputs: {
    rootKey: string;
    files: Record<string, string>;
    hashOfExternalDependencies: string;
    hashOfInternalDependencies: string;
    environmentVariables: {
      specified: {
        env: unknown;
        passThroughEnv: unknown;
      };
      configured: unknown;
      inferred: unknown;
      passthrough: unknown;
    };
    engines: Record<string, string>;
  };
  execution: {
    command: string;
    repoPath: string;
    // # tasks
    success: number;
    // # tasks
    failed: number;
    // # tasks
    cached: number;
    // # tasks
    attempted: number;
    // ms
    startTime: number;
    // ms
    endTime: number;
    exitCode: number;
  };
  packages: string[];
  envMode: 'loose' | 'strict';
  frameworkInference: boolean;
  tasks: SummaryTask[];
}

export interface SummaryTask {
  // package name + task name
  taskId: string;
  task: string;
  package: string;
  hash: string;
  inputs: Record<string, string>;
  hashOfExternalDependencies: string;
  cache: {
    local: boolean;
    remote: boolean;
    status: 'MISS' | 'HIT';
    timeSoved: number;
  };
  command: string;
  cliArguments: string[];
  outputs: null | string[];
  excludeOutputs: null | string[];
  logFile: string;
  directory: string;
  // Array of taskIds
  dependencies: string[];
  // Array of taskIds
  dependents: string[];
  resolvedTaskDefinition: {
    outputs: string[];
    cache: boolean;
    dependsOn: string[];
    inputs: string[];
    outputLogs: unknown;
    persistent: boolean;
    interruptible: boolean;
    env: string[];
    passThroughEnv: unknown;
    interactive: boolean;
  };
  expandedOutputs: string[];
  framework: string;
  envMode: 'loose' | 'strict';
  environmentVariables: {
    specified: {
      env: string[];
      passThroughEnv: unknown;
    };
    configured: unknown;
    inferred: unknown;
    passthrough: unknown;
  };
  execution: {
    startTime: number;
    endTime: number;
    exitCode: number;
  };
}
