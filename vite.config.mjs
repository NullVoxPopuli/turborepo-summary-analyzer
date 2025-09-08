import { defineConfig, withFilter } from 'vite';
import { extensions, ember } from '@embroider/vite';
import { babel } from '@rollup/plugin-babel';

import { buildMacros } from '@embroider/macros/babel';

const macros = buildMacros();

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
