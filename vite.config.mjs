import { defineConfig } from 'vite';
import { extensions, ember } from '@embroider/vite';
import { babel } from '@rollup/plugin-babel';

export default defineConfig({
  build: {
    minify: false,
    cssMinify: false,
  },
  plugins: [
    ember(),
    babel({
      babelHelpers: 'runtime',
      extensions,
    }),
  ],
  optimizeDeps: {
    exclude: [],
    include: [
      'ember-primitives',
      'nvp.ui',
      'ember-resources',
      'ember-page-title',
      'ember-modifier',
      'd3',
      'idb',
      '@observablehq/plot',
    ],
  },
});
