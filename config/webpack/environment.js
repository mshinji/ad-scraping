const { environment } = require('@rails/webpacker')
const erb = require('./loaders/erb')
const webpack = require('webpack')

environment.plugins.prepend(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    moment: 'moment',
  })
)

environment.config.resolve.alias = {
  jquery: 'jquery/src/jquery',
  'jquery-ui': 'jquery-ui-dist/jquery-ui',
  clipboard: 'clipboard/dist/clipboard.min',
}
environment.loaders.prepend('erb', erb)

module.exports = environment
