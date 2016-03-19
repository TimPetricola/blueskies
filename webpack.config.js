var webpack = require('webpack')
var ExtractTextPlugin = require('extract-text-webpack-plugin')
var Clean = require('clean-webpack-plugin')
var fs = require('fs')

var ASSETS_MANIFEST = './assets-manifest.json'
var ENTRIES = {
  bundle: [
    './app/js/app.js',
    './app/css/app.css'
  ],
  email: './app/css/email.css'
}
var ASSETS_OUTPUT_PATH = './public/assets'

module.exports = {
  devtool: 'eval',
  entry: ENTRIES,
  output: {
    path: ASSETS_OUTPUT_PATH,
    filename: '[name]-[chunkhash].js'
  },
  minimize: true,
  module: {
    loaders: [
      {
        test: /\.js$/,
        loader: 'babel',
        exclude: /node_modules/,
        include: __dirname,
        query: {
          presets: ['es2015']
        }
      },
      {
        test: /\.css$/,
        loader: ExtractTextPlugin.extract('style', 'css!cssnext')
      }
    ]
  },
  plugins: [
    new Clean(ASSETS_OUTPUT_PATH),
    new ExtractTextPlugin('[name]-[contenthash].css'),
    new webpack.optimize.UglifyJsPlugin({ minimize: true }),
    new webpack.NoErrorsPlugin(),
    function () {
      this.plugin('done', function(stats) {
        var chunks = stats.toJson().assetsByChunkName
        var assets = {}
        Object.keys(chunks).forEach(function (name) {
          chunks[name].forEach(function (chunk) {
            assets[name + '.' + chunk.split('.').pop()] = chunk
          })
        })
        fs.writeFileSync(ASSETS_MANIFEST, JSON.stringify(assets, null, 2))
      });
    },
    new webpack.ProvidePlugin({
      'Promise': 'es6-promise',
      'fetch': 'imports?this=>global!exports?global.fetch!whatwg-fetch'
    })
  ]
}
