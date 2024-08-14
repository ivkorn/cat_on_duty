import { babel } from '@rollup/plugin-babel';
import resolve from '@rollup/plugin-node-resolve';
import terser from '@rollup/plugin-terser';
import sass from 'rollup-plugin-sass';
import cssnano from 'cssnano';
import autoprefixer from 'autoprefixer';
import postcss from 'postcss';

const env = process.env.NODE_ENV ?? 'dev';

const isProd = env === 'prod';

const postcssPlugins = () => {
  const plugins = [autoprefixer];
  if (isProd) {
    plugins.push(cssnano({ preset: 'default' }));
  }
  return plugins;
};

const rollupPlugins = () => {
  const plugins = [
    resolve(),
    sass({
      options: {
        quietDeps: true,
      },
      output: true,
      processor: (css) => postcss(postcssPlugins())
        .process(css, { from: undefined })
        .then((result) => result.css),
    }),
    babel({ babelHelpers: 'bundled' }),
  ];

  if (isProd) {
    plugins.push(terser());
  }
  return plugins;
};

export default {
  input: 'assets/js/app.js',
  output: {
    file: 'priv/static/assets/app.js',
    format: 'esm',
    inlineDynamicImports: true,
    sourcemap: true,
  },
  plugins: rollupPlugins(),
};
