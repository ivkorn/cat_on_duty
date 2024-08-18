import path from 'node:path';
import { sassPlugin } from 'esbuild-sass-plugin';
import postcss from 'postcss';
import postcssPresetEnv from 'postcss-preset-env';

const env = process.env.NODE_ENV ?? 'dev';

const isProd = env === 'prod';

const minify = isProd;

const entryPoints = [path.resolve(import.meta.dirname, '..', 'assets', 'js', 'app.js')];

const outfile = path.resolve(import.meta.dirname, '..', 'priv', 'static', 'assets', 'app.js');

const config = {
  minify,
  entryPoints,
  outfile,
  target: ['es6'],
  bundle: true,
  sourcemap: true,
  plugins: [sassPlugin({
    silenceDeprecations: ['mixed-decls'],
    sourceMap: true,
    sourceMapIncludeSources: true,
    async transform(source) {
      const { css } = await postcss([postcssPresetEnv()]).process(source, { from: undefined });
      return css;
    },
  })],
};

export default config;
