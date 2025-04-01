import { defineConfig } from 'vite';
import { extensions, classicEmberSupport, ember } from '@embroider/vite';
import { babel } from '@rollup/plugin-babel';

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
 * 1. buildStart
 * 2. handleHotUpdate
 *
 * Whenever a browser tab is active
 * 1. transformIndexHTML (per HTML entry point (app, tests))
 */
export default defineConfig({
  plugins: [
    classicEmberSupport(),
    ember(),
    {
      name: 'build-time-reporter',
      // 1. start
      configResolved() {
        console.log('configResolved', time());
      },
      // 2. start
      options() {
        console.log('options', time());
      },
      // 3. start
      configureServer() {
        console.log('configureServer', time());
      },
      // 4. start
      buildStart() {
        console.log('buildStart', time());
      },
      // 5. post-start, after prebuild finishes
      //   -> waiting for browser access
      handleHotUpdate() {
        console.log('handleHotUpdate', time());
      },
      buildEnd() {
        console.log('buildEnd', time());
      },
      closeBundle() {
        console.log('closeBundle', time());
      },
      generateBundle() {
        console.log('generateBundle', time());
      },
      // On page load: twice
      // - on file change, this also prints twice
      transformIndexHtml() {
        console.log('transformIndexHtml', time());
      },
      configurePreviewServer() {
        console.log('configurePreviewServer', time());
      },
    },
    // extra plugins here
    babel({
      babelHelpers: 'runtime',
      extensions,
    }),
  ],
});
