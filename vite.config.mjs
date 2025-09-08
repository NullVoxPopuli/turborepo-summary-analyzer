import { defineConfig } from 'vite';
import { extensions, ember } from '@embroider/vite';
import { babel } from '@rollup/plugin-babel';

export default defineConfig({
  plugins: [
    ember(),
    babel({
      babelHelpers: 'runtime',
      extensions,
    }),
  ],
  optimizeDeps: {
    exclude: [
      'ember-primitives',
      '@universal-ember/preem',
      'ember-resources',
      'ember-source',
    ],
    include: [
      'ember-page-title',
      'ember-modifier',
      'd3',
      'idb',
      '@observablehq/plot',
    ],
  },
});
