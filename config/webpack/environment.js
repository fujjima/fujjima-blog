const { environment } = require('@rails/webpacker')
const webpack = require('webpack')


const sassLoader = environment.loaders.get('sass')['use'].find(rule => rule['loader'] === 'sass-loader')
sassLoader.options = {
  ...sassLoader.options,
  implementation: require('sass'),
}

environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
  })
)

module.exports = environment
