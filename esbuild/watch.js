import * as esbuild from 'esbuild';
import config from './config.js';

(async () => {
  const ctx = await esbuild.context(config);
  await ctx.watch();
})();
