var path = require('path');

module.exports = {
  entry: "./gen/ENTRY.js",
  output: {
    path: __dirname,
    filename: "main.js"
  },
  resolve: {
    root: [
      path.join('/usr/lib/dart', 'lib', 'dev_compiler', 'common'),
      path.join(__dirname, 'gen')
    ]
  },
  module: {
    preLoaders: [
      {
        test: /\.js$/,
        loader: "source-map"
      }
    ]
  }
}
