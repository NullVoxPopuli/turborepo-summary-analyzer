import type { TOC } from '@ember/component/template-only';

export const Prompt = <template>
  <div class="prompt-display">
    <span class="prompt">❯</span>
    <pre>
      {{@command}}
    </pre>
  </div>

  <style>
    .prompt-display {
      display: grid;
      gap: 1rem;
      grid-auto-flow: column;
      justify-content: start;
      font-size: 2rem;
      padding: 1rem;
      border: 1px solid;
      border-radius: 0.25rem;
      box-shadow: inset 0px 2px 4px rgba(0, 0, 0, 0.5);

      pre {
        margin: 0;
        white-space: normal;
      }
    }
  </style>
</template> satisfies TOC<{
  Args: {
    command: string;
  };
}>;
