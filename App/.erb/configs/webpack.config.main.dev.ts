/**
 * Webpack config for development electron main process
 */

import path from 'path';
import webpack from 'webpack';
import { BundleAnalyzerPlugin } from 'webpack-bundle-analyzer';
import { merge } from 'webpack-merge';
import checkNodeEnv from '../scripts/check-node-env';
import baseConfig from './webpack.config.base';
import webpackPaths from './webpack.paths';

// When an ESLint server is running, we can't set the NODE_ENV so we'll check if it's
// at the dev webpack config is not accidentally run in a production environment
if (process.env.NODE_ENV === 'production') {
  checkNodeEnv('development');
}

const configuration: webpack.Configuration = {
  devtool: 'inline-source-map',

  mode: 'development',

  target: 'electron-main',

  entry: {
    main: path.join(webpackPaths.srcMainPath, 'main.ts'),
    preload: path.join(webpackPaths.srcMainPath, 'preload.ts'),
  },

  output: {
    path: webpackPaths.dllPath,
    filename: '[name].bundle.dev.js',
    library: {
      type: 'umd',
    },
  },

  plugins: [
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore
    new BundleAnalyzerPlugin({
      analyzerMode: process.env.ANALYZE === 'true' ? 'server' : 'disabled',
      analyzerPort: 8888,
    }),

    new webpack.DefinePlugin({
      'process.type': '"browser"',
    }),

    new webpack.EnvironmentPlugin({
      NODE_ENV: 'development',
      DEBUG_PROD: false,
      START_MINIMIZED: false,
      APP_VERSION: process.env.APP_VERSION || '1.0.0',
      VERSION: process.env.VERSION || '1.0.0',
      APP_NAME: process.env.APP_NAME || 'MTH BDE IOT Client',
      APP_COPYRIGHT: process.env.APP_COPYRIGHT || 'MTH-IT-SERVICE',
      APP_AUTHOR: process.env.APP_AUTHOR || 'Michael Lindner',
      APP_DESCRIPTION: process.env.APP_DESCRIPTION || 'Anwendung zum Erfassen von Betriebsdaten',
    }),
  ],

  /**
   * Disables webpack processing of __dirname and __filename.
   * If you run the bundle in node.js it falls back to these values of node.js.
   * https://github.com/webpack/webpack/issues/2010
   */
  node: {
    __dirname: false,
    __filename: false,
  },
};

export default merge(baseConfig, configuration);
