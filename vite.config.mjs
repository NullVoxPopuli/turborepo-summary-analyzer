import { defineConfig } from 'vite';
import { extensions, ember } from '@embroider/vite';
import { babel } from '@rollup/plugin-babel';
import { buildTime } from 'vite-plugin-buildtime';

import Inspect from 'vite-plugin-inspect';

const load = Date.now();
function time() {
  return Date.now() - load;
}

/**
 * On boot
 * 1. configResolved
 * 2. options
 * 3. configureServer
 * 4. buildStart
 * 5. handleHotUpdate
 *
 * On config file change (this file)
 * -5. configResolved
 * -4. options
 * -3. configureServer
 * -2. buildEnd
 * -1. closeBundle
 * 1. buildStart
 * 2. handleHotUpdate
 *
 * Whenever a browser tab is active
 * 1. transformIndexHTML (per HTML entry point (app, tests))
 *
 * Whenever a file is saved with no changes
 * 0. nothing -- however, if a browser tab is open, the above still holds true
 *
 * Whenever a file is saved with changes
 * 1. handleHotUpdate
 * 2. transformIndexHTML
 */

const tracking = `${process.cwd()}/node_modules/ember-source/dist/packages/@glimmer/tracking/index.js`;
const cache = `${process.cwd()}/node_modules/ember-source/dist/packages/@glimmer/tracking/primitives/cache.js`;

const data = new WeakMap();
const sets = new Set();

let lastStart;
let finishedBoot = false;
let lastUpdate;

export default defineConfig({
  resolve: {
    alias: {
      '@embroider/util': 'node_modules/@embroider/util/addon/index.js',

      '@glimmer/tracking/primitives/cache': cache,

      '@glimmer/tracking': tracking,
    },
  },
  plugins: [
    // _inspect
    Inspect(),
    buildTime((data) => {
      console.log(data);
    }),
    ember(),
    babel({
      babelHelpers: 'runtime',
      extensions,
    }),
  ],
});
